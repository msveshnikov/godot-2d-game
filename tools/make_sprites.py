"""Generates 10 pixel-art animations (16x16) for a warrior and a mage.
Output: assets/sprites/heroes/*.png (horizontal strips used by the game),
        tools/preview/ (GIFs, contact sheet, combined spritesheet; not committed)
Run: python tools/make_sprites.py
"""
import os
from PIL import Image

S = 16
HERE = os.path.dirname(os.path.abspath(__file__))
SPRITES = os.path.join(HERE, '..', 'assets', 'sprites', 'heroes')
PREVIEW = os.path.join(HERE, 'preview')


def hexc(s):
    return tuple(int(s[i:i + 2], 16) for i in (1, 3, 5)) + (255,)


PAL = {k: hexc(v) for k, v in {
    'o': '#1a1c2c', 'e': '#1a1c2c',
    'h': '#94b0c2', 'H': '#566c86',          # steel
    's': '#f2c09a',                          # skin
    'r': '#b13e53', 'R': '#7a2a45',          # tunic
    'b': '#6b4226', 'n': '#8a5a34',          # boots / wood
    'p': '#ef7d57',                          # plume
    'w': '#f4f4f4', 'W': '#c0cbdc',          # white / light gray
    'g': '#ffcd75', 'y': '#ffe66d',          # gold / spark
    'B': '#3b5dc9', 'L': '#41a6f6',          # shield
    'v': '#5d3fa8', 'V': '#8b6fd8', 'd': '#3e2a78',  # robe
    'c': '#73eff7', 'C': '#2fb8d8',          # magic
}.items()}

# ---------------------------------------------------------------- parts
W_HEAD = [
    "...ppp....",
    "..oooooo..",
    ".ohhhhhho.",
    "ohhhhhhhho",
    "oHHsssssso",
    "oHssesseso",
    ".oHssssso.",
    "..oooooo..",
]
W_TORSO = [
    "..orrrrro.",
    ".osrrrrrso",
    ".osRggRRso",
    "..oRRRRRo.",
]
W_STAND = ["..obbobbo.", "..obbobbo.", "..ooooooo."]
W_WALK1 = ["..obbobbo.", ".obbo.obbo", ".oooo.oooo"]
W_WALK2 = ["..obbbbo..", "...obbo...", "...oooo..."]
SHIELD = ["ooo.", "oLBo", "oBBo", ".oo."]

M_HEAD = [
    ".....oo...",
    "....ovvo..",
    "...ovVvvo.",
    "..ogggggo.",
    "ovvvvvvvvo",
    ".ossesseo.",
    ".owwwwwwo.",
    "..owwwwo..",
]
M_ROBE = [
    "..ovvvvo..",
    ".ovvVvvvo.",
    ".osvVvvso.",
    ".ovvVvvvo.",
    ".ovvVvvdo.",
]
M_HEM = [
    ["ovvvVvvvdo", "oooooooooo"],
    [".ovvVvvvdo", ".ooooooooo"],
    ["ovvvVvvdo.", "ooooooooo."],
]

# ---------------------------------------------------------------- helpers


def blank():
    return [[None] * S for _ in range(S)]


def put(g, x, y, ch):
    if 0 <= x < S and 0 <= y < S:
        g[y][x] = PAL[ch]


def blit(g, part, x, y):
    for j, row in enumerate(part):
        for i, ch in enumerate(row):
            if ch != '.':
                put(g, x + i, y + j, ch)


def shift(g, dx, dy):
    n = blank()
    for y in range(S):
        for x in range(S):
            if g[y][x] and 0 <= x + dx < S and 0 <= y + dy < S:
                n[y + dy][x + dx] = g[y][x]
    return n


def recolor(g, fn):
    return [[fn(c) if c else None for c in row] for row in g]


def flash(g):
    return recolor(g, lambda c: PAL['w'])


def tint(g, col, t):
    return recolor(g, lambda c: tuple(int(c[i] * (1 - t) + col[i] * t) for i in range(3)) + (c[3],))


def gray(g, dim=1.0, alpha=255):
    def f(c):
        l = int((c[0] * 0.3 + c[1] * 0.59 + c[2] * 0.11) * dim)
        return (l, l, min(255, l + 12), alpha)
    return recolor(g, f)


def lie_down(g):
    """rotate 90deg CCW (head to the left) and drop to the ground"""
    n = blank()
    for y in range(S):
        for x in range(S):
            if g[y][x]:
                n[S - 1 - x][y] = g[y][x]
    rows = [y for y in range(S) if any(n[y])]
    return shift(n, 0, S - 1 - max(rows))


def death(base, soul_x):
    lying = lie_down(base)
    f3 = gray(lying, 0.9)
    for x, y in [(soul_x, 8), (soul_x + 1, 7), (soul_x, 6)]:
        f3[y][x] = PAL['w']
    f4 = gray(lying, 0.6, 170)
    for x, y in [(soul_x + 1, 3), (soul_x, 2)]:
        f4[y][x] = PAL['W']
    return [flash(shift(base, -1, 0)), shift(base, -1, 2), lying, f3, f4]


def hurt(base):
    red = PAL['r']
    return [flash(shift(base, -1, 0)), tint(shift(base, -2, 0), red, 0.45),
            flash(shift(base, -1, 0)), base]

# ---------------------------------------------------------------- warrior


def warrior(bob=0, dx=0, legs=W_STAND, sword='up', sdy=0, fx=()):
    g = blank()
    x = 1 + dx
    blit(g, legs, x, 13)
    blit(g, W_TORSO, x, 9 + bob)
    blit(g, W_HEAD, x, 1 + bob)
    blit(g, SHIELD, x - 1, 10 + bob)
    hx, hy = x + 9, 10 + bob + sdy
    if sword == 'up':
        for i in range(1, 7):
            put(g, hx + 1, hy - i, 'w' if i < 6 else 'W')
        for i in range(3):
            put(g, hx + i, hy, 'g')
        put(g, hx + 1, hy + 1, 'n')
    elif sword == 'diag_up':
        put(g, hx, hy, 'n'); put(g, hx + 1, hy - 1, 'g')
        for i in range(2, 6):
            put(g, hx + i, hy - i, 'w')
    elif sword == 'fwd':
        put(g, hx, hy, 'n')
        for j in (-1, 0, 1):
            put(g, hx + 1, hy + j, 'g')
        for i in range(2, 6):
            put(g, hx + i, hy, 'w')
    elif sword == 'diag_down':
        put(g, hx, hy, 'n'); put(g, hx + 1, hy + 1, 'g')
        for i in range(2, 6):
            put(g, hx + i, hy + i, 'w')
    for px, py, ch in fx:
        put(g, px, py, ch)
    return g


def warrior_anims():
    base = warrior()
    arc1 = [(12, 3, 'W'), (13, 3, 'W'), (14, 4, 'W')]
    arc2 = [(13, 4, 'W'), (14, 5, 'w'), (15, 6, 'w'), (15, 7, 'w'), (15, 8, 'w'), (14, 5, 'w')]
    arc3 = [(15, 8, 'W'), (15, 10, 'W'), (14, 12, 'W')]
    return {
        'warrior_idle': ([warrior(0), warrior(0), warrior(1), warrior(1)], 220),
        'warrior_walk': ([warrior(1, legs=W_WALK1), warrior(0, legs=W_WALK2),
                          warrior(1, legs=W_WALK1), warrior(0)], 120),
        'warrior_attack': ([warrior(0, dx=-1, sdy=-2),
                            warrior(0, sword='diag_up', fx=arc1),
                            warrior(1, dx=1, legs=W_WALK1, sword='fwd', fx=arc2),
                            warrior(1, dx=1, legs=W_WALK1, sword='diag_down', fx=arc3),
                            warrior(0)], 80),
        'warrior_hurt': (hurt(base), 90),
        'warrior_death': (death(base, 7), 170),
    }

# ---------------------------------------------------------------- mage


def mage(bob=0, dx=0, hem=0, sdy=0, orb='c', fx=()):
    g = blank()
    x = 1 + dx
    blit(g, M_ROBE, x, 9)
    blit(g, M_HEM[hem], x, 14)
    blit(g, M_HEAD, x, 1 + bob)
    sx = x + 10
    for y in range(5 + sdy, 15):
        put(g, sx, y, 'n')
    put(g, sx - 1, 11, 's')  # hand on the staff
    oy = 3 + sdy
    for ax, ay in [(0, -1), (-1, 0), (1, 0), (0, 1)]:
        put(g, sx + ax, oy + ay, 'C' if orb == 'c' else 'c')
    put(g, sx, oy, orb)
    for px, py, ch in fx:
        put(g, px, py, ch)
    return g


def mage_anims():
    base = mage()
    sp1 = [(9, 1, 'y'), (13, 3, 'y'), (12, 0, 'y')]
    sp2 = [(11, 0, 'c'), (9, 2, 'c'), (13, 2, 'c'), (9, 0, 'y'), (13, 0, 'y'),
           (13, 6, 'C'), (14, 6, 'c'), (13, 7, 'c'), (14, 7, 'w')]
    bolt = [(13, 6, 'C'), (14, 6, 'c'), (15, 6, 'c'), (13, 7, 'c'), (14, 7, 'w'), (15, 7, 'w'),
            (13, 8, 'C'), (14, 8, 'c'), (15, 8, 'c')]
    tail = [(15, 7, 'c'), (14, 6, 'y'), (13, 8, 'y'), (14, 9, 'C')]
    return {
        'mage_idle': ([mage(0), mage(0, orb='w'), mage(1), mage(1, orb='w')], 220),
        'mage_walk': ([mage(1, hem=1), mage(0, hem=0), mage(1, hem=2), mage(0, hem=0)], 130),
        'mage_cast': ([mage(1), mage(0, sdy=-1, orb='w', fx=sp1),
                       mage(0, sdy=-1, orb='w', fx=sp2),
                       mage(1, dx=1, orb='w', fx=bolt),
                       mage(0, fx=tail)], 100),
        'mage_hurt': (hurt(base), 90),
        'mage_death': (death(base, 7), 170),
    }

# ---------------------------------------------------------------- output


def to_img(g):
    im = Image.new('RGBA', (S, S), (0, 0, 0, 0))
    for y in range(S):
        for x in range(S):
            if g[y][x]:
                im.putpixel((x, y), g[y][x])
    return im


def main():
    anims = {**warrior_anims(), **mage_anims()}
    os.makedirs(SPRITES, exist_ok=True)
    os.makedirs(PREVIEW, exist_ok=True)
    maxf = max(len(f) for f, _ in anims.values())
    sheet = Image.new('RGBA', (S * maxf, S * len(anims)), (0, 0, 0, 0))
    K = 8
    bg = (58, 68, 82, 255)
    contact = Image.new('RGBA', (S * maxf * K, S * len(anims) * K), bg)
    for row, (name, (frames, ms)) in enumerate(anims.items()):
        imgs = [to_img(f) for f in frames]
        strip = Image.new('RGBA', (S * len(imgs), S), (0, 0, 0, 0))
        gif = []
        for i, im in enumerate(imgs):
            strip.paste(im, (i * S, 0))
            sheet.paste(im, (i * S, row * S))
            big = Image.new('RGBA', (S, S), bg)
            big.alpha_composite(im)
            big = big.resize((S * K, S * K), Image.NEAREST)
            contact.paste(big, (i * S * K, row * S * K))
            gif.append(big.convert('RGB'))
        strip.save(os.path.join(SPRITES, name + '.png'))
        gif[0].save(os.path.join(PREVIEW, name + '.gif'), save_all=True,
                    append_images=gif[1:], duration=ms, loop=0)
        print(f'{name}: {len(imgs)} frames, {ms} ms/frame')
    sheet.save(os.path.join(PREVIEW, 'spritesheet.png'))
    contact.save(os.path.join(PREVIEW, 'contact_sheet.png'))


if __name__ == '__main__':
    main()
