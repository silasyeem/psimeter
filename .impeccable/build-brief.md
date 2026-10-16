# psimeter build brief: Brass Aneroid, layout C

Read first, in order: `PRODUCT.md`, this file, then
`~/.claude/plugins/cache/impeccable/impeccable/4.0.4/skills/impeccable/reference/craft-floor.md`
and `.../reference/ios.md` from the same folder.

## Approved comps (the spec)

- Night: `.impeccable/mocks/comps/comp-c-counter-night.png` (user-approved layout).
- Day: `.impeccable/mocks/comps/comp-c-day.png` (same layout, silver dial; derived from the approval "C's layout, A's silver dial for day").
- Material reference for day: `.impeccable/mocks/decision/assigned.png`.

Comp is king. Reproduce it. Allowed concessions only: fonts (closest system face), genuine comp defects, and text legibility at real size.

Known comp defects to correct in code: the needle in every comp points near 190; it must point at the real value. Comp text is drawn at poster scale (the comp is 1024 px for a ~170 pt widget, about 6x); at real size the engraved labels would be 4 to 6 pt. Floor: 9 pt for engraved tertiary text, and drop scale numerals before you shrink below it. Keep tick marks.

## Direction contract (paste verbatim as the header comment of the widget view file)

```
THESIS: Air read off a real instrument; refuses the band-coloured number tile every AQ widget ships.
OWN-WORLD: Gunmetal plate, knurled brass bezel, grained-silver dial by day, black lacquer with radium lume by night, blued-steel needle, black roller-counter wheels, one five-segment vitreous enamel arc where only the current band is saturated.
STORY: Glance, read the exact 24h PSI for your region and the WAQI AQI beneath it, see the band by needle position, see how fresh it is.
FIRST VIEWPORT: Wide roller counter (PSI) across the dial centre, 160-degree band arc and needle above, smaller AQI counter below, time under it, regional PSIs engraved on the bezel at N/E/S/W.
FORM: Brass Aneroid, grounded list position 4, seed 95d203dd. Layout C approved.
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, and DESIGN.md
```

## Data shape (build against these; adjust names only with reason)

```swift
enum Region: String, CaseIterable { case central, north, east, south, west }
// NEA regionMetadata coords (for the WAQI geo feed):
// north 1.41803,103.82  south 1.29587,103.82  east 1.35735,103.94  west 1.35735,103.70  central 1.35735,103.82

struct PSIReport { let psi: [Region: Int]; let observedAt: Date }       // psi_twenty_four_hourly
struct AQIReport { let aqi: Int; let station: String; let observedAt: Date }

enum FeedFailure: Equatable { case missingToken, offline, unreadable }
enum Feed<Report> { case live(Report), unavailable(FeedFailure) }

struct Snapshot { let region: Region; let psi: Feed<PSIReport>; let aqi: Feed<AQIReport>; let fetchedAt: Date }
```

Bands are a table, not branches:

```swift
struct Band { let name: String; let range: ClosedRange<Int>; let enamel: Color }
enum Scale { case psi, aqi }   // psi dial 0...400; aqi has its own table
```

- PSI (NEA): 0-50 Good, 51-100 Moderate, 101-200 Unhealthy, 201-300 Very Unhealthy, 301+ Hazardous.
- AQI (US EPA): 0-50 Good, 51-100 Moderate, 101-150 Unhealthy for Sensitive Groups, 151-200 Unhealthy, 201-300 Very Unhealthy, 301+ Hazardous.
- Values above the dial max peg the needle at the end stop; the counter still shows the true figure.

## Sources (parse at the boundary, trust types inside)

- PSI: `GET https://api-open.data.gov.sg/v2/real-time/api/psi`. No key. `data.items[0].readings.psi_twenty_four_hourly.{north,south,east,west,central}`, `data.items[0].updatedTimestamp` (ISO 8601, +08:00).
- AQI: `GET https://api.waqi.info/feed/geo:{lat};{lng}/?token={WAQI_TOKEN}` using the selected region's coords. `status == "ok"`, `data.aqi` (Int, but can be the string "-": treat as unreadable), `data.city.name`, `data.time.iso`.
- Token: `.env` holds `WAQI_TOKEN=...` (may be absent today). A script syncs it into a gitignored `Config/Secrets.xcconfig`, surfaced through Info.plist as `WAQIToken`. Absent token means `.unavailable(.missingToken)`, never a crash and never a fake value.
- Fetch both concurrently. Cache the last good Snapshot in the extension's own UserDefaults (no App Group needed) and fall back to it when a fetch fails; it reads stale only once it is older than 2 h.

## States the instrument must render

- Live: as the comp.
- Stale (PSI observedAt older than 2 h): the time engraving reads `STALE 20:30` in the vermilion enamel colour.
- AQI unavailable: the AQI counter wheels are blank (no digits) and its label reads `AQI · NO TOKEN` or `AQI · OFFLINE`.
- PSI unavailable and nothing cached: blank wheels, needle parked at 0, label `PSI · OFFLINE`.
- Night: `colorScheme == .dark` switches to black lacquer and lume. Not an inverted palette.
- Tinted / clear Home Screen (`widgetRenderingMode == .accented`): drop the raster plate, keep the engraved structure, put the needle and counter figures in the accent group.

## Surfaces

- systemSmall (Home Screen): the instrument. `containerBackground` is the bezel-tile asset; content margins disabled.
- accessoryCircular: system `Gauge` 0...400, PSI value as current label.
- accessoryRectangular: `PSI 183 · AQI 168` with `Central · Unhealthy · 20:30` beneath.
- accessoryInline: `PSI 183 · AQI 168`.
- Widget configuration: an AppIntent with a Region parameter (default Central). The counter shows the chosen region; the bezel shows N/E/S/W.
- Timeline: one entry now plus one at the stale mark. Reload after 15 minutes, or one minute past the stale mark if sooner; retry every 5 minutes after any failed fetch or while stale.
- Containing app: the same instrument at large size, attribution (NEA data under the Singapore Open Data Licence; WAQI / aqicn.org attribution), token status. Plus a gallery screen (launch argument `-gallery`) that renders every state above at true systemSmall size in day and night from fixtures, each labelled DEMO. The gallery is the screenshot harness.

## Assets

- `.impeccable/assets/bezel-tile.png`: gunmetal plate, screws, brass ring, flat black centre. The dial is drawn over the centre in code. Measured opening (1024 px source): centre at (0.498, 0.480) of the side, so slightly above middle; diameter 0.776 of the side horizontally and 0.771 vertically. Draw the dial as a circle of diameter 0.778 at that centre so it just covers the black.
- `.impeccable/assets/dial-silver.png`: grained silver texture for the day dial, clipped to the circle.
- Everything else is code: band arc, ticks, needle, hub, counter wheels with cylinder shading, crystal highlight, lacquer, lume glow.
