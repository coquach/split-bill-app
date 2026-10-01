#!/usr/bin/env bash
#
# run_tests.sh — run the whole test suite, package by package.
#
# Two kinds of packages:
#   - Foundation logic packages build and test on the macOS host (`swift test`).
#   - UI-adjacent packages import SystemDesign/UIKit, so they test in the iOS
#     simulator (`xcodebuild test`).
#
# Usage:
#   scripts/run_tests.sh              # everything
#   scripts/run_tests.sh Transfer     # only packages matching "Transfer"
#   SIM_DESTINATION="platform=iOS Simulator,id=<udid>" scripts/run_tests.sh
#
# One failing package never stops the others; the script exits non-zero if
# anything failed.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SWIFT_PACKAGES=(
    "Foundation/Utils"
    "Foundation/Router"
    "Foundation/Domains"
)

XCODE_PACKAGES=(
    "Foundation/SystemDesign"
    "Features/Authentication"
    "Features/Transfer"
    "Features/SplitBill"
    "Features/Home"
    "Features/Profile"
)

FILTER="${1:-}"
LOG_DIR="$(mktemp -d /tmp/splitbill-tests.XXXXXX)"
trap 'rm -rf "$LOG_DIR"' EXIT

# --- Simulator destination -------------------------------------------------

resolve_destination() {
    if [[ -n "${SIM_DESTINATION:-}" ]]; then
        echo "$SIM_DESTINATION"
        return
    fi

    local udid
    udid="$(xcrun simctl list devices booted | awk -F '[()]' '/iPhone/ { print $2; exit }')"
    if [[ -z "$udid" ]]; then
        # Fall back to the first available iPhone (listed newest-first).
        udid="$(xcrun simctl list devices available | awk -F '[()]' '/iPhone/ { print $2; exit }')"
    fi
    if [[ -z "$udid" ]]; then
        echo "error: no iOS simulator found — start one or set SIM_DESTINATION" >&2
        return 1
    fi
    echo "platform=iOS Simulator,id=$udid"
}

DESTINATION="$(resolve_destination)"

# --- Simulator warm-up -------------------------------------------------------

# Boot the destination up front and wait until it is fully settled. A cold
# boot that starts *during* xcodebuild is what trips the flaky "Process spawn
# via launchd failed" failures and the runs that stall after every test has
# already passed (0% CPU, log frozen while finalizing the result bundle).
ensure_simulator_ready() {
    local udid
    udid="$(sed -n 's/.*id=\([A-F0-9-]*\).*/\1/p' <<<"$DESTINATION")"
    [[ -z "$udid" ]] && return 0

    if ! xcrun simctl list devices booted | grep -q "$udid"; then
        xcrun simctl boot "$udid" 2>/dev/null
    fi
    # -b: block until the boot completes; exits quickly when already booted.
    xcrun simctl bootstatus "$udid" -b >/dev/null 2>&1
}

# --- Per-package runner ----------------------------------------------------

RESULTS=()
FAILED=0

# xcodebuild occasionally stalls after the tests have all passed, hanging the
# whole suite. Bound each run so it fails loudly instead of hanging forever.
# Exit code 124 follows GNU timeout's convention. (perl's alarm can't be used
# here — the timer is dropped the moment the command is exec'd.)
XCODEBUILD_TIMEOUT=900
run_with_timeout() {
    local seconds="$1"; shift
    "$@" &
    local pid=$!
    local waited=0
    while kill -0 "$pid" 2>/dev/null && (( waited < seconds )); do
        sleep 1
        waited=$((waited + 1))
    done
    if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid" 2>/dev/null
        pkill -9 -f xctest 2>/dev/null   # orphaned test-runner children
        return 124
    fi
    wait "$pid"
}

run_swift_package() {
    local pkg="$1" name log
    name="$(basename "$pkg")"
    log="$LOG_DIR/$name.log"

    local start=$SECONDS
    if (cd "$pkg" && swift test >"$log" 2>&1); then
        RESULTS+=("PASS  $name ($((SECONDS - start))s)")
    else
        RESULTS+=("FAIL  $name ($((SECONDS - start))s)")
        FAILED=$((FAILED + 1))
        echo "---------- $name failed (last 60 lines) ----------" >&2
        tail -n 60 "$log" >&2
    fi
}

run_xcode_package() {
    local pkg="$1" name log
    name="$(basename "$pkg")"
    log="$LOG_DIR/$name.log"

    local start=$SECONDS
    ensure_simulator_ready
    # xcodebuild takes the package as the working directory, not a path arg.
    if (cd "$pkg" && run_with_timeout "$XCODEBUILD_TIMEOUT" xcodebuild test \
        -scheme "$name" \
        -destination "$DESTINATION" \
        >"$log" 2>&1); then
        RESULTS+=("PASS  $name ($((SECONDS - start))s)")
    else
        RESULTS+=("FAIL  $name ($((SECONDS - start))s)")
        FAILED=$((FAILED + 1))
        echo "---------- $name failed (last 60 lines) ----------" >&2
        tail -n 60 "$log" >&2
    fi
}

# --- Main ------------------------------------------------------------------

echo "Running test suite (logs in $LOG_DIR)"
[[ -n "$FILTER" ]] && echo "Filtering packages matching: $FILTER"
[[ -n "$DESTINATION" ]] && echo "Simulator destination: $DESTINATION"
echo

for pkg in "${SWIFT_PACKAGES[@]}"; do
    [[ -n "$FILTER" && "$pkg" != *"$FILTER"* ]] && continue
    run_swift_package "$pkg"
done

for pkg in "${XCODE_PACKAGES[@]}"; do
    [[ -n "$FILTER" && "$pkg" != *"$FILTER"* ]] && continue
    run_xcode_package "$pkg"
done

echo
echo "================= Results ================="
printf '%s\n' "${RESULTS[@]}"
echo "==========================================="

if (( FAILED > 0 )); then
    echo "$FAILED package(s) failed." >&2
    exit 1
fi
echo "All packages passed."
