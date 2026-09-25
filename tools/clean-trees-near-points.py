"""生成"删掉点位附近所有树"的数据包（作者要求：树挡住了点位与上升通道）。

点位坐标**直接从世界里的 ustc_pvp:points/build 读**（那里面 summon marker 的坐标就是点位中心），
不写死在脚本里，避免以后点位变了还得改脚本。

做法：在每个点位周围 R 格、Y YMIN..YMAX 的柱体里，用
    fill <box> minecraft:air replace #minecraft:logs
    fill <box> minecraft:air replace #minecraft:leaves
把木质方块与树叶清掉。`/fill` 单次最多 32768 方块，所以按 Y 分层切成小块；
每条命令都用 `execute store result score` 把"填掉几个方块"累计到记分板，跑完可以直接读总数。

两个坑：
  1) 26.2 的 `/fill ... replace` 过滤器**只接受单个方块或标签**，不接受逗号列表
     （实测报 "Expected whitespace to end one argument"），所以只能按标签整体删。
  2) `#minecraft:logs` 也包含"去皮木"（stripped_*），而本图里树是用 `oak_wood` 之类的
     树皮方块自定义种的（实测 A 点半径 40 内 64 根树干全部带 40+ 片树叶），去皮木则只出现在
     作者搭的建筑上（A 点西南那处砂岩+安山岩宣传栏用了 16 个 `stripped_birch_wood`）。
     所以删完之后用 RESTORE 里的命令把这几处**按原样放回去**。

同时生成两个入口：
    pvpshot_cleanup:run           主世界
    pvpshot_cleanup:run_template  ustc_pvp:template 维度（复原模板，必须一起清，否则复原会把树刷回来）

模板维度的坑：那个维度平时**没有加载竞技场区块**（复原机制是自己分批 forceload 的），
直接 `/execute in ustc_pvp:template run fill` 会报 "That position is not loaded"，
`execute store result` 会把 0 记进记分板，看起来像"模板里没树"。
所以 run_template 先给 5 个点位各 forceload 一块（合计 ≤256 个区块，避免触发上限），
延后 5 tick 等区块真正加载，再跑清理，最后撤掉 forceload。

用法：
    python tools/clean-trees-near-points.py [--radius 24] [--world world-ustc]
然后 /reload，再执行上面两个函数。
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

POINT = re.compile(
    r"summon marker (-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?) (-?\d+(?:\.\d+)?) .*ustc\.point\.([A-Z])"
)

MIN_Y, MAX_Y = -8, 64
MAX_FILL_VOLUME = 32000        # /fill 上限 32768，留点余量

# 第一遍：木质方块与树叶（都是标签，26.2 的 fill 过滤器每次只认一个）
FILTERS = ("#minecraft:logs", "#minecraft:leaves")

# 第二遍：本图的树是"木头立柱 + 栏杆/墙块"混搭搭出来的，清完树叶与木块后还会剩下这些配件。
# 用清树前的原始地图（before/USTC_project）在同样 5 个方框里做过分类（判定规则：水平 4 格内、
# 竖直 -4..+14 内有树叶即算植被）：
#     spruce_fence      325 个植被 / 0 个建筑
#     mud_brick_wall    498 / 0
#     oak_fence         338 / 0
#     prismarine_wall    60 / 0
# 而这四类以外的东西基本都是建筑：铁栏杆(1078/4953)、诡异木栅栏(284/5103)、
# 灰玻璃板(0/3853)、脚手架(0/478)、梯子(2/573)、安山岩墙(242/386)、砂岩墙(117/241)……
# 所以这里**只清这四类**，并且把 Y 限制在 -8..40（实测这些配件最高到 y=22，建筑栏杆都在 70+）。
EXTRA_FILTERS = ("minecraft:spruce_fence", "minecraft:mud_brick_wall",
                 "minecraft:oak_fence", "minecraft:prismarine_wall")
EXTRA_MIN_Y, EXTRA_MAX_Y = -8, 40

# 清完之后按原样放回去的"去皮木建筑"（用 tools/region_scan.py 扫出来，全图就这一处）：
# A 点西南 x=-2020、z=-1538..-1535、y=3..6 的宣传栏，16 个 stripped_birch_wood
RESTORE = [
    "fill -2020 3 -1538 -2020 6 -1535 minecraft:stripped_birch_wood",
]


def boxes(px: int, pz: int, radius: int, ymin: int = MIN_Y, ymax: int = MAX_Y):
    x1, x2 = px - radius, px + radius
    z1, z2 = pz - radius, pz + radius
    width = (x2 - x1 + 1) * (z2 - z1 + 1)
    layer = max(1, MAX_FILL_VOLUME // width)
    y = ymin
    while y <= ymax:
        top = min(y + layer - 1, ymax)
        yield x1, y, z1, x2, top, z2
        y = top + 1


def build(repo: Path, world: str, radius: int) -> None:
    build_fn = (repo / "server" / world / "datapacks" / "ustc_pvp" / "data" / "ustc_pvp"
                / "function" / "points" / "build.mcfunction")
    text = build_fn.read_text(encoding="utf-8")
    points = [(m.group(4), float(m.group(1)), float(m.group(3))) for m in POINT.finditer(text)]
    if not points:
        raise SystemExit(f"[trees] 没在 {build_fn} 里找到点位 marker")

    out = repo / "server" / world / "datapacks" / "pvpshot-cleanup"
    fn = out / "data" / "pvpshot_cleanup" / "function"
    fn.mkdir(parents=True, exist_ok=True)
    (out / "pack.mcmeta").write_text(
        json.dumps(
            {
                "pack": {
                    "description": "点位附近清树（一次性工具，可留档）",
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

    lines_overworld = [
        "# 由 tools/clean-trees-near-points.py 生成",
        f"# 半径 {radius} 格，Y {MIN_Y}..{MAX_Y}，清掉树叶与非去皮木质方块；末行给出总块数",
        "scoreboard players set #trees.removed pvpshot.cal 0",
    ]
    total_fills = 0

    # 模板维度：先算好每个点位方块的 forceload 范围（区块盒），再生成清理函数
    forceload_boxes = []
    for name, px, pz in points:
        cx, cz = int(px), int(pz)
        forceload_boxes.append((cx - radius, cz - radius, cx + radius, cz + radius))
    chunks = set()
    for x1, z1, x2, z2 in forceload_boxes:
        for ccx in range(x1 >> 4, (x2 >> 4) + 1):
            for ccz in range(z1 >> 4, (z2 >> 4) + 1):
                chunks.add((ccx, ccz))
    if len(chunks) > 256:
        raise SystemExit(f"[trees] forceload 需要 {len(chunks)} 个区块，超过原版 256 上限，请缩小 --radius")

    lines_template = ["# 由 tools/clean-trees-near-points.py 生成（模板维度入口）",
                      f"# 先 forceload {len(chunks)} 个区块，5 tick 后跑 run_template_fill"]
    lines_template += [f"execute in ustc_pvp:template run forceload add {a} {b} {c} {d}"
                       for a, b, c, d in forceload_boxes]
    lines_template.append("schedule function pvpshot_cleanup:run_template_fill 5t replace")
    lines_template.append('tellraw @a {"text":"[清树] 模板维度已常加载 5 个点位区块，5 tick 后开始清理"}')

    lines_fill = ["# 由 tools/clean-trees-near-points.py 生成（模板维度清理主体）",
                  "scoreboard players set #trees.removed pvpshot.cal 0"]

    for name, px, pz in points:
        cx, cz = int(px), int(pz)
        for x1, y1, z1, x2, y2, z2 in boxes(cx, cz, radius):
            for flt in FILTERS:
                total_fills += 1
                fill = f"fill {x1} {y1} {z1} {x2} {y2} {z2} minecraft:air replace {flt}"
                lines_overworld.append(
                    f"execute store result score #n pvpshot.cal run {fill}")
                lines_overworld.append(
                    "scoreboard players operation #trees.removed pvpshot.cal += #n pvpshot.cal")
                lines_fill.append(
                    f"execute in ustc_pvp:template store result score #n pvpshot.cal run {fill}")
                lines_fill.append(
                    "scoreboard players operation #trees.removed pvpshot.cal += #n pvpshot.cal")
        # 第二遍：树上的栏杆/墙块配件
        for x1, y1, z1, x2, y2, z2 in boxes(cx, cz, radius, EXTRA_MIN_Y, EXTRA_MAX_Y):
            for flt in EXTRA_FILTERS:
                total_fills += 1
                fill = f"fill {x1} {y1} {z1} {x2} {y2} {z2} minecraft:air replace {flt}"
                lines_overworld.append(
                    f"execute store result score #n pvpshot.cal run {fill}")
                lines_overworld.append(
                    "scoreboard players operation #trees.removed pvpshot.cal += #n pvpshot.cal")
                lines_fill.append(
                    f"execute in ustc_pvp:template store result score #n pvpshot.cal run {fill}")
                lines_fill.append(
                    "scoreboard players operation #trees.removed pvpshot.cal += #n pvpshot.cal")

    # 把误伤到的去皮木建筑按原样放回去（放回操作不参与"清掉多少方块"的计数）
    lines_overworld += ["# 放回去皮木建筑"] + list(RESTORE)
    lines_fill += ["# 放回去皮木建筑"] + [f"execute in ustc_pvp:template run {c}" for c in RESTORE]
    lines_fill += [f"execute in ustc_pvp:template run forceload remove {a} {b} {c} {d}"
                   for a, b, c, d in forceload_boxes]

    lines_overworld.append('tellraw @a {"text":"[清树] 主世界完成，共清除 ","extra":[{"score":{"name":"#trees.removed","objective":"pvpshot.cal"}},{"text":" 个方块"}]}')
    lines_fill.append('tellraw @a {"text":"[清树] 模板维度完成，共清除 ","extra":[{"score":{"name":"#trees.removed","objective":"pvpshot.cal"}},{"text":" 个方块"}]}')

    (fn / "run.mcfunction").write_text("\n".join(lines_overworld) + "\n", encoding="utf-8")
    (fn / "run_template.mcfunction").write_text("\n".join(lines_template) + "\n", encoding="utf-8")
    (fn / "run_template_fill.mcfunction").write_text("\n".join(lines_fill) + "\n", encoding="utf-8")

    print(f"[trees] points: {[p[0] for p in points]}")
    print(f"[trees] fills per dimension: {total_fills}, radius={radius}")
    print(f"[trees] written to {out}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=None)
    ap.add_argument("--world", default="world-ustc")
    ap.add_argument("--radius", type=int, default=24)
    args = ap.parse_args()
    root = Path(args.repo) if args.repo else Path(__file__).resolve().parents[1]
    build(root, args.world, args.radius)
