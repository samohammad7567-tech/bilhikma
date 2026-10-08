#!/usr/bin/env bash
#
# Encodes the Apple signing material into the base64 blobs that the
# "iOS Release" GitHub Actions workflow expects, and (optionally) uploads
# them straight to the repository with the GitHub CLI.
#
# Run this on a Mac that already has the distribution certificate in its
# login keychain. See docs/ios_release_setup.md for the full walkthrough.
#
# Usage:
#   scripts/ios_encode_secrets.sh \
#       --p12 ~/Desktop/bilhikma_dist.p12 \
#       --profile ~/Desktop/Bilhikma_AdHoc.mobileprovision \
#       --service-account ~/Desktop/firebase-sa.json \
#       [--push]
#
set -euo pipefail

P12=""
PROFILE=""
SERVICE_ACCOUNT=""
PLIST="ios/Runner/GoogleService-Info.plist"
PUSH=0

die() { echo "error: $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --p12)             P12="${2:-}"; shift 2 ;;
    --profile)         PROFILE="${2:-}"; shift 2 ;;
    --service-account) SERVICE_ACCOUNT="${2:-}"; shift 2 ;;
    --plist)           PLIST="${2:-}"; shift 2 ;;
    --push)            PUSH=1; shift ;;
    -h|--help)         sed -n '2,20p' "$0"; exit 0 ;;
    *)                 die "unknown argument: $1" ;;
  esac
done

[ -n "$P12" ]     || die "--p12 is required"
[ -n "$PROFILE" ] || die "--profile is required"
[ -f "$P12" ]     || die "no such file: $P12"
[ -f "$PROFILE" ] || die "no such file: $PROFILE"

b64() { base64 -i "$1" | tr -d '\n'; }

OUT_DIR="$(mktemp -d)"
trap 'rm -rf "$OUT_DIR"' EXIT

b64 "$P12"     > "$OUT_DIR/IOS_DIST_CERT_P12_BASE64"
b64 "$PROFILE" > "$OUT_DIR/IOS_PROVISION_PROFILE_BASE64"
[ -n "$SERVICE_ACCOUNT" ] && cp "$SERVICE_ACCOUNT" "$OUT_DIR/FIREBASE_SERVICE_ACCOUNT_JSON"
[ -f "$PLIST" ] && b64 "$PLIST" > "$OUT_DIR/GOOGLE_SERVICE_INFO_PLIST_BASE64"

echo "== Provisioning profile =="
security cms -D -i "$PROFILE" > "$OUT_DIR/profile.plist"
for key in Name UUID ExpirationDate; do
  printf '  %-15s %s\n' "$key:" "$(/usr/libexec/PlistBuddy -c "Print :$key" "$OUT_DIR/profile.plist" 2>/dev/null || echo '-')"
done
printf '  %-15s %s\n' "app id:" \
  "$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:application-identifier' "$OUT_DIR/profile.plist" 2>/dev/null || echo '-')"
printf '  %-15s %s\n' "aps-env:" \
  "$(/usr/libexec/PlistBuddy -c 'Print :Entitlements:aps-environment' "$OUT_DIR/profile.plist" 2>/dev/null || echo 'MISSING - push notifications will not work')"
printf '  %-15s %s\n' "devices:" \
  "$(/usr/libexec/PlistBuddy -c 'Print :ProvisionedDevices' "$OUT_DIR/profile.plist" 2>/dev/null | grep -c '^        ' || echo '0 (ad-hoc builds need registered UDIDs)')"
echo

echo "== Certificate =="
openssl pkcs12 -in "$P12" -nokeys -legacy -passin pass:"${IOS_DIST_CERT_PASSWORD:-}" 2>/dev/null \
  | openssl x509 -noout -subject -enddate 2>/dev/null \
  || echo "  (set IOS_DIST_CERT_PASSWORD in your shell to print certificate details)"
echo

if [ "$PUSH" -eq 1 ]; then
  command -v gh >/dev/null || die "--push needs the GitHub CLI (brew install gh)"
  echo "== Uploading secrets with gh =="
  for f in "$OUT_DIR"/*; do
    name="$(basename "$f")"
    case "$name" in profile.plist) continue ;; esac
    gh secret set "$name" < "$f"
    echo "  set $name"
  done
  echo
  echo "Still to set by hand (they are not files):"
  echo "  gh secret set IOS_DIST_CERT_PASSWORD"
  echo "  gh secret set FIREBASE_IOS_APP_ID --body '1:940046231017:ios:4c047fc493bb7703635778'"
else
  DEST="${HOME}/Desktop/bilhikma-ios-secrets"
  mkdir -p "$DEST"
  cp "$OUT_DIR"/* "$DEST"/
  rm -f "$DEST/profile.plist"
  echo "Secret values written to: $DEST"
  echo "Paste each file's contents into the matching GitHub repository secret,"
  echo "then delete the directory:  rm -rf '$DEST'"
fi
