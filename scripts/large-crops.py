import sys
from pathlib import Path
from PIL import Image

root = Path(sys.argv[1])
shots = Path(sys.argv[2])
tag = sys.argv[3] if len(sys.argv) > 3 else ""
review = root / ".impeccable" / "review"
comps = root / ".impeccable" / "mocks" / "large"
size = (1050, 1092)


def tile_box(shot):
    px = shot.load()
    width, height = shot.size
    background = px[4, height - 40]
    differs = lambda p: sum(abs(a - b) for a, b in zip(p, background)) > 40
    tile_row = lambda y: sum(1 for x in range(0, width, 3) if differs(px[x, y])) > width // 6
    for y in range(height // 2):
        if tile_row(y):
            xs = [x for x in range(width) if differs(px[x, y + 300])]
            bottom = next(b for b in range(y + 300, height) if not tile_row(b))
            return (xs[0], y, xs[-1] + 1, bottom)
    raise SystemExit("no large tile found")


box = tile_box(Image.open(shots / "live-light.png").convert("RGB"))
finish = {"light": "day", "dark": "night"}
for path in sorted(shots.glob("*.png")):
    state, appearance = path.stem.rsplit("-", 1)
    crop = Image.open(path).convert("RGB").crop(box)
    if tag:
        crop.save(review / f"large-{tag}-{state}-{finish[appearance]}.png")
        continue
    crop.save(review / f"large-{state}-{finish[appearance]}.png")
    if state == "live":
        crop.save(review / f"large-{finish[appearance]}.png")
        comp = "large-a-day.png" if appearance == "light" else "large-c-night.png"
        plate = Image.open(comps / comp).convert("RGB").crop((45, 55, 975, 965)).resize(size, Image.LANCZOS)
        pair = Image.new("RGB", (size[0] * 2 + 30, size[1]), "white" if appearance == "light" else "black")
        pair.paste(plate, (0, 0))
        pair.paste(crop, (size[0] + 30, 0))
        pair.save(review / f"compare-large-{finish[appearance]}.png")
print(f"large crops from box {box}, {box[2] - box[0]}x{box[3] - box[1]} px")
