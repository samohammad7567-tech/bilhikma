#!/usr/bin/env bash
#
# Builds the two artifacts that are safe to distribute, and proves each one
# carries the native libraries old phones need.
#
# Why this script exists: a plain `flutter build apk --split-per-abi` writes
# three same-looking APKs into the same folder, with no universal one. Hand a
# 32-bit phone the arm64 split and the install is refused
# (INSTALL_FAILED_NO_MATCHING_ABIS, which some OEM installers render as
# "the package appears to be invalid"); hand it one that installs without a
# matching .so and the process dies at Application creation, before the splash
# ever paints. That is the "it crashes on open / never opens" report from
# older devices.
#
# Usage:  bash scripts/build_release.sh
#
set -euo pipefail

cd "$(dirname "$0")/.."

# Every ABI a current Android phone can be. armeabi-v7a is the one that
# matters here: most genuinely old devices are 32-bit.
REQUIRED_ABIS=("armeabi-v7a" "arm64-v8a")

if [[ ! -f android/key.properties ]]; then
  echo "ERROR android/key.properties not found."
  echo "      A release signed with the debug key cannot be distributed:"
  echo "      users who already installed a build signed elsewhere get"
  echo "      INSTALL_FAILED_UPDATE_INCOMPATIBLE and cannot update."
  exit 1
fi

echo "==> Cleaning previous outputs"
rm -rf build/app/outputs/flutter-apk build/app/outputs/bundle

# The Play Store artifact. Play splits it per device, so every phone gets the
# right ABI automatically — this is what should ship to users.
echo "==> Building App Bundle (for Google Play)"
flutter build appbundle --release

# The sideload artifact. One file that installs on any phone, for manual
# distribution and QA. Deliberately NOT --split-per-abi.
echo "==> Building universal APK (for sideloading / QA)"
flutter build apk --release

APK="build/app/outputs/flutter-apk/app-release.apk"
AAB="build/app/outputs/bundle/release/app-release.aab"

echo "==> Verifying the APK carries every required ABI"
if [[ ! -f "$APK" ]]; then
  echo "ERROR $APK was not produced."
  echo "      If the output is app-<abi>-release.apk instead, the build ran"
  echo "      with --split-per-abi. Those splits must not be handed out."
  exit 1
fi

# Any of these three is normally present; use whichever the machine has.
list_abis() {
  if command -v unzip >/dev/null 2>&1; then
    unzip -l "$1" | grep -oE 'lib/[^/]+/' | cut -d/ -f2 | sort -u
  else
    python -c "import zipfile,sys,posixpath
names={posixpath.dirname(n).split('/')[1] for n in zipfile.ZipFile(sys.argv[1]).namelist() if n.startswith('lib/')}
print('\n'.join(sorted(names)))" "$1"
  fi
}

FOUND="$(list_abis "$APK")"
echo "    ABIs in the APK:"
echo "$FOUND" | sed 's/^/      /'

missing=0
for abi in "${REQUIRED_ABIS[@]}"; do
  if ! echo "$FOUND" | grep -qx "$abi"; then
    echo "ERROR the APK has no $abi native library — phones on that"
    echo "      architecture will fail to install it or crash at launch."
    missing=1
  fi
done
[[ $missing -eq 0 ]] || exit 1

echo
echo "==> Done. Distribute:"
echo "    Play Store : $AAB"
echo "    Sideload   : $APK   (installs on any ABI)"
echo
echo "    Do not hand out build/app/outputs/flutter-apk/app-<abi>-release.apk."
