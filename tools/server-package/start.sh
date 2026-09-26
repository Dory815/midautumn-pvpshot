#!/usr/bin/env bash
# ============================================================================
# 中秋校园枪战小游戏 · 服务端启动脚本（Linux）
#
# 用法：
#   chmod +x start.sh          # 第一次要先给执行权限
#   ./start.sh                 # 前台运行；关掉终端就会停服（建议配合 screen/tmux）
#   screen -S pvpshot -d -m ./start.sh    # 后台常驻的简单做法
#
# 需要 Java 25（必需）。如果 java 不在 PATH 里，就改下面的 JAVA_BIN。
# 内存默认 1G/3G，按机器改 JAVA_MEM_MAX 即可。
# ============================================================================
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p logs

JAVA_BIN="${JAVA_BIN:-java}"
JAVA_MEM_MIN="${JAVA_MEM_MIN:-1G}"
JAVA_MEM_MAX="${JAVA_MEM_MAX:-3G}"

if ! command -v "$JAVA_BIN" >/dev/null 2>&1 && [ ! -x "$JAVA_BIN" ]; then
  echo "[错误] 找不到 java（当前 JAVA_BIN=$JAVA_BIN）—— 请安装 JDK 25，或在本脚本里把它改成绝对路径" >&2
  exit 1
fi

# 登录方式二选一：
#   ① 外置登录（默认，和作者的测试服一致）：LyerSkin 皮肤站 + authlib-injector。
#      玩家要在启动器里把 https://auth.lylighte.cc/skinapi 加为外置登录并先登录一次。
#   ② 正版登录（Mojang）：删掉下面 exec 里的 -javaagent:... 这一行，online-mode 保持 true。
#   ③ 离线模式：server.properties 里 online-mode=false（公开服不建议）。
exec "$JAVA_BIN" \
  -Xms"$JAVA_MEM_MIN" -Xmx"$JAVA_MEM_MAX" \
  -XX:+UseZGC \
  -XX:ErrorFile=logs/hs_err_pid%p.log \
  -javaagent:authlib-injector-1.2.8.jar=https://auth.lylighte.cc/skinapi \
  -Dfile.encoding=UTF-8 \
  -Dstdout.encoding=UTF-8 \
  -Dstderr.encoding=UTF-8 \
  -Djava.awt.headless=true \
  -jar fabric-server-launch.jar nogui

# 为什么用 ZGC：JDK 25.0.2 的 G1 有一个内部崩溃 bug
#   Internal Error (g1HeapRegionManager.cpp:55) ... master free list MT safety protocol at a safepoint
# 会直接把进程干掉；换成 ZGC 就绕开了。换更新的 JDK 补丁版本也可以。
