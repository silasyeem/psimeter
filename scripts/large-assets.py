import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

root = Path(sys.argv[1])
source = root / ".impeccable" / "assets" / "large"
catalog = root / "Shared" / "Assets.xcassets"

sizes = {
    "drum-housing.png": ("DrumHousing", (1008, 546)),
    "drum-housing-night.png": ("DrumHousingNight", (1008, 546)),
    "drum-glass.png": ("DrumGlass", (840, 560)),
    "paper-day.png": ("PaperDay", (840, 840)),
    "paper-night.png": ("PaperNight", (840, 840)),
    "plate-day.png": ("PlateDay", (1024, 1024)),
    "plate-night.png": ("PlateNight", (1024, 1024)),
    "pen-arm.png": ("PenArm", (214, 52)),
    "pen-arm-night.png": ("PenArmNight", (214, 52)),
    "screw.png": ("Screw", (62, 62)),
    "screw-night.png": ("ScrewNight", (60, 60)),
    "brass-grain.png": ("BrassGrain", (896, 44)),
    "brass-grain-night.png": ("BrassGrainNight", (896, 44)),
}

aged = {
    "bezel-tile-aged.png": ("BezelTileAged", (1024, 1024)),
    "bezel-tile-night-aged.png": ("BezelTileNightAged", (1024, 1024)),
    "tex-dial.png": ("DialAged", (1024, 1024)),
    "drum-housing-aged.png": ("DrumHousingAged", (1008, 546)),
    "drum-housing-night-aged.png": ("DrumHousingNightAged", (1008, 546)),
    "tex-paper-day.png": ("PaperDayAged", (840, 840)),
    "tex-paper-night.png": ("PaperNightAged", (840, 840)),
    "plate-day-aged.png": ("PlateDayAged", (1024, 1024)),
    "plate-night-aged.png": ("PlateNightAged", (1024, 1024)),
    "pen-arm-aged.png": ("PenArmAged", (214, 52)),
    "pen-arm-night-aged.png": ("PenArmNightAged", (214, 52)),
    "screw-aged.png": ("ScrewAged", (62, 62)),
    "screw-night-aged.png": ("ScrewNightAged", (60, 60)),
}

grain_crop = (320, 19, 320 + 896, 19 + 44)
paper_rows = (216, 624)
papers = {"PaperDayAged", "PaperNightAged"}

housing = (7, 34, 336, 182)
window_fractions = (0.0911, 0.1406, 0.9095, 0.8534)
window_pt = (
    housing[0] + window_fractions[0] * housing[2],
    housing[1] + window_fractions[1] * housing[3],
    (window_fractions[2] - window_fractions[0]) * housing[2],
    (window_fractions[3] - window_fractions[1]) * housing[3],
)
glass_lift_pt = 12
glass_fade = (0.8, 0.86)
aged_glass = {"DrumGlassAgedDay": (0.6, 0.35), "DrumGlassAgedNight": (0.45, 0.25)}
dial_smudge_px = 400
grains = {
    "drum-housing-aged.png": "BrassGrainAged",
    "drum-housing-night-aged.png": "BrassGrainNightAged",
}


def write(image, name, filename):
    folder = catalog / f"{name}.imageset"
    folder.mkdir(exist_ok=True)
    image.save(folder / filename, optimize=True)
    (folder / "Contents.json").write_text(json.dumps({
        "images": [{"filename": filename, "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }, indent=2) + "\n")
    print(f"{name}: {image.size[0]}x{image.size[1]} from {filename}")


def grey(image, size):
    return np.asarray(image.convert("L").resize(size, Image.LANCZOS)).astype(np.float64) / 255


def bake_glass(glass_opacity, smudge_opacity):
    width, height = (math.ceil(v * 3) for v in window_pt[2:])
    reflections = grey(Image.open(source / "drum-glass.png"), (width, height))
    rows = np.arange(height)[:, None]
    fade = np.clip((glass_fade[1] - rows / height) / (glass_fade[1] - glass_fade[0]), 0, 1)
    lift = glass_lift_pt * 3
    lifted = np.zeros_like(reflections)
    lifted[: height - lift] = (reflections * fade)[lift:]
    side = width
    dust = grey(Image.open(root / ".impeccable" / "assets" / "aged" / "tex-smudge.png"), (side, side))
    top = round((side - height) / 2)
    dust = dust[top: top + height]
    screen = 1 - (1 - glass_opacity * lifted) * (1 - smudge_opacity * dust)
    return Image.fromarray(np.round(screen * 255).astype(np.uint8))


for folder, table in [(source, sizes), (root / ".impeccable" / "assets" / "aged", aged)]:
    for filename, (name, size) in table.items():
        image = Image.open(folder / filename)
        if image.size != size:
            image = image.resize(size, Image.LANCZOS)
        if name in papers:
            image = image.crop((0, paper_rows[0], size[0], paper_rows[1]))
        write(image, name, filename)

for name, (glass_opacity, smudge_opacity) in aged_glass.items():
    write(bake_glass(glass_opacity, smudge_opacity), name, f"{name}.png")

smudge = Image.open(root / ".impeccable" / "assets" / "aged" / "tex-smudge.png").convert("L")
write(smudge.resize((dial_smudge_px, dial_smudge_px), Image.LANCZOS), "Smudge", "tex-smudge.png")

for filename, name in grains.items():
    housing = Image.open(root / ".impeccable" / "assets" / "aged" / filename)
    write(housing.crop(grain_crop), name, f"{name}.png")
