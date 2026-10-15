#!/bin/sh
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
udid=${1:-B3D69ACF-D6E8-43E4-A38D-D2C4F8A2A6DB}
out="$root/.impeccable/review"
app="$root/build/dd/Build/Products/Debug-iphonesimulator/Psimeter.app"
mkdir -p "$out"

xcodebuild -project "$root/Psimeter.xcodeproj" -scheme Psimeter \
  -destination "platform=iOS Simulator,id=$udid" \
  -derivedDataPath "$root/build/dd" -quiet build
xcrun simctl install "$udid" "$app"

for appearance in light dark; do
  xcrun simctl ui "$udid" appearance "$appearance"
  xcrun simctl terminate "$udid" com.silasyeem.psimeter 2>/dev/null || true
  xcrun simctl launch "$udid" com.silasyeem.psimeter -gallery >/dev/null
  sleep 3
  xcrun simctl io "$udid" screenshot "$out/gallery-$appearance.png" >/dev/null 2>&1
done
xcrun simctl ui "$udid" appearance light

python3 -I "$root/scripts/review-crops.py" "$root"
