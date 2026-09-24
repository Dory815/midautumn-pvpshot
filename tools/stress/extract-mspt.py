"""[tickrec] 日志 → CSV（两列：tick 序号, MSPT 毫秒）。

用法：
    python tools/stress/extract-mspt.py <latest.log 路径> <输出 CSV 路径>

日志来源：模组命令 `/pvpshot tickrecord <tick 数>` 会为每个 tick 写一行
    [pvpshot][tickrec] 17 6.482
本脚本把它们抽出来写成 CSV，交给 tools/stress/plot-mspt.ps1 画图。
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

LINE = re.compile(r"\[tickrec\]\s+(\d+)\s+([0-9.]+)")


def main(log_path: str, csv_path: str) -> int:
    text = Path(log_path).read_text(encoding="utf-8", errors="replace")
    rows: list[tuple[int, float]] = []
    for line in text.splitlines():
        m = LINE.search(line)
        if m:
            rows.append((int(m.group(1)), float(m.group(2))))
    if not rows:
        print("[extract] no [tickrec] samples found")
        return 1
    # 同一次采样从 1 重新编号；按序号去重（取最后一次，便于反复压测后只看最新一轮）
    latest: dict[int, float] = {}
    for idx, ms in rows:
        if idx == 1 and latest:
            latest = {}
        latest[idx] = ms
    out = Path(csv_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w", encoding="utf-8") as fh:
        for idx in sorted(latest):
            fh.write(f"{idx},{latest[idx]:.3f}\n")
    ms = list(latest.values())
    ms_sorted = sorted(ms)
    p95 = ms_sorted[min(len(ms_sorted) - 1, int(len(ms_sorted) * 0.95))]
    print(f"[extract] {len(ms)} samples -> {out}")
    print(f"[extract] avg={sum(ms)/len(ms):.2f} p95={p95:.2f} max={max(ms):.2f} min={min(ms):.2f}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        raise SystemExit(2)
    raise SystemExit(main(sys.argv[1], sys.argv[2]))
