#!/usr/bin/env python3
"""Rebuild the deployable templates and their footprint checks (stdlib only)."""
from pathlib import Path
import gzip
import struct

ROOT = Path(__file__).resolve().parents[1] / 'pvpshot/data/pvpshot'

def string(s):
    b = s.encode('utf-8')
    return struct.pack('>H', len(b)) + b

def payload(t, value):
    if t == 3:
        return struct.pack('>i', value)
    if t == 8:
        return string(value)
    if t == 9:
        subtype, values = value
        return bytes([subtype]) + struct.pack('>i', len(values)) + b''.join(payload(subtype, v) for v in values)
    if t == 10:
        return b''.join(bytes([kind]) + string(name) + payload(kind, v) for name, (kind, v) in value.items()) + b'\0'
    raise ValueError(t)

def write_structure(name, size, blocks):
    palette, entries = [], []
    for (x, y, z), (block, props) in sorted(blocks.items()):
        state = {'Name': (8, 'minecraft:' + block)}
        if props:
            state['Properties'] = (10, {k: (8, v) for k, v in props.items()})
        if state not in palette:
            palette.append(state)
        entries.append({'pos': (9, (3, [x, y, z])), 'state': (3, palette.index(state))})
    data = {'DataVersion': (3, 4903), 'size': (9, (3, size)),
            'palette': (9, (10, palette)), 'blocks': (9, (10, entries)), 'entities': (9, (10, []))}
    path = ROOT / 'structure' / (name + '.nbt')
    path.write_bytes(gzip.compress(b'\x0a\0\0' + payload(10, data), mtime=0))

def build():
    for kind, depth, template in [('cannon', 5, 'tnt_cannon'), ('turret', 3, 'face_turret')]:
        blocks = {(x, y, z): ('air', {}) for x in range(3) for y in range(3) for z in range(depth)}
        for x in range(3):
            for z in range(depth):
                blocks[x, 0, z] = ('obsidian', {})
        if kind == 'cannon':
            for z in range(1, 4):
                for x in [0, 2]:
                    blocks[x, 1, z] = ('obsidian', {})
            blocks[1, 1, 3] = ('dispenser', {'facing': 'south', 'triggered': 'false'})
            blocks[1, 2, 3] = ('smooth_stone_slab', {'type': 'bottom', 'waterlogged': 'false'})
            for x in [0, 2]:
                blocks[x, 2, 2] = ('stone_brick_wall', {'east': 'none', 'north': 'none', 'south': 'none', 'west': 'none', 'up': 'true', 'waterlogged': 'false'})
        else:
            for x in range(3):
                # U-shaped breech: the centre power cell directly touches all
                # three dispensers, without relying on dust connection rules.
                z = 1 if x == 1 else 0
                blocks[x, 1, z] = ('dispenser', {'facing': 'south', 'triggered': 'false'})
                blocks[x, 2, z] = ('smooth_stone_slab', {'type': 'bottom', 'waterlogged': 'false'})
        write_structure(template, [3, 3, depth], blocks)
        checks = ['# @s is the aligned marker; caller supplies its cardinal rotation.', 'scoreboard players set #place.ok pvpshot.cal 1']
        for x in range(3):
            for z in range(depth):
                for y in range(3):
                    # Allow unsupported, obstructed and occupied placement. Only
                    # immutable engine/map foundation cells cannot be replaced.
                    checks.append(f'execute positioned ^{x} ^{y} ^{z} if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0')
                    checks.append(f'execute positioned ^{x} ^{y} ^{z} run function pvpshot:protection/check')
                    checks.append('execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0')
        (ROOT / 'function/deploy' / f'check_{kind}.mcfunction').write_text('\n'.join(checks) + '\n')

if __name__ == '__main__':
    build()
