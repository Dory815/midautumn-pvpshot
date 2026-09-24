"""生成"全员投掷物齐射"压测数据包（供测试服的命令方块调用）。

用法：
    python tools/stress/make_stress_pack.py [输出目录]

默认写到 <仓库>/server/world/datapacks/pvpshot-stress/，然后 /reload 即可生效。

生成内容：
    pvpshot_stress:all      每种投掷物 100 发，方向随机（固定种子，可复现），
                            从**命令方块执行位置**（也就是玩家身上）飞出去
    pvpshot_stress:clear    清掉所有本数据包生成的投掷物（按 tag=pvpshot.stress）

投掷物清单取自游戏自身的两个地方，保证"不漏也不乱加"：
  * 数据包标签 pvpshot:resettable（tnt / arrow / spectral_arrow / snowball / egg /
    fireball / small_fireball / firework_rocket / trident）
  * 物品表里实际存在的投掷类道具（风弹 wind_charge、末影珍珠 ender_pearl、投掷药水 potion）
"""

from __future__ import annotations

import json
import math
import random
import sys
from pathlib import Path

class Raw(str):
    """原样写进 SNBT 的字面量（数字、带后缀的 0b/60s 等），不加引号。"""


# 每种投掷物：(实体 id, 初速 格/tick, 额外 NBT)
PROJECTILES: list[tuple[str, float, dict]] = [
    ("minecraft:arrow", 2.2, {"pickup": Raw("0b")}),
    ("minecraft:spectral_arrow", 2.2, {"pickup": Raw("0b")}),
    ("minecraft:snowball", 1.4, {}),
    ("minecraft:egg", 1.4, {}),
    ("minecraft:trident", 2.0, {}),
    ("minecraft:tnt", 0.9, {"fuse": Raw("60s")}),
    ("minecraft:small_fireball", 1.5, {}),
    ("minecraft:fireball", 0.8, {}),
    ("minecraft:firework_rocket", 0.9, {"Life": Raw("0"), "Fireworks": {"Flight": Raw("1")}}),
    ("minecraft:wind_charge", 1.2, {}),
    ("minecraft:ender_pearl", 1.5, {}),
    ("minecraft:splash_potion", 0.9, {"Item": {"id": "minecraft:splash_potion", "count": Raw("1")}}),
    ("minecraft:lingering_potion", 0.9, {"Item": {"id": "minecraft:lingering_potion", "count": Raw("1")}}),
]

SHOTS_PER_TYPE = 100
TAG = "pvpshot.stress"
SEED = 20260925


def nbt(value) -> str:
    """把 Python 值写成 SNBT：dict / list / 字符串（加引号）/ Raw（原样）。"""
    if isinstance(value, dict):
        inner = ",".join(f'{k}:{nbt(v)}' for k, v in value.items())
        return "{" + inner + "}"
    if isinstance(value, (list, tuple)):
        return "[" + ",".join(nbt(v) for v in value) + "]"
    if isinstance(value, Raw):
        return str(value)
    if isinstance(value, str):
        return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'
    return str(value)


def directions(count: int) -> list[tuple[float, float, float]]:
    """随机方向：水平方向绕满一圈，俯仰限制在 -10°~+60°，避免大部分一出土就砸地。"""
    rng = random.Random(SEED)
    out = []
    for _ in range(count):
        yaw = rng.uniform(0.0, 2.0 * math.pi)
        pitch = math.radians(rng.uniform(-10.0, 60.0))
        out.append(
            (
                math.cos(yaw) * math.cos(pitch),
                math.sin(pitch),
                math.sin(yaw) * math.cos(pitch),
            )
        )
    return out


def build(out_dir: Path) -> None:
    fn_dir = out_dir / "data" / "pvpshot_stress" / "function"
    fn_dir.mkdir(parents=True, exist_ok=True)

    (out_dir / "pack.mcmeta").write_text(
        json.dumps(
            {
                # 26.2 起必须写 min_format / max_format，只写 pack_format 会被拒绝加载
                "pack": {
                    "description": "PVP Shot 压测：齐射全部投掷物（每种 100 发）",
                    "min_format": [107, 1],
                    "max_format": 107,
                }
            },
            ensure_ascii=False,
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )

    dirs = directions(SHOTS_PER_TYPE)
    lines = [
        "# 由 tools/stress/make_stress_pack.py 生成，请勿手改",
        f"# 每种投掷物 {SHOTS_PER_TYPE} 发；方向随机（种子 {SEED}）；从执行位置（玩家身上）射出",
        f"# 共 {len(PROJECTILES)} 种 / {len(PROJECTILES) * SHOTS_PER_TYPE} 发",
    ]
    for entity, speed, extra in PROJECTILES:
        nbt_extra = dict(extra)
        nbt_extra["Tags"] = [TAG]
        for dx, dy, dz in dirs:
            motion = [round(dx * speed, 3), round(dy * speed, 3), round(dz * speed, 3)]
            data = dict(nbt_extra)
            data["Motion"] = motion
            lines.append(f"summon {entity} ~ ~1 ~ {nbt(data)}")

    (fn_dir / "all.mcfunction").write_text("\n".join(lines) + "\n", encoding="utf-8")

    (fn_dir / "clear.mcfunction").write_text(
        "\n".join(
            [
                "# 清掉压测生成的投掷物（含未爆的 TNT）",
                f"kill @e[tag={TAG}]",
                f"kill @e[tag={TAG},type=minecraft:item]",
                "tellraw @a {\"text\":\"[压测] 已清理本次齐射生成的全部投掷物\",\"color\":\"gray\"}",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    # "压测三件套"：命令方块（+2 格）+ 按钮（方块顶上）+ 告示牌（+3 格）。
    # 用函数而不是手敲 setblock，避免在 shell 里跟引号搏斗；位置全部相对执行位置。
    place = fn_dir / "place_kit.mcfunction"
    place.write_text(
        "\n".join(
            [
                "# 在「执行位置右手边 2 格」放好压测三件套；/reload 后再执行：",
                "#   execute at <玩家> positioned ~2 ~ ~ run function pvpshot_stress:place_kit",
                'setblock ~2 ~ ~ minecraft:command_block[facing=up]{Command:"execute at @p[distance=..20] run function pvpshot_stress:all",auto:0b,TrackOutput:0b,powered:0b}',
                "setblock ~2 ~1 ~ minecraft:stone_button[face=floor,facing=north,powered=false]",
                'setblock ~3 ~ ~ minecraft:oak_sign[rotation=4]{front_text:{color:"black",messages:[{text:"[压测] 齐射全部投掷物"},{text:"每种 100 发 · 共 13 种"},{text:"按钮：从你身上向外随机发射"},{text:"清理 /function pvpshot_stress:clear"}]}}',
                '# 在命令方块旁留一个定位用的 marker：data get entity @e[tag=pvpshot.stress.kit,limit=1] Pos',
                'summon minecraft:marker ~2 ~ ~ {Tags:["pvpshot.stress.kit"]}',
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    # 控制台输出只用 ASCII：Windows 控制台默认代码页会把 UTF-8 中文显示成乱码
    print(f"[stress] written to {out_dir}")
    print(f"[stress] all.mcfunction   : {len(PROJECTILES) * SHOTS_PER_TYPE} summon lines ({len(PROJECTILES)} kinds)")
    print("[stress] clear.mcfunction : cleanup function")
    print("[stress] place_kit.mcfunction : command block + button + sign")

    # 自检用：放一个"按钮 → 命令方块"的最小组合，命令只是把 #selftest 置 1，
    # 用来确认接线（按钮在命令方块正上方）真的能触发；用完直接 setblock 成 air 即可。
    (fn_dir / "place_selftest.mcfunction").write_text(
        "\n".join(
            [
                "# 自检组合：命令方块(执行位置) + 按钮(其正上方)",
                'setblock ~ ~ ~ minecraft:command_block[facing=up]{Command:"scoreboard players set #selftest pvpshot.cal 1",auto:0b,TrackOutput:0b}',
                "setblock ~ ~1 ~ minecraft:stone_button[face=floor,facing=north,powered=false]",
            ]
        )
        + "\n",
        encoding="utf-8",
    )
    print("[stress] place_selftest.mcfunction : button->command block self test")


if __name__ == "__main__":
    repo = Path(__file__).resolve().parents[2]
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else repo / "server" / "world" / "datapacks" / "pvpshot-stress"
    build(target)
