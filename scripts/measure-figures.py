import sys
from PIL import Image

path, finish = sys.argv[1], sys.argv[2]
boxes = [tuple(int(v) for v in arg.split(",")) for arg in sys.argv[3:]]
image = Image.open(path).convert("RGB")
px = image.load()
night = finish == "night"


def figure(p):
    return (p[1] > 160 and p[1] > p[2] + 15) if night else min(p) > 200


for x0, y0, x1, y1 in boxes:
    rows = [y for y in range(y0, y1) if sum(1 for x in range(x0, x1) if figure(px[x, y])) >= 2]
    cols = [x for x in range(x0, x1) if sum(1 for y in range(y0, y1) if figure(px[x, y])) >= 2]
    print(f"{path.split('/')[-1]} box {x0},{y0},{x1},{y1}: figure height {rows[-1] - rows[0] + 1} px, width {cols[-1] - cols[0] + 1} px")
