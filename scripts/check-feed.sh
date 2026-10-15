#!/bin/sh
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
out=$(mktemp -d "${TMPDIR:-/tmp}/feed-check.XXXXXX")
trap 'rm -rf "$out"' EXIT

# macOS 15 matches the iOS 18 deployment target, so an API newer than that fails here too.
xcrun swiftc -swift-version 6 -target "$(uname -m)-apple-macos15" -module-name FeedCheck \
  -o "$out/feed-check" \
  "$root/Shared/Model/Air.swift" "$root"/Shared/Feed/*.swift \
  "$root/Shared/Instrument/Reading.swift" "$root/Shared/Instrument/Bands.swift" \
  "$root/scripts/feed-check/main.swift"

token=$(sed -n 's/^WAQI_TOKEN = //p' "$root/Config/Secrets.xcconfig" 2>/dev/null || true)
WAQI_TOKEN="$token" "$out/feed-check"
