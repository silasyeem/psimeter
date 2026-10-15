#!/bin/sh
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
udid=${1:-B3D69ACF-D6E8-43E4-A38D-D2C4F8A2A6DB}
out="$root/.impeccable/review"
shots=$(mktemp -d "${TMPDIR:-/tmp}/large-shots.XXXXXX")
trap 'rm -rf "$shots"' EXIT
mkdir -p "$out"

xcodebuild -project "$root/Psimeter.xcodeproj" -scheme Psimeter \
  -destination "platform=iOS Simulator,id=$udid" \
  -derivedDataPath "$root/build/dd" -quiet build
xcrun simctl install "$udid" "$root/build/dd/Build/Products/Debug-iphonesimulator/Psimeter.app"

for appearance in light dark; do
  xcrun simctl ui "$udid" appearance "$appearance"
  for state in live stale trend accented; do
    xcrun simctl terminate "$udid" com.silasyeem.psimeter 2>/dev/null || true
    xcrun simctl launch "$udid" com.silasyeem.psimeter -gallery-large "$state" >/dev/null
    sleep 2
    xcrun simctl io "$udid" screenshot "$shots/$state-$appearance.png" >/dev/null 2>&1
  done
done
xcrun simctl ui "$udid" appearance light

python3 -I "$root/scripts/large-crops.py" "$root" "$shots"
