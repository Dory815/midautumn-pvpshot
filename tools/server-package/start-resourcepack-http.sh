#!/usr/bin/env bash
# ============================================================================
# 资源包下载服务（可选，Linux）
#
# 作用：把当前目录挂在 8080 端口，让客户端自动下载 pvpshot-waypoints.zip
#       （A~E 点位字母图标；不装资源包也能进服，只是定位条字母会变成缺失纹理）。
#
# 用法：
#   chmod +x start-resourcepack-http.sh
#   ./start-resourcepack-http.sh
#
# 然后到 server.properties 里填（把 <服务器IP> 换成你的公网/内网地址）：
#   resource-pack=http://<服务器IP>:8080/pvpshot-waypoints.zip
#   resource-pack-sha1=e37d44ce8a4bde81910fcfddf879680783ce178b
#   require-resource-pack=false      # 允许多次拒绝，玩家可选
#
# 这是最简单的 python http.server，没有守护；掉了重跑一次即可。
# ============================================================================
set -euo pipefail
cd "$(dirname "$0")"

PORT="${PORT:-8080}"
mkdir -p logs
exec python3 -m http.server "$PORT" --bind 0.0.0.0 >> logs/resourcepack-http.log 2>&1
