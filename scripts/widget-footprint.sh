#!/bin/sh
set -eu

udid=${2:-B3D69ACF-D6E8-43E4-A38D-D2C4F8A2A6DB}
pid=$(ps -eo pid,args | grep "$udid.*PsimeterWidget.appex/PsimeterWidget" | grep -v grep | awk '{print $1}' | head -1)

case "${1:-read}" in
  kill)
    if [ -n "$pid" ]; then kill -9 "$pid"; echo "stopped extension $pid"; else echo "no extension running"; fi
    ;;
  read)
    if [ -z "$pid" ]; then echo "no extension running"; exit 0; fi
    footprint --noCategories -f bytes "$pid" 2>/dev/null | awk -v pid="$pid" '
      /phys_footprint:/ { now = $2 }
      /phys_footprint_peak:/ { peak = $2 }
      END { printf "extension %s: footprint %.1f MB, peak %.1f MB\n", pid, now / 1048576, peak / 1048576 }'
    ;;
  *)
    echo "usage: widget-footprint.sh [read|kill] [simulator udid]" >&2
    exit 2
    ;;
esac
