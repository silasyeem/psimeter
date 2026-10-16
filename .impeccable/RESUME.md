# Status (2026-10-15 10:30 SGT)

Small + Lock Screen + Large (barograph) widgets built, finish-reviewed (ship), and installed on the user's iPhone 15 Pro Max (free signing, profile expires 2026-10-22; reinstall with `xcrun devicectl device install app --device 00008130-000275A00191001C build/dd-device/Build/Products/Release-iphoneos/Psimeter.app` after a Release build with -allowProvisioningUpdates).
- Wheels: Archivo Black (OFL, Shared/Fonts). Refresh: every 15 min (system-budgeted).
- Large surface: raster assets in .impeccable/assets/large/ made by scripts/{chroma-key,night-bezel,brass-tone,plate-tones}.swift + scripts/large-assets.py.

- PSI: NEA 24h PSI via data.gov.sg. AQI: WAQI official station per region (@1662 N, @1663 S, @1664 E, @1665 W, @1666 C). The geo feed does not resolve Singapore coordinates.
- Token: .env WAQI_TOKEN -> scripts/sync-secrets.sh -> Config/Secrets.xcconfig -> Info.plist WAQIToken.
- Verify: scripts/check-feed.sh (live NEA + all five WAQI stations), scripts/capture-gallery.sh (screens + comp comparisons).

Verified 2026-10-15 (captures in .impeccable/review/):
- Real Lock Screen, vibrant: inline, rectangular and circular all legible with live data (lockscreen-light.png).
- Tinted and clear Home Screen: renders as an engraved line drawing with every figure (widget-tinted.png, widget-clear.png). A placeholder-redacted frame shows for a few seconds right after switching modes; that's the system, not a bug.
- Reduce Motion: needle snaps, wheels crossfade (motion-default.png vs motion-reduced.png).
- 158 pt (iPhone 17e) and 170 pt (17 Pro Max) gallery tiles: no clipping at the 9 pt floor (gallery-17e-light.png, gallery-17promax-light.png). These sizes come from Apple's table; only the 17 Pro's 164 pt was measured on a real Home Screen.

Open:
- WAQI API terms for a commercial App Store app; attribution is in the app.
- NEA rate-limits rapid unkeyed calls (HTTP 429 -> falls back to the held snapshot).
- On-device install needs a signing team in project.yml.
- Stale stamp contrast margin is thin (about 4.7:1); don't darken the rim vignette.
- DESIGN.md colour names were chosen by the documenter; confirm or rename.


## 2026-10-16
- PR #2 merged into main at 1e14a0e: one NEA request per refresh wave + 5-min retry + STALE only when data >2h old; Aged wear option; aged large fit under the widget memory limit (scripts/widget-footprint.sh). Installed on the user's iPhone and verified via iPhone Mirroring.
- Open: Polished large peaks ~36.6 MB on the simulator (works on device, thin margin).
