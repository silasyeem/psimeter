---
name: psimeter
description: A brass aneroid and a brass barograph that read NEA's 24-hour PSI and WAQI's AQI on the iOS Home Screen.
colors:
  brass: "#cca352"
  brass-highlight: "#f7e09e"
  brass-shadow: "#8c6629"
  blued-steel-root: "#0a1f45"
  blued-steel-tip: "#337adb"
  enamel-green: "#338c45"
  enamel-blue: "#306bbd"
  enamel-vermilion: "#eb4a21"
  enamel-oxblood: "#8c2b29"
  enamel-maroon: "#6e1c2b"
  night-enamel-warmth: "#ff9938"
  engraving-ink: "#1a1a1c"
  plate-cream: "#e8e0cc" # day engraving on the gunmetal plate (barograph)
  chart-grid: "#57668a" # day chart rules and axes (barograph)
  trace-ink: "#261a45" # day pen trace (barograph)
  bezel-ink: "#33210a"
  bezel-relief: "#fff0bd8c"
  figure-white: "#f7f7f2"
  drum-crest: "#454545"
  drum-shadow: "#050505"
  counter-window: "#0f0d08"
  radium-lume: "#ccedc2"
  lacquer-centre: "#1c1c1c"
  lacquer-edge: "#040404"
  gunmetal-needle-root: "#212424"
  gunmetal-needle-tip: "#424745"
  stale-rust: "#70180a"
  stale-ember: "#ff6b42"
  stale-ember-light: "#ff9e7a" # day stale mark on the gunmetal plate (barograph)
  accented-plate: "#262930"
  accent-amber: "#ffc761" # gallery stand-in for the system tint; a device tints the accent group itself
typography:
  counter-psi:
    fontFamily: "Archivo Black" # SIL OFL 1.1, bundled in the app and the widget extension
    fontSize: "30.7pt" # drum height x 0.703 / 0.712, so a 0.712em digit fills 70.3% of the drum; at the 164pt reference widget
    fontWeight: 400 # the family's only style, black by design
  counter-aqi:
    fontFamily: "Archivo Black"
    fontSize: "11.1pt" # same formula on the AQI counter, floored at 9pt
    fontWeight: 400
  counter-psi-large:
    fontFamily: "Archivo Black"
    fontSize: "60pt" # same formula on the 84pt barograph PSI counter
    fontWeight: 400
  counter-aqi-large:
    fontFamily: "Archivo Black"
    fontSize: "31.4pt" # same formula on the 44pt barograph AQI counter
    fontWeight: 400
  engraving:
    fontFamily: "New York, ui-serif, serif"
    fontSize: "9pt" # max(9, 9u)
    fontWeight: 500
    letterSpacing: "0.1pt" # 0.1u
  bezel-inscription:
    fontFamily: "New York, ui-serif, serif"
    fontSize: "9pt" # max(9, 9u)
    fontWeight: 600
    letterSpacing: "0.1pt"
  plate-engraving:
    fontFamily: "New York, ui-serif, serif"
    fontSize: "11.5pt" # barograph, at the 350 x 364pt canvas
    fontWeight: 600
    letterSpacing: "0.5pt"
  housing-inscription:
    fontFamily: "New York, ui-serif, serif"
    fontSize: "11.5pt"
    fontWeight: 600
    letterSpacing: "0.6pt"
  chart-label:
    fontFamily: "New York, ui-serif, serif"
    fontSize: "9.5pt" # on the 350 x 364pt canvas, set at max(9.5, 9 / scale) so it never renders under 9pt
    fontWeight: 500
  accessory-headline:
    fontFamily: "SF Pro" # system text style .headline, Dynamic Type
    fontSize: "17pt"
    fontWeight: 600
    fontFeature: "tnum"
  accessory-detail:
    fontFamily: "SF Pro" # system text style .caption, minimum scale 0.8
    fontSize: "12pt"
    fontWeight: 400
rounded:
  tile: "21.3pt" # 0.13 x side, continuous corner; app and gallery tiles only, the Home Screen applies its own mask
  counter-frame: "5.5pt" # 0.15 x counter height (PSI counter); 2.0pt on the AQI counter
  counter-window: "2.2pt" # 0.4 x frame radius
  counter-frame-large: "12.6pt" # 0.15 x the 84pt barograph PSI counter; 6.6pt on its AQI counter
spacing:
  unit: "0.965pt" # u = side / 170; 1pt at the 170pt authoring size, 0.965pt on the 164pt reference widget
components:
  instrument-small:
    size: "164pt"
    rounded: "{rounded.tile}"
  counter-psi:
    backgroundColor: "{colors.counter-window}"
    textColor: "{colors.figure-white}"
    typography: "{typography.counter-psi}"
    rounded: "{rounded.counter-frame}"
    width: "92.8pt"
    height: "37pt"
  counter-psi-night:
    backgroundColor: "{colors.counter-window}"
    textColor: "{colors.radium-lume}"
    typography: "{typography.counter-psi}"
    rounded: "{rounded.counter-frame}"
  counter-psi-accented:
    textColor: "{colors.accent-amber}"
    typography: "{typography.counter-psi}"
    rounded: "{rounded.counter-frame}"
  counter-aqi:
    backgroundColor: "{colors.counter-window}"
    textColor: "{colors.figure-white}"
    typography: "{typography.counter-aqi}"
    width: "34.4pt"
    height: "13.4pt"
  legend:
    textColor: "{colors.engraving-ink}"
    typography: "{typography.engraving}"
  legend-night:
    textColor: "{colors.radium-lume}"
    typography: "{typography.engraving}"
  time-stale:
    textColor: "{colors.stale-rust}"
    typography: "{typography.engraving}"
  time-stale-night:
    textColor: "{colors.stale-ember}"
    typography: "{typography.engraving}"
  bezel-inscription:
    textColor: "{colors.bezel-ink}"
    typography: "{typography.bezel-inscription}"
  bezel-inscription-night:
    textColor: "{colors.radium-lume}"
    typography: "{typography.bezel-inscription}"
  needle-day:
    backgroundColor: "{colors.blued-steel-tip}"
    width: "3.7pt"
  needle-night:
    backgroundColor: "{colors.gunmetal-needle-tip}"
    width: "3.7pt"
  hub:
    backgroundColor: "{colors.brass}"
    size: "9.3pt"
  accessory-rectangular:
    typography: "{typography.accessory-headline}"
  instrument-large:
    width: "350pt"
    height: "364pt"
  counter-psi-large:
    backgroundColor: "{colors.counter-window}"
    textColor: "{colors.figure-white}"
    typography: "{typography.counter-psi-large}"
    rounded: "{rounded.counter-frame-large}"
    width: "195.1pt"
    height: "84pt"
  counter-aqi-large:
    backgroundColor: "{colors.counter-window}"
    textColor: "{colors.figure-white}"
    typography: "{typography.counter-aqi-large}"
    width: "102.2pt"
    height: "44pt"
  plate-legend:
    textColor: "{colors.plate-cream}"
    typography: "{typography.plate-engraving}"
  plate-legend-night:
    textColor: "{colors.radium-lume}"
    typography: "{typography.plate-engraving}"
  plate-stale:
    textColor: "{colors.stale-ember-light}"
    typography: "{typography.plate-engraving}"
  plate-stale-night:
    textColor: "{colors.stale-ember}"
    typography: "{typography.plate-engraving}"
  housing-inscription:
    textColor: "{colors.bezel-ink}"
    typography: "{typography.housing-inscription}"
  housing-inscription-night:
    textColor: "{colors.radium-lume}"
    typography: "{typography.housing-inscription}"
  chart-label:
    textColor: "{colors.engraving-ink}"
    typography: "{typography.chart-label}"
  chart-label-night:
    textColor: "{colors.radium-lume}"
    typography: "{typography.chart-label}"
  trace-day:
    backgroundColor: "{colors.trace-ink}"
    height: "1.05pt"
  trace-night:
    backgroundColor: "{colors.radium-lume}"
    height: "1.4pt"
  pen-arm:
    width: "31pt"
    height: "7.5pt"
---

# Design System: psimeter

## Overview

**Creative North Star: "The Brass Aneroid"**

psimeter is one instrument world in two Home Screen sizes. The systemSmall widget is an aneroid, a 164 pt square on the reference iPhone 17 Pro. A gunmetal plate with four slotted screws holds a knurled brass bezel and a round dial. The dial carries a shallow five-band enamel arc with one needle, a wide three-wheel roller counter for the 24-hour PSI, a small counter for the WAQI AQI, and engraved legends. Every mark on the face is metal, enamel, glass, a tick or engraved text. There are no buttons, icons, chips or cards. On the Lock Screen, where the materials cannot survive vibrant rendering, the accessories drop to plain system type and make no attempt to imitate brass.

The systemLarge widget is a barograph, 350 × 364 pt on the same phone. The same gunmetal plate, its four brass screws now seated in counterbores, carries a brass drum housing across its upper half. Through the housing window a paper drum shows the last 24 hours of PSI as a pen trace over faint band zones, and a brass pen arm's nib marks the current reading at the right edge of the chart, which is now. Below the drum the plate holds the PSI and AQI roller counters in grained brass frames, and engraving for the legends, the four regional PSIs and the time. The barograph adds the trace and nothing else: the same materials, light and type voices as the aneroid.

The world changes material with the appearance. It never inverts. Day is grained silver, black engraving and a blued-steel needle; on the barograph it is warm chart paper and violet-black pen ink. Night is black lacquer with radium lume: legends, ticks, wheel figures and the barograph's trace glow, the needle turns gunmetal with a lume strip, the paper turns black under a lume grid, and the brass becomes a tone-mapped, darker copy of the day brass. A tinted or clear Home Screen gets a third finish, an open line drawing that keeps the engraved structure and puts the needle, the pen, the trace and the figures in the accent group.

The reading is the product, so the figures carry it and the band supports it. Figures never take the band colour. The band shows only as the needle's position over the enamel, or the pen's position over the chart zones, where the current band is the brightest. The aneroid face is dense, about a dozen engraved strings on 164 pt, and it holds together with two type voices, one light source and a 9 pt floor.

**Key Characteristics:**
- Two instruments in one world: the systemSmall aneroid, drawn in code over three raster textures on a 170 pt grid, and the systemLarge barograph, drawn in code over raster materials on a 350 × 364 pt canvas.
- Exact figures on roller wheels; the band arc and the 24-hour trace are supporting cast.
- A material switch for night (lacquer, black paper, lume, dimmed brass), never an inverted palette.
- Engraved serif for every legend and Archivo Black figures for the two readings. Nothing else is set on either face.
- Light from the upper left everywhere: dial sheen, crystal glare, plate bevel, screw bores, needle, hub, pen and counter shadows.
- Honest states drawn in the material: blank wheels for missing data, a rust or ember stale mark, a pegged needle, an empty chart engraved `TREND · OFFLINE`.

### As built against the direction contract

The header comment of `Shared/Instrument/InstrumentView.swift` holds the contract (seed 95d203dd, Brass Aneroid, layout C). Where the build departs from it, the build is the record.

- The band arc sweeps 126 degrees, not 160. PSI 0 sits at 153 degrees, 200 points straight up, 400 sits at 27 degrees.
- The systemSmall face measures 164 pt on the reference device. Geometry is authored at 170 pt and scales by u = side / 170.
- Engraved text has a 9 pt floor, set by the build brief. The contract names no size.
- The time legend follows an arc along the lower inside edge of the dial (radius 58.05u). The contract placed it as a line under the AQI counter.
- "Only the current band is saturated" lands softly. Non-current segments mix 22% toward mid-grey by day and 15% toward black by night, so all five still read as coloured. The current segment wins on full enamel and a brighter glaze.
- The blued-steel needle is day only. At night the blade is gunmetal with a lume strip on its outer 58%.
- The night bezel is `BezelTileNight`, the day tile run through `scripts/night-bezel.swift`. It reads as dark bronze, not the bright brass of the night comp.
- Scale numerals are 0, 100, 200, 300 and 400, set radially. The comp's upright 50 numeral was dropped to hold the type floor; its major tick stays.
- A missing WAQI token engraves `AQI · UNAVAILABLE`. The build brief asked for `NO TOKEN`.
- The day stale mark on the silver dial is a dark rust, not the vermilion enamel the build brief asked for.

### As built against the barograph approval

The record is `.impeccable/surfaces/shared-instrument-barograph-swift.md`: layout A, approved in chat on 2026-10-15, with `.impeccable/mocks/large/large-a-day.png` as the day spec and `large-c-night.png` as the night spec. The source is `Shared/Instrument/Barograph.swift`.

- At night only the current band's zone is lit. The night comp paints all five zones strongly; the record ruled that out.
- Engraving on the day plate is Plate Cream. The day comp cuts it in black, which measures about 1.2:1 on the gunmetal.
- The stale mark on the day plate is Light Ember, not the Stale Rust of the silver dial.
- The plate raster has no screws. Four screw rasters sit in counterbores drawn in code.
- The trend failure the record left open is built: zones, value scale and grid stay, the hour labels and the trace go, and `TREND · <FAILURE>` is engraved at the chart centre. The pen still marks the current reading.
- The hour labels come from the live data window. The comp's fixed 09 to 06 axis was a sample.

## Colors

The palette is a set of real materials: brass, blued steel, five vitreous enamels, black engraving, black lacquer, chart paper, pen ink and radium lume. Much of the metal is raster (the aneroid's bezel ring and silver dial grain; the barograph's plate, screws, drum housing, paper, glass, pen arm and counter brass); the colours below are the ones the code paints.

### Primary
- **Counter Brass** (#cca352), with **Brass Highlight** (#f7e09e) and **Brass Shadow** (#8c6629). The aneroid's roller-counter frames and the hub cap. A counter frame runs a vertical gradient from highlight at the top through brass (30%) to shadow (72%) and back up to a lighter brass lip (#c79e4f) at the bottom, so it reads as a turned rim. The hub uses the same family on a diagonal from upper left (#edcc80, #c79e4f, #8c692e) and multiplies it by 0.78 at night. The bezel ring's brass lives in the raster tile and has no token. The barograph's counter frames swap the gradient for the `BrassGrain` raster (`BrassGrainNight` at night) under a white 20% to clear to black 28% shade; see Components.

### Secondary
- **Blued Steel** (#0a1f45 at the root to #337adb at the tip). The day needle, a linear gradient from hub to tip with a 22% white bevel on one half of the blade. It is the only cool metal on the face and the only part that moves across it.

### Tertiary
- **Good Enamel Green** (#338c45): PSI 0 to 50.
- **Moderate Enamel Blue** (#306bbd): PSI 51 to 100.
- **Unhealthy Vermilion** (#eb4a21): PSI 101 to 200.
- **Very Unhealthy Oxblood** (#8c2b29): PSI 201 to 300.
- **Hazardous Maroon** (#6e1c2b): PSI 301 and up.
- **Lamp Warmth** (#ff9938). Never painted on its own. At night the current band mixes 22% toward it, so the lit segment burns warmer than the rest. The barograph's night chart zones all take the warmed enamel.

The AQI band table in `Shared/Instrument/Bands.swift` also defines an ochre (#d9a829) and an amber (#e67821). Nothing draws them. The arc and the chart are PSI only, and the AQI table only supplies band names to VoiceOver, so they are not tokens.

### Neutral
- **Engraver's Black** (#1a1a1c): engraving on the silver dial (day legends, scale numerals, ticks and the fresh time) and the value and hour labels on the day chart paper.
- **Plate Cream** (#e8e0cc): day engraving cut into the barograph's gunmetal plate: `PSI · NEA 24H`, `AQI · WAQI`, the regional foot and the fresh time. Each string has a black 60% copy 0.4 pt left and 0.6 pt up, the shaded upper wall of the cut. It measures about 9.9 to 11.4:1 against the plate behind it.
- **Bezel Umber** (#33210a) over **Relief Glint** (#fff0bd at 55%): day inscriptions cut into brass, the aneroid's bezel and the barograph's housing bar. The glint is a second copy of the letters drawn lower (0.55u on the aneroid, 0.6 pt on the barograph), the lit lower lip of a cut letter.
- **Chart Blue-Grey** (#57668a): the day chart's rules and axes. Major rules draw at 42% and 0.6 pt, minor rules at 14% and 0.4 pt, the two axes at 60% and 0.7 pt.
- **Violet Ink** (#261a45): the day pen trace. See The Pen Ink Rule.
- **Wheel White** (#f7f7f2): day figures on the roller wheels.
- **Drum Crest** (#454545) and **Drum Shadow** (#050505): the wheel cylinder, a six-stop vertical gradient, darkest at both ends and brightest just above centre.
- **Counter Well** (#0f0d08): the slot behind the wheels, seen as the dividers between drums.
- **Radium Lume** (#ccedc2): every night ink. Legends, numerals, ticks, bezel and housing inscriptions, plate engraving, wheel figures and the needle strip all glow in their own colour at 60% (85% on the needle). On the night chart it is also the grid (at the day opacities) and the trace, which glows at 80%.
- **Lacquer Sheen** (#1c1c1c) to **Black Lacquer** (#040404): the night dial, a radial gradient lit from the upper left.
- **Gunmetal Needle** (#212424 at the root to #424745 at the tip): the night blade under its lume strip.
- **Stale Rust** (#70180a) by day and **Stale Ember** (#ff6b42) by night: the stale time mark on the aneroid's dial and nothing else.
- **Light Ember** (#ff9e7a) by day and **Stale Ember** (#ff6b42) by night: the stale time mark on the barograph's gunmetal plate and nothing else. Light Ember measures 7.5:1 against the day plate; Stale Ember measures 6.5:1 against the night plate.
- **Accented Slate** (#262930): the flat plate of the accented finish, on both sizes. **Accent Stand-in Amber** (#ffc761) colours the needle and figures in the app gallery's simulation of accented mode. On a device the system tint replaces it.

### Named Rules
**The One Lit Band Rule.** The segment holding the current PSI draws at full enamel under a 38% white glaze. The other four are muted (22% toward mid-grey by day, 15% toward black by night) under a 22% glaze. With no PSI reading, no segment is lit. The barograph's chart zones obey the same rule: the zone holding the current PSI fills at 30% of its enamel and every other zone at 12% by day and 8.5% at night; the accented finish uses white at 14% and 3%. The zone is lit by the current reading, not by where the trace has been.

**The Figures Never Take the Band Rule.** Wheel figures stay Wheel White by day and Radium Lume by night at every value. The band shows only as the needle over the enamel, or the pen over the chart zones.

**The Lume Is Night Rule.** Only the night finish glows. The day finish has no glow anywhere, and the stale mark never glows in any finish. Stale is painted, not luminous. The day trace's soft edge is ink bleed, darker than the paper, not a glow.

**The Ink Follows the Ground Rule.** Day engraving takes its ink from the ground it is cut into, and night switches every ground to lume. Silver dial and chart paper take Engraver's Black. Brass (the aneroid bezel, the barograph housing bar) takes Bezel Umber over Relief Glint. The gunmetal plate takes Plate Cream, about 9.9 to 11.4:1. The stale mark follows the ground too: Stale Rust on silver, Light Ember on the day plate (7.5:1), Stale Ember on the night plate (6.5:1). Engraver's Black and Stale Rust never go on the plate.

**The Pen Ink Rule.** The day trace is ink from a pen, never a clean vector line. Each hourly segment is cut into steps of 1.3 pt or a little more, and every step except the segment's end is offset up to 0.28 pt along the normal, so the line still passes through every hourly reading. The offsets come from a generator seeded by the data, so the same 24 hours always draws the same line. The line is Violet Ink at 1.05 pt with round caps and joins, over a 2.3 pt bleed of the same ink at 28%, blurred 0.5 pt. At night the trace is a smooth 1.4 pt lume line with an 80% lume glow, radius 2 pt.

## Typography

**Display Font:** Archivo Black (SIL OFL 1.1), on the wheel figures only. The file is `Shared/Fonts/ArchivoBlack-Regular.ttf`, with its licence beside it, and both the app and the widget extension register it through `UIAppFonts`.
**Label Font:** New York, the iOS system serif
**Lock Screen:** SF Pro through system text styles

**Character:** An engraved serif for everything the maker cut into the dial, the plate, the brass and the chart, and a black-weight grotesque for the figures printed on the wheels. The two never swap jobs.

### Hierarchy
- **Display, PSI wheels** (Archivo Black, 30.7 pt on the 164 pt aneroid, 60 pt on the barograph): the 24-hour PSI. The face is sized by its figure height, not its em: the size is the drum height × 0.703 / 0.712, so a digit, which stands 0.712 em tall with overshoot, fills 70.3% of its drum. It is set at a fixed size with no Dynamic Type. All ten digits share one 0.667 em advance, so the figures are tabular without a feature.
- **Headline, AQI wheels** (Archivo Black, 11.1 pt on the aneroid, 31.4 pt on the barograph): the WAQI AQI. Same formula on the smaller counter, floored at 9 pt.
- **Label, engraving** (500, 9 pt, 0.1u tracking, capitals): the aneroid's legends `PSI · 24H · CENTRAL` and `AQI · WAQI`, the scale numerals, the time and the stale mark. The size is max(9, 9u), so it grows only when the instrument is drawn larger than 170 pt, as in the app.
- **Label strong, bezel inscription** (600, 9 pt, 0.1u tracking): `N 126`, `E 173`, `S 159`, `W 197`, with W and E turned to run along the ring.
- **Barograph plate engraving** (600, 11.5 pt, 0.5 pt tracking): `PSI · NEA 24H`, `AQI · WAQI`, the regional foot `N 126   S 159   E 173   W 197` and the time or stale mark. The housing inscription `PSI · 24H · CENTRAL` uses the same size and weight at 0.6 pt tracking.
- **Barograph chart labels** (500, 9.5 pt on the canvas, never under 9 pt on screen): the value scale and the hour labels. The trend failure note sets the same face at 11 pt. See The Counter-Scaled Label Rule.
- **Lock Screen** (`.headline` with tabular digits for `PSI 183 · AQI 168`, `.caption` at a 0.8 minimum scale for `Central · Unhealthy · 20:30`). Dynamic Type applies here and nowhere on either instrument face.

Leading zeros on the wheels draw at 30% opacity, so 42 reads as a dim 0 followed by a full 4 and 2.

### Named Rules
**The Engraver's Floor Rule.** Engraved text never drops below 9 pt. When space runs out, drop scale numerals first (the 50 already went), then shorten the legend. Never shrink. The floor sits two points under the iOS 11 pt guidance and holds only for tertiary engraving on the fixed-art face. App UI stays at 11 pt or above.

**The Two Voices Rule.** Each face has two type voices. The engraved serif sets every legend, numeral, time and inscription; Archivo Black sets the two readings on the wheels. A third voice, or the serif on a wheel, breaks the instrument.

**The Counter-Scaled Label Rule.** The barograph face scales as one piece (see Layout), so text set at s pt on the canvas renders at s × scale. Each chart label is set at max(s, 9 / scale) on the canvas, so it renders at s × scale or at 9 pt, whichever is larger. The 9.5 pt labels render at 9.9 pt at 364 × 382, 9.5 pt at the 350 × 364 reference and 9.2 pt at 338 × 354, and hold at exactly 9 pt at 329 × 345 and 292 × 311. Only the size counter-scales. The labels stay anchored where the canvas puts them, so at 292 × 311 they stand 1.14 times their authored proportion. They still fit: the 3-hour labels clear one another and the 3-digit value labels clear the paper's edge, so nothing is dropped. The 11 pt trend note goes through the same floor but never needs it at a table size (9.2 pt at 292 × 311). The 11.5 pt plate and housing engraving have no floor in code; they render at 9.6 pt at 292 × 311.

## Layout

Both widgets draw full bleed with WidgetKit content margins disabled.

### Aneroid (systemSmall)

The aneroid is one square. Every measure is in u = side / 170. On the 164 pt reference widget u is 0.965 pt; in the app the same view grows to 360 pt wide. The horizontal centre is 0.498 of the side throughout. Vertical positions are in u from the top edge.

| Element | Position | Size |
| --- | --- | --- |
| Dial | centre at (0.498, 0.480) of the side | radius 0.389 of the side |
| Bezel inscriptions | on a ring 0.4165 of the side from the dial centre | 9 pt |
| Arc centre | y 78.6u | arc radius 45.4u, band 5.6u wide |
| Ticks | from the band's outer edge plus 0.7u | major 3.5u long at 1.1u, minor 2.3u at 0.8u, every 25 PSI |
| Scale numerals | tick end plus 1.2u plus 0.36 of the type size | 0, 100, 200, 300, 400 |
| Hub (needle pivot) | y 55u | radius 4.8u |
| PSI legend | y 65.3u | 9 pt |
| PSI counter | centre y 89.35u | 38.35u tall, about 96u wide |
| AQI legend | y 113.4u | 9 pt |
| AQI counter | centre y 125.22u | 13.89u tall, about 36u wide |
| Time | on an arc of radius 58.05u below the dial centre | 9 pt |

Major ticks fall at 0, 50, 100, 200, 300 and 400. The value-to-angle map is 153 degrees minus 126 degrees times PSI / 400. The needle pivots 23.6u above the arc centre, so it is eccentric to the scale. Its blade stretches from a 40u reference length so the tip lands 0.8u inside the tick ends at every value.

The widget side follows the device width (the gallery's table): 170 pt at 430 pt and wider, 169 at 414, 164 at 402, 158 at 390, 155 at 375, and 141 below that. Type floors at 9 pt while the geometry keeps scaling, so below 170 pt the engraving grows relative to the dial; at 141 pt it is 1.2 times its authored proportion. Only the 164 pt size has been captured.

In the app and the gallery, the tile clips to a continuous corner of 0.13 of the side. On the Home Screen the system mask clips it.

### Barograph (systemLarge)

The barograph is laid out in points on a 350 × 364 pt canvas, the systemLarge size on the 402 pt-wide reference phone. The whole face scales uniformly by the smaller of width / 350 and height / 364 and sits centred in the widget, so type scales with it, except that the chart labels never drop below 9 pt (see The Counter-Scaled Label Rule). The plate behind it fills the widget on its own. All positions are in points from the canvas's top left.

| Element | Position | Size |
| --- | --- | --- |
| Plate screws | centres (26, 18.5), (324, 18.5), (26, 344), (324, 344) | 17 pt heads in 20 pt counterbores |
| Drum housing | origin (7, 34) | 336 × 182 |
| Housing inscription | centre (175, 46) | 11.5 pt |
| Chart window | origin (37.6, 59.6), set by the housing art at 9.11% to 90.95% across and 14.06% to 85.34% down | 275.0 × 129.7 |
| Plot | the window inset 26 left, 7 top, 13 right, 26 bottom: origin (63.6, 66.6) | 236.0 × 103.7 |
| Value labels | trailing edge at x 59.6, on their rules | 9.5 pt, never under 9 pt on screen |
| Hour labels | centred at y 179.3, on their rules | 9.5 pt, never under 9 pt on screen |
| Pen arm | nib at (299.6, the current PSI's height), arm running right over the end cap | 31 × 7.5, nib at 49.2% of its height |
| PSI legend | centre (121, 233) | 11.5 pt |
| PSI counter | centre (121, 285.5) | 84 tall, about 195 wide |
| AQI legend | centre (281, 251) | 11.5 pt |
| AQI counter | centre (281, 286) | 44 tall, about 102 wide |
| Regional foot | leading edge at (46, 343), three spaces between regions | 11.5 pt |
| Time or stale mark | trailing edge at (304, 343) | 11.5 pt |

The chart's value scale fits the data. Its top is the first of 300, 400, 500, 600, 800 and 1000 that clears the higher of the 24-hour peak and the current reading by at least 25; a calm day reads 0 to 300. Up to a 400 top, major rules fall every 50 and minor rules every 10; above it, every 100 and 25. Every major rule is labelled. Zero is the hour axis and the top of the scale is the plot's edge, so neither has a rule or a label.

The hour axis is built from the live data window, not from the clock. The window is the 24 hours ending at the newest hourly reading, which sits on the right edge of the plot under the pen nib. Each reading sits at its own hour. Hourly rules step across the window from its start, which is the value axis itself; rules on Singapore hours divisible by 3 are major and carry a two-digit label (`21`, `00`, `03`). The labels therefore move with the data: a window ending at 10:00 reads `12` to `09`, one ending at 20:00 reads `21` to `18`. With no trend, the same 24 divisions are spaced evenly and carry no labels.

The size table in the gallery (Apple's figures) gives 364 × 382 at 430 pt and wider, 360 × 379 at 414, 350 × 364 at 402, 338 × 354 at 390, 329 × 345 at 375 and 292 × 311 below that. 350 × 364 has been measured on a real iPhone 17 Pro Home Screen. Real Home Screens don't all match the table: the 17e, 390 pt wide, measures about 342 × 357, and the 17 Pro Max, 440 pt wide, about 377 × 393, against the table's 338 × 354 and 364 × 382. The chart labels render at 9.3 and 10.2 pt there. The table's sizes have been captured as gallery tiles: 364 × 382 on the 17 Pro Max, 338 × 354 on the 17e, 329 × 345 on the 13 mini and the SE (3rd generation), and 292 × 311 with `scripts/capture-large.sh <udid> <tag> 320`, because no iOS 27 simulator is narrower than 375 pt. The label floor is computed from the widget's actual size, so it also holds at sizes the table doesn't list. In the gallery the tile clips to a continuous corner of 0.064 of its width; on the Home Screen the system shape clips it.

### Named Rules
**The 170 Grid Rule.** Author every aneroid measure in u = side / 170 and let the view scale. Only type has a floor.

**The 350 Canvas Rule.** Author every barograph measure in points on the 350 × 364 canvas and scale the finished face as one piece, never element by element. The one exception is the chart labels' type size, which counter-scales under The Counter-Scaled Label Rule; their positions still scale with the face. The chart window is measured off the housing art, and the plot, pen and chart labels are measured off the window, so the chart always sits inside the drum it is drawn on.

**The Raster Opening Rule.** The dial is a circle of radius 0.389 of the side at (0.498, 0.480). That matches the black opening in the `BezelTile` artwork, so the code dial covers it exactly. Move the dial and the plate's black shows.

## Elevation & Depth

There is no UI elevation. Depth is physical. On the aneroid: a raster plate, a dial sunk under the bezel, raised counters, a needle and hub standing off the dial, and a crystal over all of it. The draw order from the back is plate, dial print (face, enamel, ticks, numerals, legends, bezel inscriptions), PSI counter, AQI counter, needle, hub, crystal.

On the barograph: a bevelled raster plate, screws seated in counterbores, a paper drum and the pen that writes on it behind glass inside a brass housing, the pen arm's collar resting on the housing's end cap, and raised counters on the plate. The draw order from the back is plate and bevel, screws, chart paper (paper, zones, grid, labels), trace, drum shade, pen arm inside the window, drum glass, housing and its inscription, pen arm outside the window (the collar on the end cap), plate engraving, PSI counter, AQI counter. The accented finish has no glass, so its pen rule draws whole over the housing outline.

### Shadow Vocabulary
- **Bezel lip** (6u stroke blurred 2.4u, black 55% by day and 90% at night, on a ring offset 0.6u left and 1.1u up): shades the dial's upper-left inner edge, as the bezel would under an upper-left lamp.
- **Needle cast** (radius 0.9u, offset 0.9u right and 1.4u down, black 38% by day and 60% at night, none in the accented finish).
- **Hub drop** (a disc offset 0.7u right and 1.2u down, blurred 1u, black 50%).
- **Counter frame** (radius 1.2u, offset 0.3u right and 1.0u down, black 50% by day and 80% at night).
- **Counter well** (an inner stroke of 1.6u blurred 1u at black 80%), plus a split-glass glint over the top half (white 14% fading to 3% at 46%, cut hard at 48%).
- **Drum wrap** (black 75% fading to clear over the top 20% of each wheel, clear to black 80% over the bottom 20%): figures roll over the curve of the wheel.
- **Lume glow** (radius 1.6u on text, 1.2u on ticks, 2u on the needle strip; Radium Lume at 60%, 85% on the needle): night only.
- **Engraving relief** (a copy of the bezel letters 0.55u lower in Relief Glint, no blur): day bezel only. The barograph's housing inscription uses the same relief 0.6 pt lower.

Barograph additions, in points:
- **Plate bevel** (a 1.5 pt stroke of the widget's container shape, inset 0.75 pt): white at 42% by day and 24% at night on the upper-left half, black 60% on the lower-right half, the two meeting along the diagonal between 47% and 53%. It follows whatever corner the system gives the widget. The accented plate has no bevel.
- **Counterbore** (a 20 pt bore under each 17 pt screw head): a radial fill from black 85% just up and left of centre to 55% at the rim, and a 0.6 pt lit lip on the lower-right wall, white 26% by day and 14% at night. The head itself casts black 60% at radius 0.7, offset 0.8 right and 0.8 down.
- **Plate cut** (a black 60% copy of each day plate string, 0.4 left and 0.6 up): the shaded upper wall of letters cut into the plate. Day only.
- **Pen cast** (radius 0.6, offset 0.3 right and 0.8 down, black 40% by day and 60% at night).
- **Drum shade** (multiplied over the window by day only): a cosine falloff from full at the centre to 55% at the top and bottom edges, and to 85% at the two ends, so the paper reads as a cylinder.
- **Drum glass** (the `DrumGlass` highlights, screen-blended at 60% by day and 45% at night, lifted 12 pt and faded out between 80% and 86% of the window height). The accented finish has no glass.
- **Trace bleed** (day) and **trace glow** (night): see The Pen Ink Rule.
- **Counter frame** on the barograph uses the same shadow at u = 1.

### Crystal
A glass layer clipped to the dial. It has an inner shade ring (4.4u wide at the dial radius minus 2.6u, blurred 1.6u, black 24% to 2% from top to bottom by day, white 9% to 2% at night), a radial glare at the upper left (white 16% by day, 10% at night, reaching 0.75 of the dial radius), and a crescent highlight on the upper-left rim (the even-odd gap between the dial and a 0.972 circle shifted down-right, white 85% fading out by 75% of the way across).

### Materials
| Material | Source | Notes |
| --- | --- | --- |
| `BezelTile` | raster, from `.impeccable/assets/bezel-tile.png` | gunmetal plate, four slotted screws, knurled brass ring, black centre opening; 1024 px |
| `BezelTileNight` | raster, generated from the day tile by `scripts/night-bezel.swift` at its defaults | tone curve (0 to 0, 0.25 to 0.13, 0.5 to 0.30, 0.75 to 0.52, 1 to 0.88), then 72% saturation, no hue shift |
| `DialSilver` | raster, from `.impeccable/assets/dial-silver.png` | grained silver clipped to the dial; code adds a radial sheen from white 16% at the upper left to black 14% at the rim |
| `AppIcon` | raster, the catalog copy is `.impeccable/assets/app-icon-v2.png` | a silver aneroid with brass bezel, enamel arc and a small counter on gunmetal |
| Everything else | code | lacquer, enamel and glaze, ticks, numerals, legends, inscriptions, needle, hub, counters, crystal, lume, the accented line drawing |

The barograph's materials, all in `Shared/Assets.xcassets`, with sources and prompts in `.impeccable/assets/large/`:

| Material | Source | Notes |
| --- | --- | --- |
| `PlateDay`, `PlateNight` | raster, both written from one screwless plate by `scripts/plate-tones.swift` | brushed gunmetal with a bevelled rim, 1024 px, aspect-filled behind the face; night is the darker curve (top at 0.85) at 72% saturation |
| `Screw`, `ScrewNight` | raster | slotted brass heads, drawn at 17 pt in code-drawn counterbores |
| `DrumHousing`, `DrumHousingNight` | raster, keyed by `scripts/chroma-key.swift` | brass bars with beaded rope trim and four small slotted screws, turned end caps, the window keyed out; 1008 × 546 px |
| `PaperDay`, `PaperNight` | raster | warm white and black chart paper, 840 px, drawn as a 275 pt square centred on the window and clipped to it |
| `DrumGlass` | raster | highlights on black, for screen blending |
| `PenArm`, `PenArmNight` | raster, keyed | turned brass pivot boss, slim rod and steel nib; 214 × 52 px |
| `BrassGrain`, `BrassGrainNight` | raster | an 896 × 44 px strip of brushed brass, tiled down the barograph's counter frames |
| Everything else | code | the bevel, counterbores, zones, grid, labels, trace, drum shade, engraving, counters and figures, the accented line drawing |

The night housing, pen arm and grain share the day art's alpha and are tone-mapped copies of it. The tools: `scripts/chroma-key.swift` keys pure #00FF00 out of generated art (alpha ramps from opaque at a greenness of 0.12 to clear at 0.38, with despill and an optional crop); `scripts/brass-tone.swift` rotates hue and sets saturation so brass from different sources matches; `scripts/night-bezel.swift` tone-maps day art to night and now takes saturation, ceiling and hue arguments (defaults 0.72, 0.88, none); `scripts/plate-tones.swift` writes both plates from one source; `scripts/large-assets.py` installs each file into the catalog at a fixed pixel size.

### Named Rules
**The One Lamp Rule.** Light comes from the upper left. Highlights sit up and left (dial sheen, crystal glare and crescent, hub cap gradient, plate bevel); shadows fall down and right (needle, hub, counters, screw heads, pen arm). Recesses invert: a counterbore lights its lower-right wall and a letter cut into the plate shades its upper-left wall. A new part lit from anywhere else is wrong.

**The Glass Over Everything Rule.** On the aneroid, the crystal is the top layer, and the needle, hub and counters sit under its glare. On the barograph the glass covers everything inside the drum window: the paper, zones, grid, labels, trace, wrap shading and the pen arm all sit under its glare. The glass is clipped to the window, so the housing, the pen arm's collar on the end cap, the engraving and the counters stay unglazed above it. The accented finish has no glass on either size.

**The Raster Material, Code Data Rule.** A raster may carry a material and never a value. Brass, gunmetal, paper, glass, screws and the pen arm can be generated art; every zone, rule, label, trace point, figure and engraved string is drawn in code from the reading. A raster that moves with the data, like the pen arm, is placed by code and carries nothing that would need to change with it.

## Shapes

The form language is instrument geometry. Circles make the dial, the bezel ring and the hub. Annular sectors with square ends make the enamel bands, with 1.5u gaps between them. Ticks are radial strokes with butt caps. The needle is a tapered blade, 3.8u wide at the root, 0.72u at the tip, with a 3u tail narrowing to 2u. Counters are continuous-corner rounded rectangles: frame radius 0.15 of the counter height, inner bevel 0.75 of that, window 0.4 of it. The tile is a square with a 0.13-of-side continuous corner where the app draws it. There are no pills, chips or sharp-cornered boxes anywhere on the aneroid face.

The barograph adds the rectilinear forms of a drum recorder. The chart window is a square-cornered opening between the housing's bars and end caps, and the chart paper is clipped hard to it, as paper on a drum is. Screws and counterbores are circles. The counters keep their continuous corners at 0.15 of the height, but the rim is 1.9 times as thick (12.4% of the height), so the brass reads as a heavy cast frame rather than a turned bezel. The plate's corner is never drawn in code; the bevel strokes the system's container shape, so it follows whatever radius the Home Screen applies. The trace has round caps and joins. In the accented finish the housing becomes a 6 pt rounded outline with its bars and window as plain rectangles, and the pen becomes a 1.2 pt rule.

## Components

### Roller counter
A brass-framed window of three black wheels, one figure per wheel. Both sizes share one component, `Shared/Instrument/RollerCounter.swift`.
- **Shape:** frame radius 0.15 of the height, continuous; rim 6.5% of the height times the rim scale (1 on the aneroid, 1.9 on the barograph), inset 1.5%; drum width 0.86 of the drum height; dividers max(0.8 pt, 4.5% of the height).
- **Frame:** an outer edge stroked 0.5u from white 70% at the top to black 50% at the bottom; a sunken bevel ring half the rim wide, dark brass at the top (#5c4017) through #9e7836 to pale brass at the bottom (#fae6a8); a 0.45u black 70% line where the frame meets the window.
- **Brass:** with no grain (the aneroid), the frame is the Counter Brass gradient, and at night a black 22% wash dims it. With grain (the barograph), the frame is the `BrassGrain` raster stacked down the frame in full-width strips at the strip's own aspect, every other strip flipped vertically so the seams match, under a shade from white 20% at the top through clear at 35% to black 28% at the bottom. At night the grain is `BrassGrainNight` and a black 42% overlay darkens the bevel ring instead of the wash.
- **Color:** Counter Well slot, Drum Crest to Drum Shadow cylinders. Wheel White figures by day; Radium Lume figures with glow at night.
- **Figures:** Archivo Black at the drum height × 0.703 / 0.712, floored at 9 pt. See Typography.
- **Values:** clamped to 0 through 999, always three wheels, leading zeros at 30% opacity.
- **Missing data:** the wheels stay and the figures go. A blank counter is the drawn state for no reading.
- **Motion:** each wheel changes its figure with a numeric-text content transition keyed to the digit's value, so it rolls up or down, inside a 0.9 s smooth animation. Each drum clips its figure, so the roll happens behind the cylinder shading. With Reduce Motion on, the figure crossfades over 0.3 s (ease in and out) instead.
- **Accented:** the frame becomes a 0.7u white outline at 50%, each drum a 0.5u white outline at 28% with 1u corners, and the figures join the accent group.

### Enamel arc and needle
- **Arc:** five PSI band segments on the 126-degree sweep, lit by The One Lit Band Rule. The glaze is radial across the band: black 18% at the inner edge, clear by 45%, white at 92% (38% on the current band, 22% on the others), white 5% at the outer edge. Each segment has a 0.3u black outline (22% by day, 50% at night). The accented finish drops glaze and outline and uses white at 62% for the current band, 16% for the rest.
- **Ticks:** every 25 PSI, majors at 0, 50, 100, 200, 300 and 400.
- **Needle:** a tapered blade pivoting on the hub, eccentric to the arc. Values above 400 peg it at the end stop; no PSI parks it at 0. Day is Blued Steel with its bevel. Night is gunmetal with a lume strip from 42% of the blade to the tip. Accented puts it in the accent group.
- **Motion:** the needle sweeps, rotation and length together, on a 1.2 s smooth animation keyed to the value. The wheels settle 0.3 s before the needle does. With Reduce Motion on, the needle snaps to its value and the wheel figures crossfade over 0.3 s instead of rolling.
- **Hub:** a brass cap of radius 4.8u with machined rings (alternating white 13% and black 10% every 0.3u), a bevel ring and a dark brass pin (#735424). Night tones the brass to 78%. Accented draws a white outline at 85%.

### Engraved legends and time
- **Legends:** `PSI · 24H · <REGION>` above the PSI counter and `AQI · WAQI` above the AQI counter. On failure the legend names the cause: `UNAVAILABLE` (no WAQI token), `OFFLINE`, or `NO DATA` (an unreadable reply, or the region missing from the report).
- **Time:** the SGT observation time as `HH:MM`, set glyph by glyph along the lower arc in the ink colour, glowing at night.
- **Stale:** once the reading is more than 2 hours old, the time reads `STALE HH:MM`, or `STALE 14 OCT` after 20 hours, in Stale Rust or Stale Ember with no glow. Age alone decides. A reading held from cache after a failed fetch is the last good reading and keeps its plain time until it reaches 2 hours. The timeline adds an entry one minute past the 2-hour mark, so the face goes stale without a fetch.
- **Refresh:** every family reads the same NEA day feed, and one refresh wave sends each source one request. Concurrent fetches in the extension share a single flight, and a body fetched in the last 4 minutes is reused from the extension's UserDefaults. After a clean fetch the timeline reloads in 15 minutes, or one minute past the 2-hour mark if that comes sooner. After any failed fetch (PSI held or missing, AQI offline or unreadable, no trend), or while the reading is already stale, it retries in 5 minutes. A missing WAQI token is not a failure.
- With PSI unavailable, no time is engraved.

### Bezel inscriptions
Four regional PSIs sit on the bezel ring: N at the top, S at the bottom, W and E turned to run along the ring. With PSI unavailable they shrink to bare letters. Day draws Bezel Umber over a Relief Glint copy; night draws lume with glow and no relief. The bezel always shows the four outer regions and the counter shows the chosen region (Central by default), so a chosen outer region appears in both places.

### Instrument states
| State | Wheels | Needle | Legends | Time |
| --- | --- | --- | --- | --- |
| Live | figures | at the value | scale and source | `HH:MM` in ink |
| Stale | figures | at the value | scale and source | `STALE` mark, no glow |
| AQI unavailable | AQI blank | unchanged | `AQI · UNAVAILABLE`, `OFFLINE` or `NO DATA` | unchanged |
| PSI unavailable | PSI blank | parked at 0 | `PSI · OFFLINE` and siblings | none; bezel shows bare letters |
| Pegged, above 400 | the true figure, up to 999 | end stop at 400 | unchanged | unchanged |
| Accented | outlined, figures in the accent group | accent group | white at 85% | white at 85%, stale in white |

The finish follows the environment. Accented rendering mode selects the accented finish; otherwise dark appearance selects night and light selects day. The container background is the matching plate: `BezelTile`, `BezelTileNight`, or flat Accented Slate. The barograph uses the same finish switch with `PlateDay`, `PlateNight` or the same slate.

### Barograph
The systemLarge instrument, in `Shared/Instrument/Barograph.swift`. It shares the palette, the finish switch and the roller counter with the aneroid; the rest is its own.
- **Plate:** `PlateDay` or `PlateNight` behind the face, with the plate bevel, and four screws in counterbores near the corners. Accented: flat Accented Slate with no bevel and no screws.
- **Housing:** `DrumHousing` (`DrumHousingNight` at night) framing the drum, with `PSI · 24H · <REGION>` cut into the top bar: Bezel Umber over Relief Glint by day, lume with a 1.6 pt glow at night, white 85% in the accented finish, where the housing becomes an outline.
- **Chart:** the paper raster clipped to the window; the band zones under The One Lit Band Rule; the grid; the value and hour labels in the ground's ink, with a 1.2 pt glow at night. Then the trace, the drum shade (day only), the pen arm and the drum glass over all of them.
- **Trace:** the configured region's 24-hour PSI, one point per hourly NEA reading in the window, drawn under The Pen Ink Rule. The accented trace is a 1.4 pt line in the accent group.
- **Pen arm:** the `PenArm` raster (`PenArmNight` at night), 31 × 7.5 pt. Its nib sits on the right edge of the plot at the current PSI's height, where the trace ends, and the arm runs right across the end cap. Inside the window the arm lies under the drum glass; the collar on the end cap is outside it and draws over the housing, unglazed. It moves with a 1.2 s smooth animation keyed to the nib's height and snaps to place with Reduce Motion on. With no PSI it parks at 0. Accented: a 1.2 pt rule in the accent group.
- **Plate engraving:** `PSI · NEA 24H` over the PSI counter (the failure legend, such as `PSI · OFFLINE`, when PSI is missing), `AQI · WAQI` or its failure over the AQI counter, the regional foot on the left (bare letters when PSI is missing), and the time or stale mark on the right. Plate Cream with the plate cut by day, lume with a 1.6 pt glow at night, white 85% in the accented finish.
- **Counters:** PSI 84 pt and AQI 44 pt tall, rim scale 1.9, brass grain, drawn at u = 1.
- **Trend data:** NEA's hourly PSI for the current and previous Singapore day, merged and cut to the 24 hours ending at the newest reading. A complete past day is cached and never fetched again.

| State | Chart | Pen | Plate engraving |
| --- | --- | --- | --- |
| Live | zones, labelled grid, trace | nib at the current PSI, meeting the trace | legends, foot, `HH:MM` |
| Stale | unchanged | at the last PSI | `STALE HH:MM`, Light Ember by day, Stale Ember at night, no glow |
| Trend unavailable | zones, value labels and an unlabelled grid; `TREND · OFFLINE` or `TREND · NO DATA` engraved at the centre in 11 pt; no trace | at the current PSI | unchanged |
| PSI unavailable | no zone lit; any cached trend still drawn | parked at 0 | `PSI · OFFLINE` and siblings, bare region letters, no time |
| Accented | white zones (14% current, 3% others), white grid, accent trace, no paper or glass | accent rule | white 85%, stale in white |

### Aged wear
Edit Widget offers a second parameter, Wear, with Polished (the default) and Aged. It applies to systemSmall and systemLarge; the accessories ignore it. `Palette.of(finish, wear)` is a table keyed by finish and wear, and each entry names its raster materials, so no view branches on wear.

What changes:
- Every raster swaps for an aged twin with the same geometry and alpha, made by `scripts/aged-assets.sh` from the polished art: bezel tile and night tile, drum housing and night housing, pen arm, plate, screw, and the counters' brass grain (cut from the aged housing at the polished grain's crop). The day dial becomes a yellowed, foxed paper (`DialAged`); the night lacquer stays. The chart paper becomes `PaperDayAged` and `PaperNightAged`.
- A smudge layer (fingerprints and dust, light on black) screens over the glass at 35% by day and 25% at night. On the aneroid it is an 8-bit grey raster at the dial's drawn size, clipped to the dial and kept out of the counter windows. On the barograph it is pre-composited with the drum glass (its lift, fade and opacity included) into one 8-bit grey raster per finish at the window's size (`DrumGlassAgedDay`, `DrumGlassAgedNight`), so Aged screens a single layer, as Polished does. The aged chart papers store only the band of rows the window shows.
- Each wheel shows its neighbours: the previous digit above and the next below, (d + 9) % 10 and (d + 1) % 10, at 35% (10% on a dimmed leading zero), clipped by the drum and under its shading. Polished wheels do not.
- Ink moves only where the aged ground needs it. At night the bezel lume brightens to #e6ffe0 over a black relief; the plate stale mark lightens to #ffa887 by day and #ff754d at night.

What never changes: the wheel figures (clean, unchipped Archivo Black), the needle, the hub, the enamel, the trace, the type, every position, and the polished finish itself, which captures pixel-identical with and without this option.

Memory: a widget extension runs under a hard memory limit on device, about 30 MB, and the limit applies to its peak while rendering. A render that exceeds it is killed and the widget stays on its redacted placeholder. Decoded rasters dominate that peak, so every added raster or screen-blended layer on the barograph is budgeted against it. `scripts/widget-footprint.sh` reads the extension's peak on the simulator; the simulator adds a fixed overhead and does not enforce the limit, so compare cases rather than reading the totals as device numbers. Measured after one render in a fresh extension: large Polished 36.6 MB by day and night, large Aged 34.0 MB by day and 33.7 MB at night, small Aged 29.4 MB.

Contrast against the ground immediately around each glyph, from the gallery captures (`scripts/measure-contrast.py`):

| Surface | Finish | Element | Polished | Aged |
| --- | --- | --- | --- | --- |
| Aneroid | day | dial legend | 11.1:1 | 12.0:1 |
| Aneroid | day | AQI legend | 9.3:1 | 10.1:1 |
| Aneroid | day | time | 6.8:1 | 6.8:1 |
| Aneroid | day | region on the bezel | 2.1:1 | 2.5:1 |
| Aneroid | day | stale stamp | 4.5:1 | 4.6:1 |
| Aneroid | night | dial legend | 11.6:1 | 11.5:1 |
| Aneroid | night | time | 14.7:1 | 14.7:1 |
| Aneroid | night | region on the bezel | 4.0:1 | 4.1:1 |
| Aneroid | night | stale stamp | 7.2:1 | 7.2:1 |
| Barograph | day | housing inscription | 2.3:1 | 2.7:1 |
| Barograph | day | value and hour labels | 10.2:1, 6.3:1 | 8.3:1, 5.3:1 |
| Barograph | day | plate legend, foot, time | 10.0 to 11.3:1 | 10.3 to 11.2:1 |
| Barograph | day | stale stamp | 7.3:1 | 7.8:1 |
| Barograph | night | housing inscription | 5.1:1 | 5.8:1 |
| Barograph | night | value and hour labels | 13.0:1, 13.3:1 | 8.7:1, 9.1:1 |
| Barograph | night | plate legend, foot, time | 10.8 to 11.7:1 | 10.8 to 11.7:1 |
| Barograph | night | stale stamp | 6.5:1 | 6.8:1 |

Every aged element holds its polished value or the 4.5:1 floor, whichever is lower. Two day inscriptions on brass, the aneroid's regional bezel and the barograph's housing bar, sit below 4.5:1 in both wears; they are relief engravings in umber over a glint, the polished build already measures them at 2.1:1 and 2.3:1, and aged wear raises both slightly.

### Lock Screen accessories
Plain system type. The brass does not survive vibrant rendering, so the accessories do not imitate it.
- **accessoryCircular:** the system Gauge from 0 to 400, the PSI value (or `–`) as the current label, `PSI` as the label, in the accent group.
- **accessoryRectangular:** `PSI 183 · AQI 168` in `.headline` with tabular digits, in the accent group, over `Central · Unhealthy · 20:30` in `.caption`. Stale reads `Stale 20:30`; a PSI failure reads `Central · Offline`.
- **accessoryInline:** `PSI 183 · AQI 168`.
- Container backgrounds are clear.

### Accessibility
The whole instrument is one VoiceOver element that speaks the reading, for example "24-hour PSI 183, Central, Unhealthy. WAQI AQI 168, Unhealthy. observed 20:30". The band name is spoken and printed on the rectangular accessory, so band meaning never rests on enamel colour alone. Reduce Motion is honoured: the needle snaps and the wheel figures crossfade instead of rolling (evidence: .impeccable/review/motion-default.png and motion-reduced.png). The barograph's pen snaps the same way.

The barograph is also one element. It speaks the same reading and then the trend, for example "Trend up 35 over 24 hours, from 148", "Trend steady over 24 hours, from 183", or "24-hour trend unavailable".

## Do's and Don'ts

### Do:
- **Do** measure every aneroid part in u = side / 170 and keep the dial at (0.498, 0.480) with radius 0.389 of the side.
- **Do** measure every barograph part in points on the 350 × 364 canvas and place the plot, pen and labels from the housing's window.
- **Do** keep the exact figures on the wheels and let the arc and the chart zones only place the band.
- **Do** switch materials for night: lacquer face, black paper, lume ink with glow, `BezelTileNight` and the night barograph rasters, a gunmetal needle with a lume strip, the counter frame dimmed, the current enamel warmed 22% toward Lamp Warmth.
- **Do** label each reading with its scale and source in the engraving (`PSI · 24H · CENTRAL`, `PSI · NEA 24H`, `AQI · WAQI`).
- **Do** pick engraving ink by its ground: Engraver's Black on silver and paper, Bezel Umber on brass, Plate Cream on gunmetal, with the stale mark in Light Ember on the plate.
- **Do** show missing data as blank wheels and a named failure in the legend, with the needle or pen parked at 0 when PSI is missing, and an engraved `TREND · <FAILURE>` on an empty chart.
- **Do** peg the needle at 400 and let the counter show the true figure, up to 999.
- **Do** build the hour axis from the data window, with the newest reading under the pen nib.
- **Do** light every new part from the upper left and cast its shadow down and right.
- **Do** put the needle, the pen, the trace and the wheel figures in the accent group, and drop the raster plate, screws, housing, paper, glass and crystal in the accented finish.

### Don't:
- **Don't** colour the figures, the counters or the plate by band. The thesis refuses the band-coloured number tile; the band lives in the enamel arc and the chart zones only.
- **Don't** draw AQI on the arc or the chart, or give it a needle or a pen. The arc and the chart are NEA's PSI scale; AQI has its own counter.
- **Don't** shrink engraved text below 9 pt. Drop numerals or shorten the legend instead.
- **Don't** let anything glow by day, and don't let the stale mark glow at all.
- **Don't** invent a figure to fill a wheel, or a trace to fill a chart. A blank wheel and an empty chart are the honest states.
- **Don't** draw the day trace as a clean vector line, or let its wobble change between reloads of the same data.
- **Don't** bake a value into a raster. Materials can be generated art; readings, zones, rules and labels are code.
- **Don't** put icons, chips, cards or buttons on the face. Every mark is engraving, enamel, metal, paper, ink or glass.
