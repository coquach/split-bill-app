#!/usr/bin/env bash
#
# add_spm_packages_to_xcodeproj.sh
#
# One-off utility that wires Swift Package Manager dependencies directly into
# SplitPay.xcodeproj/project.pbxproj by editing the pbxproj text, instead of
# clicking through Xcode's "Add Package Dependencies..." dialog by hand.
#
# Why this exists: after project.pbxproj had to be recreated from scratch,
# every local Swift package + remote SPM dependency the app target actually
# needs had to be re-linked one at a time in Xcode's UI. This script does the
# same wiring programmatically so it can be re-run (e.g. if the pbxproj ever
# has to be regenerated again) instead of repeating the manual clicks.
#
# What it adds to the SplitPay (app) target only:
#   Local packages (resolved by relative path inside this repo):
#     Foundation/Domains        -> products: Domains, DomainDatas
#     Features/Authentication   -> products: Authentication
#     Features/Home             -> products: Home
#   Remote packages:
#     Swinject       (>= 2.8.0)  -> product: Swinject
#     supabase-swift (>= 2.55.2) -> product: Supabase
#
#   Router, SystemDesign, CommonUi, Loggers, Utils are intentionally NOT
#   added here, because the SplitPay app target does not `import` them
#   directly. They resolve transitively through Authentication/Home's own
#   Package.swift (which already depend on them via relative paths).
#
# Usage:
#   ./scripts/add_spm_packages_to_xcodeproj.sh
#
# Run it from anywhere inside the repo (it walks up from its own location to
# find the folder that contains SplitPay.xcodeproj). It edits the pbxproj IN
# PLACE and writes a timestamped backup next to it before touching anything.
# It refuses to run if any of the target packages already appear in the
# pbxproj, so it will not silently double-add entries.
#
# Requires: bash, awk, openssl (all present by default on macOS). Touches
# only project.pbxproj (plain text, not Swift), so it doesn't conflict with
# the project rule that all .swift files are hand-written.

set -euo pipefail

# ---------------------------------------------------------------------------
# Config: what to add. Edit these if the set of dependencies changes.
# Parallel arrays: index i in LOCAL_PATHS matches index i in LOCAL_PRODUCTS.
# ---------------------------------------------------------------------------

LOCAL_PATHS=("Foundation/Domains" "Features/Authentication" "Features/Home")
LOCAL_PRODUCTS=("Domains DomainDatas" "Authentication" "Home")

REMOTE_NAMES=("Swinject" "supabase-swift")
REMOTE_URLS=(
  "https://github.com/Swinject/Swinject.git"
  "https://github.com/supabase/supabase-swift.git"
)
REMOTE_MINVERS=("2.8.0" "2.55.2")
REMOTE_PRODUCTS=("Swinject" "Supabase")

# Anchors specific to the SplitPay app target's current pbxproj layout.
# If Xcode ever regenerates the project with different object IDs, update
# this by grepping project.pbxproj for the SplitPay target's
# PBXFrameworksBuildPhase entry (not SplitPayTests/SplitPayUITests).
FRAMEWORKS_PHASE_ID="6A67E9583062C6FD005289DA"
EXISTING_LOCAL_REF_LINE='6A67E9B630642DB1005289DA /* XCLocalSwiftPackageReference "Core/CommonUi" */'

# ---------------------------------------------------------------------------
# Locate repo root (folder containing SplitPay.xcodeproj) from this script's
# own location.
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
while [[ "$REPO_ROOT" != "/" && ! -f "$REPO_ROOT/SplitPay.xcodeproj/project.pbxproj" ]]; do
  REPO_ROOT="$(dirname "$REPO_ROOT")"
done
PBXPROJ="$REPO_ROOT/SplitPay.xcodeproj/project.pbxproj"

if [[ ! -f "$PBXPROJ" ]]; then
  echo "error: could not find SplitPay.xcodeproj/project.pbxproj above $SCRIPT_DIR" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Guard: refuse to run if any target package is already wired in.
# ---------------------------------------------------------------------------

already=()
for p in "${LOCAL_PATHS[@]}"; do
  grep -qF "XCLocalSwiftPackageReference \"$p\"" "$PBXPROJ" && already+=("$p")
done
for n in "${REMOTE_NAMES[@]}"; do
  grep -qF "XCRemoteSwiftPackageReference \"$n\"" "$PBXPROJ" && already+=("$n")
done
if [[ ${#already[@]} -gt 0 ]]; then
  echo "Refusing to run: these packages already appear to be wired in project.pbxproj:" >&2
  printf '  %s\n' "${already[@]}" >&2
  echo "Revert or remove them first, or this script will add duplicate entries." >&2
  exit 1
fi

BACKUP="$PBXPROJ.bak.$(date +%Y%m%d%H%M%S)"
cp "$PBXPROJ" "$BACKUP"
echo "Backed up original to $BACKUP"

# ---------------------------------------------------------------------------
# ID generation: 24 uppercase hex chars, unique within the file.
# ---------------------------------------------------------------------------

USED_IDS=" $(grep -oE '[0-9A-F]{24}' "$PBXPROJ" | tr '\n' ' ') "

new_id() {
  local candidate
  while :; do
    candidate="$(openssl rand -hex 12 | tr '[:lower:]' '[:upper:]')"
    if [[ "$USED_IDS" != *" $candidate "* ]]; then
      USED_IDS="$USED_IDS$candidate "
      echo "$candidate"
      return
    fi
  done
}

# ---------------------------------------------------------------------------
# Build up all the text blocks + bookkeeping lines we need to insert.
# ---------------------------------------------------------------------------

BUILD_FILE_LINES=""
LOCAL_REF_BLOCKS=""
REMOTE_REF_BLOCKS=""
PRODUCT_DEP_BLOCKS=""
PKG_REF_LINES=""        # for project-level packageReferences array
TARGET_DEP_LINES=""     # for SplitPay target's packageProductDependencies array
FRAMEWORKS_FILE_LINES="" # for SplitPay target's Frameworks build phase files array

add_product() {
  # $1 = product name, $2 = ref id, $3 = ref comment
  local prod="$1" ref_id="$2" ref_comment="$3"
  local dep_id bf_id
  dep_id="$(new_id)"
  bf_id="$(new_id)"

  PRODUCT_DEP_BLOCKS+=$'\t\t'"$dep_id"' /* '"$prod"' */ = {'$'\n'
  PRODUCT_DEP_BLOCKS+=$'\t\t\tisa = XCSwiftPackageProductDependency;\n'
  PRODUCT_DEP_BLOCKS+=$'\t\t\tpackage = '"$ref_id"' /* '"$ref_comment"' */;'$'\n'
  PRODUCT_DEP_BLOCKS+=$'\t\t\tproductName = '"$prod"';'$'\n'
  PRODUCT_DEP_BLOCKS+=$'\t\t};\n'

  BUILD_FILE_LINES+=$'\t\t'"$bf_id"' /* '"$prod"' in Frameworks */ = {isa = PBXBuildFile; productRef = '"$dep_id"' /* '"$prod"' */; };'$'\n'

  TARGET_DEP_LINES+=$'\t\t\t\t'"$dep_id"' /* '"$prod"' */,'$'\n'
  FRAMEWORKS_FILE_LINES+=$'\t\t\t\t'"$bf_id"' /* '"$prod"' in Frameworks */,'$'\n'
}

for i in "${!LOCAL_PATHS[@]}"; do
  relpath="${LOCAL_PATHS[$i]}"
  ref_id="$(new_id)"
  ref_comment="XCLocalSwiftPackageReference \"$relpath\""

  LOCAL_REF_BLOCKS+=$'\t\t'"$ref_id"' /* '"$ref_comment"' */ = {'$'\n'
  LOCAL_REF_BLOCKS+=$'\t\t\tisa = XCLocalSwiftPackageReference;\n'
  LOCAL_REF_BLOCKS+=$'\t\t\trelativePath = '"$relpath"';'$'\n'
  LOCAL_REF_BLOCKS+=$'\t\t};\n'

  PKG_REF_LINES+=$'\t\t\t\t'"$ref_id"' /* '"$ref_comment"' */,'$'\n'

  for prod in ${LOCAL_PRODUCTS[$i]}; do
    add_product "$prod" "$ref_id" "$ref_comment"
  done
done

for i in "${!REMOTE_NAMES[@]}"; do
  name="${REMOTE_NAMES[$i]}"
  url="${REMOTE_URLS[$i]}"
  minver="${REMOTE_MINVERS[$i]}"
  ref_id="$(new_id)"
  ref_comment="XCRemoteSwiftPackageReference \"$name\""

  REMOTE_REF_BLOCKS+=$'\t\t'"$ref_id"' /* '"$ref_comment"' */ = {'$'\n'
  REMOTE_REF_BLOCKS+=$'\t\t\tisa = XCRemoteSwiftPackageReference;\n'
  REMOTE_REF_BLOCKS+=$'\t\t\trepositoryURL = "'"$url"'";'$'\n'
  REMOTE_REF_BLOCKS+=$'\t\t\trequirement = {\n'
  REMOTE_REF_BLOCKS+=$'\t\t\t\tkind = upToNextMajorVersion;\n'
  REMOTE_REF_BLOCKS+=$'\t\t\t\tminimumVersion = '"$minver"';'$'\n'
  REMOTE_REF_BLOCKS+=$'\t\t\t};\n'
  REMOTE_REF_BLOCKS+=$'\t\t};\n'

  PKG_REF_LINES+=$'\t\t\t\t'"$ref_id"' /* '"$ref_comment"' */,'$'\n'

  add_product "${REMOTE_PRODUCTS[$i]}" "$ref_id" "$ref_comment"
done

# ---------------------------------------------------------------------------
# Apply the six edits with awk, each keyed off an anchor that is unique (or
# disambiguated by the line immediately before it) in the current pbxproj.
# ---------------------------------------------------------------------------

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

awk -v build_files="$BUILD_FILE_LINES" \
    -v local_refs="$LOCAL_REF_BLOCKS" \
    -v remote_refs="$REMOTE_REF_BLOCKS" \
    -v product_deps="$PRODUCT_DEP_BLOCKS" \
    -v pkg_ref_lines="$PKG_REF_LINES" \
    -v target_dep_lines="$TARGET_DEP_LINES" \
    -v fw_lines="$FRAMEWORKS_FILE_LINES" \
    -v fw_phase_id="$FRAMEWORKS_PHASE_ID" \
    -v existing_local_ref="$EXISTING_LOCAL_REF_LINE" '
  {
    line = $0

    # 1) right after "Begin PBXBuildFile section" marker
    if (line == "/* Begin PBXBuildFile section */") {
      print line
      printf "%s", build_files
      next
    }

    # 2) + 3) right before "Begin XCLocalSwiftPackageReference section":
    #    insert new remote-ref + product-dep sections, then fall through to
    #    print the marker itself, followed by the new local-ref blocks.
    if (line == "/* Begin XCLocalSwiftPackageReference section */") {
      printf "/* Begin XCRemoteSwiftPackageReference section */\n"
      printf "%s", remote_refs
      printf "/* End XCRemoteSwiftPackageReference section */\n\n"
      printf "/* Begin XCSwiftPackageProductDependency section */\n"
      printf "%s", product_deps
      printf "/* End XCSwiftPackageProductDependency section */\n\n"
      print line
      printf "%s", local_refs
      next
    }

    # 4) project-level packageReferences array: it currently contains
    #    exactly one entry (the CommonUi ref). Track the 2-line sequence and
    #    inject right before the closing ");".
    if (line ~ /^\t\t\tpackageReferences = \($/) {
      in_pkgrefs = 1
      print line
      next
    }
    if (in_pkgrefs == 1) {
      # this should be the existing CommonUi line
      print line
      in_pkgrefs = 2
      next
    }
    if (in_pkgrefs == 2 && line == "\t\t\t);") {
      printf "%s", pkg_ref_lines
      print line
      in_pkgrefs = 0
      next
    }

    # 5) SplitPay app target packageProductDependencies: disambiguate the 3
    #    targets by remembering we just printed "name = SplitPay;".
    if (line == "\t\t\tname = SplitPay;") {
      saw_splitpay_name = 1
      print line
      next
    }
    if (saw_splitpay_name == 1 && line == "\t\t\tpackageProductDependencies = (") {
      saw_splitpay_name = 0
      in_target_deps = 1
      print line
      next
    }
    if (line == "\t\t\tname = SplitPayTests;" || line == "\t\t\tname = SplitPayUITests;") {
      saw_splitpay_name = 0
    }
    if (in_target_deps == 1 && line == "\t\t\t);") {
      printf "%s", target_dep_lines
      print line
      in_target_deps = 0
      next
    }

    # 6) SplitPay Frameworks build phase files array: disambiguate the 3
    #    targets by the unique Frameworks phase object ID.
    if (line == "\t\t" fw_phase_id " /* Frameworks */ = {") {
      in_fw_target = 1
      print line
      next
    }
    if (in_fw_target == 1 && line == "\t\t\tfiles = (") {
      in_fw_target = 2
      print line
      next
    }
    if (in_fw_target == 2 && line == "\t\t\t);") {
      printf "%s", fw_lines
      print line
      in_fw_target = 0
      next
    }

    print line
  }
' "$PBXPROJ" > "$TMP"

mv "$TMP" "$PBXPROJ"
trap - EXIT

echo "Done. Added to SplitPay target:"
for i in "${!LOCAL_PATHS[@]}"; do
  echo "  local  ${LOCAL_PATHS[$i]}: ${LOCAL_PRODUCTS[$i]}"
done
for i in "${!REMOTE_NAMES[@]}"; do
  echo "  remote ${REMOTE_NAMES[$i]} >= ${REMOTE_MINVERS[$i]}: ${REMOTE_PRODUCTS[$i]}"
done
echo
echo "Reopen Xcode (or let it reload project.pbxproj from disk) and build to confirm everything resolves."
