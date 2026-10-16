import json
import sys
from pathlib import Path
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
    "tex-smudge.png": ("Smudge", (840, 840)),
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


for folder, table in [(source, sizes), (root / ".impeccable" / "assets" / "aged", aged)]:
    for filename, (name, size) in table.items():
        image = Image.open(folder / filename)
        if image.size != size:
            image = image.resize(size, Image.LANCZOS)
        write(image, name, filename)

for filename, name in grains.items():
    housing = Image.open(root / ".impeccable" / "assets" / "aged" / filename)
    write(housing.crop(grain_crop), name, f"{name}.png")
