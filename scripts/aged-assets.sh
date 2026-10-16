#!/bin/sh
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
a="$root/.impeccable/assets"
l="$a/large"
o="$a/aged"
age() { swift -O "$root/scripts/age-assets.swift" "$1" "$2" "$o/tex-brass.png" "$o/tex-steel.png" "${3:-1}"; }

age "$a/bezel-tile.png" "$o/bezel-tile-aged.png"
swift "$root/scripts/night-bezel.swift" "$o/bezel-tile-aged.png" "$o/bezel-tile-night-aged.png"

age "$l/drum-housing-raw-keyed.png" "$o/drum-housing-raw-aged.png"
swift "$root/scripts/brass-tone.swift" "$o/drum-housing-raw-aged.png" "$o/drum-housing-aged.png" 0.09 0.72
swift "$root/scripts/night-bezel.swift" "$o/drum-housing-raw-aged.png" "$o/drum-housing-night-aged.png" 0.62 0.66 0.16

age "$l/pen-arm-raw-keyed.png" "$o/pen-arm-raw-aged.png" 0.7
swift "$root/scripts/brass-tone.swift" "$o/pen-arm-raw-aged.png" "$o/pen-arm-aged.png" 0.09 0.72
swift "$root/scripts/night-bezel.swift" "$o/pen-arm-raw-aged.png" "$o/pen-arm-night-aged.png" 0.62 0.66 0.16

age "$l/plate-noscrew-raw.png" "$o/plate-raw-aged.png"
swift "$root/scripts/plate-tones.swift" "$o/plate-raw-aged.png" "$o/plate-day-aged.png" "$o/plate-night-aged.png"

age "$l/screw.png" "$o/screw-aged.png"
age "$l/screw-night.png" "$o/screw-night-aged.png"

rm -f "$o/drum-housing-raw-aged.png" "$o/pen-arm-raw-aged.png" "$o/plate-raw-aged.png"
echo "aged assets written to $o"
