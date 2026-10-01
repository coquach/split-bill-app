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

# --- Per-package runner ----------------------------------------------------

RESULTS=()
FAILED=0

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
    # xcodebuild takes the package as the working directory, not a path arg.
    if (cd "$pkg" && xcodebuild test \
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
