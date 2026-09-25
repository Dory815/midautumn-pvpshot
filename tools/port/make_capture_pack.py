"""生成"把当前世界灌进复原模板"的数据包（移植到新地图时用一次）。

背景：游戏用 `ustc_pvp:template` 维度存一份**原始竞技场**（含据点、基地、大厅等设施），
`/pvpshot restore`（模组）和校园包的"重置战场"都从这里把地形抄回主世界。
换新地图后必须重新灌一次模板，否则复原时会把竞技场刷成空气。

做法：直接复用校园包自己那 176 个批次（`ustc_pvp:reset/batch_N/copy.mcfunction`），
把里面的 `clone from ustc_pvp:template ... to minecraft:overworld ...`
**方向反过来**，再配一个每 tick 跑一批的驱动器。

用法：
    python tools/port/make_capture_pack.py [--repo 仓库根]

生成物写到 <世界>/datapacks/pvpshot-capture/，然后：
    /reload
    /function pvpshot_capture:start
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

CLONE = re.compile(
    r"clone from ustc_pvp:template (.+?) to minecraft:overworld (.+?) replace force"
)


def reverse_line(line: str) -> str:
    return CLONE.sub(
        lambda m: f"clone from minecraft:overworld {m.group(1)} to ustc_pvp:template {m.group(2)} replace force",
        line,
    )


def build(repo: Path, world: str) -> None:
    reset = repo / "server" / world / "datapacks" / "ustc_pvp" / "data" / "ustc_pvp" / "function" / "reset"
    batches = sorted(
        (p for p in reset.glob("batch_*") if p.is_dir()),
        key=lambda p: int(p.name.split("_")[1]),
    )
    if not batches:
        raise SystemExit(f"[capture] no batches found under {reset}")

    out = repo / "server" / world / "datapacks" / "pvpshot-capture"
    fn = out / "data" / "pvpshot_capture" / "function"
    fn.mkdir(parents=True, exist_ok=True)

    (out / "pack.mcmeta").write_text(
        json.dumps(
            {
                "pack": {
                    "description": "PVP Shot：把当前竞技场灌进 ustc_pvp:template（移植用，跑一次即可）",
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

    total_clone = 0
    for path in batches:
        lines = path.joinpath("copy.mcfunction").read_text(encoding="utf-8").splitlines()
        converted = []
        for line in lines:
            if "clone from ustc_pvp:template" in line:
                converted.append(reverse_line(line))
                total_clone += 1
        (fn / path.name).mkdir(parents=True, exist_ok=True)
        (fn / path.name / "copy.mcfunction").write_text("\n".join(converted) + "\n", encoding="utf-8")

    # 竞技场范围（与校园包 batch 覆盖一致）：X -2144..-1569, Z -1776..-1153
    arena_x1, arena_z1, arena_x2, arena_z2 = -2144, -1776, -1569, -1153

    # 结尾要把临时 forceload 全部取消；单条 forceload 最多 256 区块，
    # 所以按 8x8 区块（64 个）一块地写，稳妥且不会因为超限静默失败。
    removals = []
    for cx in range(arena_x1 >> 4, (arena_x2 >> 4) + 1, 8):
        for cz in range(arena_z1 >> 4, (arena_z2 >> 4) + 1, 8):
            x2 = min(cx + 7, arena_x2 >> 4) * 16
            z2 = min(cz + 7, arena_z2 >> 4) * 16
            removals.append(
                f"execute in minecraft:overworld run forceload remove {cx << 4} {cz << 4} {x2} {z2}"
            )
            removals.append(
                f"execute in ustc_pvp:template run forceload remove {cx << 4} {cz << 4} {x2} {z2}"
            )
    last = len(batches) - 1
    (fn / "start.mcfunction").write_text(
        "\n".join(
            [
                "# 把主世界竞技场灌进 ustc_pvp:template（每 10 tick 一批，共 %d 批）" % len(batches),
                'tellraw @a {"text":"[capture] 开始把当前地图灌进复原模板，请稍候（约 %d 秒）。"}' % max(1, len(batches) // 2),
                "# 区块加载交给校园包自己的 batch_N/load（它按 256 区块以内的粒度分批 forceload）",
                "scoreboard players set #cap.index pvpshot.cal 0",
                "function pvpshot_capture:step",
            ]
        )
        + "\n",
        encoding="utf-8",
    )
    (fn / "step.mcfunction").write_text(
        "\n".join(
            [
                f"execute if score #cap.index pvpshot.cal matches {len(batches)}.. run return 0",
                "execute store result storage pvpshot_capture:state batch int 1 run scoreboard players get #cap.index pvpshot.cal",
                "function pvpshot_capture:step_macro with storage pvpshot_capture:state",
                "scoreboard players add #cap.index pvpshot.cal 1",
                # 每批 ~66 万方块，间隔 10 tick（0.5 秒）跑一批：总耗时约 %d 秒，
                # 单 tick 峰值约 0.4 秒，既不会触发看门狗，也不至于把服务器压死。
                f"execute if score #cap.index pvpshot.cal matches ..{len(batches)} run schedule function pvpshot_capture:step 10t replace",
                f"execute if score #cap.index pvpshot.cal matches {len(batches)}.. run function pvpshot_capture:finish",
            ]
        )
        + "\n",
        encoding="utf-8",
    )
    (fn / "step_macro.mcfunction").write_text(
        "\n".join(
            [
                "$function ustc_pvp:reset/batch_$(batch)/load",
                "$function pvpshot_capture:batch_$(batch)/copy",
            ]
        )
        + "\n",
        encoding="utf-8",
    )
    (fn / "finish.mcfunction").write_text(
        "\n".join(
            removals
            + ['tellraw @a {"text":"[capture] 复原模板已灌好，临时 forceload 已全部取消。"}']
        )
        + "\n",
        encoding="utf-8",
    )

    print(f"[capture] written to {out}")
    print(f"[capture] batches={len(batches)} clone_lines={total_clone}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", default=None)
    ap.add_argument("--world", default="world-ustc")
    args = ap.parse_args()
    root = Path(args.repo) if args.repo else Path(__file__).resolve().parents[2]
    build(root, args.world)
