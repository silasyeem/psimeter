import sys
from PIL import Image

crop = Image.open(sys.argv[1]).convert("RGB")
night = sys.argv[2] == "night"
px = crop.load()
side = crop.width
cx = side // 2


def brass(p):
    return p[0] - p[2] > 40 and p[0] > 90


def dial(p):
    return max(p) < 30 if night else (abs(p[0] - p[2]) < 14 and p[0] > 125)


def figure(p):
    return (p[1] > 160 and p[1] > p[2] + 15) if night else min(p) > 200


def ink(p):
    return (p[1] > 140 and p[1] > p[2] + 15) if night else max(p) < 70


column = [y for y in range(int(side * 0.38), int(side * 0.66)) if brass(px[cx + side // 12, y])]
top = column[0]
bottom = max(y for y in column if y - top < side * 0.3)


def outer(direction):
    x, seen = cx, False
    row = (top + bottom) // 2
    while 0 < x < side - 1:
        p = px[x, row]
        seen = seen or brass(p)
        if seen and dial(p):
            return x - direction
        x += direction
    return x


left, right = outer(-1), outer(1)
fig = [y for y in range(top, bottom) if any(figure(px[x, y]) for x in range(cx - 10, cx + 11))]
edge = next(y for y in range(int(side * 0.8), side) if all(brass(px[cx, y + k]) for k in range(4)))
glyphs = [y for y in range(int(side * 0.79), edge) if any(ink(px[x, y]) for x in range(cx - 20, cx + 21))]
glyph_bottom = glyphs[-1]
print(f"{sys.argv[1].split('/')[-1]}: frame {right - left + 1} x {bottom - top + 1} px "
      f"({(bottom - top + 1) / side:.1%} of side); figure '8' {fig[-1] - fig[0] + 1} px; "
      f"time glyph bottom y={glyph_bottom}, bezel edge y={edge}, gap {edge - glyph_bottom - 1} px")
