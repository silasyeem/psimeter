import sys
from pathlib import Path
from PIL import Image

root = Path(sys.argv[1])
review = root / ".impeccable" / "review"
comps = root / ".impeccable" / "mocks" / "comps"


def first_tile(shot):
    px = shot.load()
    width, height = shot.size
    background = px[4, height // 2]
    differs = lambda p: sum(abs(a - b) for a, b in zip(p, background)) > 60
    for y in range(120, height // 2):
        run = [x for x in range(width // 2) if differs(px[x, y])]
        if len(run) > width // 3:
            middle = y + 200
            xs = [x for x in range(width // 2) if differs(px[x, middle])]
            left, right = xs[0], xs[-1] + 1
            return (left, y - 2, right, y - 2 + (right - left))
    raise SystemExit("no tile found")


box = first_tile(Image.open(review / "gallery-light.png").convert("RGB"))
for appearance, name, comp in [("light", "widget-day", "comp-c-day"), ("dark", "widget-night", "comp-c-counter-night")]:
    shot = Image.open(review / f"gallery-{appearance}.png").convert("RGB")
    tile = shot.crop(box)
    tile.save(review / f"{name}.png")
    plate = Image.open(comps / f"{comp}.png").convert("RGB").crop((60, 52, 958, 950)).resize(tile.size, Image.LANCZOS)
    pair = Image.new("RGB", (tile.width * 2 + 20, tile.height), "black" if appearance == "dark" else "white")
    pair.paste(plate, (0, 0))
    pair.paste(tile, (tile.width + 20, 0))
    pair.save(review / f"compare-{name.split('-')[1]}.png")
    print(f"{name}.png {tile.width}x{tile.height} from {box}")
