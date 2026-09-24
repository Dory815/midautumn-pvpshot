# -*- coding: utf-8 -*-
"""Generate the waypoint-icon resource pack (A~E letters for the locator bar)."""
import hashlib
import json
import os
import shutil
import zipfile

from PIL import Image

OUT_DIR = r'D:\MC\MidAutumnMiniGame\tools\waypoint-resourcepack'
ZIP_PATH = r'D:\MC\MidAutumnMiniGame\server\pvpshot-waypoints.zip'
NS = 'pvpshot'

# 5x7 点阵字母
LETTERS = {
    'A': ['.###.', '#...#', '#...#', '#####', '#...#', '#...#', '#...#'],
    'B': ['####.', '#...#', '#...#', '####.', '#...#', '#...#', '####.'],
    'C': ['.###.', '#...#', '#....', '#....', '#....', '#...#', '.###.'],
    'D': ['####.', '#...#', '#...#', '#...#', '#...#', '#...#', '####.'],
    'E': ['#####', '#....', '#....', '####.', '#....', '#....', '#####'],
}

RESOURCE_PACK_FORMAT = 88

if os.path.exists(OUT_DIR):
    shutil.rmtree(OUT_DIR)

# 注意：GUI sprite 的贴图路径必须包含 gui/sprites/ 这一段
# （对照原版：assets/minecraft/textures/gui/sprites/hud/locator_bar_dot/default_0.png）
style_dir = os.path.join(OUT_DIR, 'assets', NS, 'waypoint_style')
texture_dir = os.path.join(OUT_DIR, 'assets', NS, 'textures', 'gui', 'sprites',
                           'hud', 'locator_bar_dot')
os.makedirs(style_dir, exist_ok=True)
os.makedirs(texture_dir, exist_ok=True)

with open(os.path.join(OUT_DIR, 'pack.mcmeta'), 'w', encoding='utf-8', newline='\n') as handle:
    json.dump({
        'pack': {
            'description': 'PVP Shot 点位图标（A~E）',
            'min_format': [RESOURCE_PACK_FORMAT, 0],
            'max_format': RESOURCE_PACK_FORMAT,
        }
    }, handle, ensure_ascii=False, indent=2)

for letter, rows in LETTERS.items():
    # 9x9 图标（原版定位条圆点尺寸），字母居中，白色（客户端会按队伍颜色染色）
    image = Image.new('RGBA', (9, 9), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        for x, cell in enumerate(row):
            if cell == '#':
                image.putpixel((x + 2, y + 1), (255, 255, 255, 255))
    name = letter.lower()
    image.save(os.path.join(texture_dir, name + '.png'))
    with open(os.path.join(style_dir, name + '.json'), 'w', encoding='utf-8', newline='\n') as handle:
        json.dump({
            'near_distance': 128,
            'far_distance': 1000,
            'sprites': ['%s:%s' % (NS, name)],
        }, handle, ensure_ascii=False, indent=2)

with zipfile.ZipFile(ZIP_PATH, 'w', zipfile.ZIP_DEFLATED) as archive:
    for root, _, files in os.walk(OUT_DIR):
        for name in files:
            full = os.path.join(root, name)
            archive.write(full, os.path.relpath(full, OUT_DIR).replace('\\', '/'))

with open(ZIP_PATH, 'rb') as handle:
    sha1 = hashlib.sha1(handle.read()).hexdigest()

print('PACK_DIR=' + OUT_DIR)
print('ZIP=' + ZIP_PATH)
print('ZIP_SIZE=' + str(os.path.getsize(ZIP_PATH)))
print('SHA1=' + sha1)
