#!/usr/bin/env bash
#
# run_ui_tests.sh — run the XCUITest suite (SplitPayUITests) in the simulator.
#
# Kept separate from run_tests.sh on purpose: UI tests boot the whole app and
# run one launch per test, so they're an order of magnitude slower than the
# package unit tests. CI runs this as its own lane.
#
# Usage:
#   scripts/run_ui_tests.sh                        # the whole suite
#   scripts/run_ui_tests.sh AuthTests              # only classes matching
#   scripts/run_ui_tests.sh -only-testing:SplitPayUITests/TransferTests/testHappyPath
#   SIM_DESTINATION="platform=iOS Simulator,id=<udid>" scripts/run_ui_tests.sh
#
# Everything runs against the in-memory mock backend: the tests launch the app
# with -UITest, so no Supabase credentials or network are involved.

set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SCHEME="SplitPay"
BUNDLE_ID="com.dlong.SplitPayUITests"

FILTERS=("$@")

# --- Simulator destination -------------------------------------------------

resolve_destination() {
    if [[ -n "${SIM_DESTINATION:-}" ]]; then
        echo "$SIM_DESTINATION"
        return
    fi

    local udid
    udid="$(xcrun simctl list devices booted | awk -F '[()]' '/iPhone/ { print $2; exit }')"
    if [[ -z "$udid" ]]; then
        udid="$(xcrun simctl list devices available | awk -F '[()]' '/iPhone/ { print $2; exit }')"
    fi
    if [[ -z "$udid" ]]; then
        echo "error: no iOS simulator found — start one or set SIM_DESTINATION" >&2
        return 1
    fi
    echo "platform=iOS Simulator,id=$udid"
}

DESTINATION="$(resolve_destination)" || exit 1

# --- Run -------------------------------------------------------------------

# -only-testing filters are passed straight through to xcodebuild; a bare
# class name is expanded to the bundle-qualified form. Several filters can be
# given at once — they union.
ARGS=(test -scheme "$SCHEME" -destination "$DESTINATION")
# ${arr[@]+…} guards the empty case: bash 3.2 treats an empty array as unset
# under `set -u`.
for filter in ${FILTERS[@]+"${FILTERS[@]}"}; do
    if [[ "$filter" == -only-testing:* ]]; then
        ARGS+=("$filter")
    else
        ARGS+=("-only-testing:$BUNDLE_ID/$filter")
    fi
done

echo "Running UI tests: xcodebuild ${ARGS[*]}"

# `set -o pipefail` is on, but the exit code of a pipeline assignment still
# comes from the last command — surface xcodebuild's own status explicitly.
xcodebuild "${ARGS[@]}" 2>&1 | tee /tmp/splitpay-ui-tests.log
status=${PIPESTATUS[0]}
exit "$status"
