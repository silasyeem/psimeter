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

for filename, (name, size) in sizes.items():
    image = Image.open(source / filename)
    if image.size != size:
        image = image.resize(size, Image.LANCZOS)
    folder = catalog / f"{name}.imageset"
    folder.mkdir(exist_ok=True)
    image.save(folder / filename, optimize=True)
    (folder / "Contents.json").write_text(json.dumps({
        "images": [{"filename": filename, "idiom": "universal"}],
        "info": {"author": "xcode", "version": 1},
        "properties": {"preserves-vector-representation": False},
    }, indent=2) + "\n")
    print(f"{name}: {size[0]}x{size[1]} from {filename}")
