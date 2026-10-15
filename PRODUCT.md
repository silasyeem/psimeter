# Product

<!-- impeccable:product-schema 1 -->

## Platform

ios

## Stack

Native WidgetKit: a SwiftUI widget extension inside a minimal containing iOS app, built with Xcode 27. Chosen by the user over Scriptable so the rendering has no ceiling.

## Users

People in Singapore who check air quality during haze season and on bad-air days, glancing at the Home Screen or Lock Screen before going outside, exercising, or opening windows. They know the PSI and AQI scales and want the readings, not a softened verdict. The product targets the App Store, so it must also hold up for a stranger installing it cold.

## Product Purpose

A Home Screen and Lock Screen widget that shows the latest Singapore air readings from two sources at a glance: NEA's 24-hour PSI (the figures published on haze.gov.sg) and the AQI reported by the World Air Quality Index project (aqicn.org). Success is reading both exact numbers in under a second without opening an app.

## Positioning

Two independent authorities on one instrument. NEA's official 24-hour PSI and WAQI's AQI use different scales and averaging windows and often disagree; the widget shows both exact readings side by side instead of collapsing them into one score. It is built as a crafted physical object rather than a flat data tile.

## Operating Context

- Glanced at on the Home Screen (systemSmall, systemLarge) and Lock Screen (accessory families), in tropical daylight outdoors and in dim rooms at night.
- Haze season (roughly August to October) is when it matters most. NEA historically headlines PSI updates hourly; PSI can sit in the Unhealthy band (101 to 200) for days.
- WidgetKit refreshes on a system-managed budget, so the widget must always say how old its reading is.

## Capabilities and Constraints

- Sizes: systemSmall, systemLarge (added 2026-10-15; adds a 24-hour PSI trend), and Lock Screen (accessoryCircular, accessoryRectangular, accessoryInline). No medium in scope.
- Trend source: the same NEA endpoint with `?date=YYYY-MM-DD` returns that day's hourly readings; the last 24 hours spans today and yesterday.
- PSI source: `https://api-open.data.gov.sg/v2/real-time/api/psi`, no key. Returns 24-hour PSI and PM2.5 per region (north, south, east, west, central) with an update timestamp.
- AQI source: WAQI JSON API (`api.waqi.info/feed/...`), needs a personal token (`WAQI_TOKEN`). The demo token does not return Singapore.
- PSI bands (NEA): 0-50 Good, 51-100 Moderate, 101-200 Unhealthy, 201-300 Very Unhealthy, 301+ Hazardous.
- AQI bands (US EPA scale used by WAQI): 0-50 Good, 51-100 Moderate, 101-150 Unhealthy for Sensitive Groups, 151-200 Unhealthy, 201-300 Very Unhealthy, 301+ Hazardous.
- Lock Screen widgets render in vibrant/monochrome system modes; colour and texture largely do not survive there.
- Headline region: user-chosen per widget (Edit Widget → Region), default Central.
- WAQI stations: NEA's official per-region stations @1662 North, @1663 South, @1664 East, @1665 West, @1666 Central, so AQI and PSI describe the same region. WAQI's geo feed does not resolve Singapore coordinates.

## Brand Commitments

- Working name: psimeter (from the project folder; not confirmed as the shipping name).
- The user asked for a gorgeous skeuomorphic widget. That is binding.

## Evidence on Hand

- Live NEA PSI API verified working on 2026-10-14 (24-hour PSI 126 to 197 across regions at 20:30 SGT).
- No logo, icon, or brand assets exist yet.
- No WAQI token yet; AQI values must not be invented in shipped UI.
- Attribution: NEA data falls under the Singapore Open Data Licence and WAQI requires source attribution. Both need a credit surface before App Store submission.

## Product Principles

1. Exact numbers first. The reading is the product; bands and colour support it, never replace it.
2. Two sources, never blended. Each number is labelled with its scale and source.
3. Honest freshness. A stale reading must look stale.
4. A real object. The craft of the material is the reason to install this over a free alternative.

## Accessibility & Inclusion

Band meaning must not rely on colour alone (label or position must carry it too). Numerals must stay legible at systemSmall size in both light and dark Home Screens and in tinted/clear icon modes.
