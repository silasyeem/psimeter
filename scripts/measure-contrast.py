import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw

review = Path(sys.argv[1])

small = {
    "dial legend": (140, 178, 350, 200),
    "AQI legend": (185, 318, 305, 340),
    "time": (195, 388, 295, 418),
    "region N": (205, 18, 285, 44),
}
small_stale = {"stale stamp": (198, 390, 298, 420)}
large = {
    "housing inscription": (390, 124, 660, 154),
    "value label": (120, 292, 182, 316),
    "hour labels": (180, 526, 920, 552),
    "plate legend": (250, 686, 480, 712),
    "region foot": (130, 1016, 560, 1044),
    "time": (760, 1016, 925, 1044),
}
large_stale = {"stale stamp": (700, 1016, 925, 1044)}


def luminance(rgb):
    c = rgb / 255
    c = np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
    return 0.2126 * c[..., 0] + 0.7152 * c[..., 1] + 0.0722 * c[..., 2]


def dilate(mask, radius):
    grown = mask.copy()
    for dy in range(-radius, radius + 1):
        for dx in range(-radius, radius + 1):
            grown |= np.roll(np.roll(mask, dy, 0), dx, 1)
    return grown


def contrast(image, box):
    lum = luminance(np.asarray(image.crop(box)).astype(np.float64))
    median = np.median(lum)
    dark, light = np.percentile(lum, 3), np.percentile(lum, 97)
    ink = dark if median - dark > light - median else light
    glyphs = (lum <= median + 0.6 * (dark - median)) if ink == dark else (lum >= median + 0.6 * (light - median))
    halo = dilate(glyphs, 6) & ~dilate(glyphs, 2)
    ground = np.median(lum[halo])
    return (max(ink, ground) + 0.05) / (min(ink, ground) + 0.05)


rows = []
for size, polished, aged, boxes in [
    ("small", "widget-day.png", "widget-aged-day.png", small),
    ("small", "widget-night.png", "widget-aged-night.png", small),
    ("small", "gallery-light.png", "widget-aged-stale-day.png", small_stale),
    ("small", "gallery-dark.png", "widget-aged-stale-night.png", small_stale),
    ("large", "large-live-day.png", "large-aged-day.png", large),
    ("large", "large-live-night.png", "large-aged-night.png", large),
    ("large", "large-stale-day.png", "large-aged-stale-day.png", large_stale),
    ("large", "large-stale-night.png", "large-aged-stale-night.png", large_stale),
]:
    finish = "night" if "night" in aged else "day"
    a = Image.open(review / aged).convert("RGB")
    p = Image.open(review / polished).convert("RGB")
    if polished.startswith("gallery-"):
        p = p.crop((627, 248, 1119, 740))
    for name, box in boxes.items():
        rows.append((size, finish, name, contrast(p, box), contrast(a, box)))

print(f"{'surface':7} {'finish':6} {'element':20} {'polished':>9} {'aged':>7}")
for size, finish, name, p, a in rows:
    flag = "  LOW" if a < min(p, 4.5) - 0.05 else ""
    print(f"{size:7} {finish:6} {name:20} {p:8.2f}:1 {a:6.2f}:1{flag}")

if len(sys.argv) > 2:
    out = Path(sys.argv[2])
    for source, boxes in [("widget-aged-stale-day.png", {**small, **small_stale}), ("large-aged-stale-day.png", {**large, **large_stale})]:
        image = Image.open(review / source).convert("RGB")
        draw = ImageDraw.Draw(image)
        for box in boxes.values():
            draw.rectangle(box, outline=(255, 0, 255), width=2)
        image.save(out / f"boxes-{source}")
