# 中秋校园枪战小游戏 · 服务端部署说明（Linux）

这是一份**开箱即用**的 Fabric 服务端：把整个目录传到 Linux 机器上，装好 Java 25，跑 `./start.sh` 就能开服。
地图、点位、出生点、设施保护、整场复原模板都在 `world-ustc/` 里，不需要再单独导地图。
玩家端**零安装**：原版 26.2 客户端直连即可（资源包可选）。

---

## 1. 目录里有什么

```
.
├── start.sh                       ← 启动脚本（已配好 ZGC、UTF-8、外置登录）
├── start-resourcepack-http.sh     ← 可选：8080 端口发资源包
├── fabric-server-launch.jar       ← Fabric 启动器
├── versions/26.2/server-26.2.jar  ← 官方服务端（Fabric 启动器要用）
├── libraries/                     ← Fabric/游戏依赖库
├── mods/pvpshot-1.0.0-m1.jar      ← 一体化模组（含 7 个嵌套模组，见第 7 节）
├── config/                        ← 模组配置（Carpet / spark / 铁氧体磁芯 等）
├── authlib-injector-1.2.8.jar     ← 外置登录（LyerSkin）用
├── world-ustc/                    ← ★ 全部世界数据（地图 / 竞技场 / 复原模板维度 / 数据包）
├── server.properties              ← 服务器配置（resource-pack 已清空，见第 5 节）
├── eula.txt                       ← 已写 eula=true，请自行确认你同意 Mojang EULA
├── ops.json / whitelist.json / banned-*.json
└── pvpshot-waypoints.zip          ← 资源包本体（2.7 KB）
```

不含：旧地图 `world/`、玩家客户端缓存（`voxy/`）、日志、Fabric 缓存（`.fabric/`）——
这些要么不需要，要么第一次启动会自动生成。

## 2. 环境要求

| 项目 | 要求 |
|---|---|
| JDK | **25**（必需）。`java -version` 能看到 25 即可；OpenJDK / Microsoft / Temurin 都行 |
| 内存 | 建议 ≥ 4 GB（`start.sh` 默认 `-Xms1G -Xmx3G`，按机器改 `JAVA_MEM_MAX`） |
| CPU | 2 核以上；这个玩法是 tick 敏感的，单核性能比核数重要 |
| python3 | 只有想开资源包下载服务才需要（第 5 节） |
| 系统 | 任意 Linux（Debian/Ubuntu/CentOS/Alpine 均可） |

> **为什么脚本用 `-XX:+UseZGC`**：JDK 25.0.2 的 G1 有个内部崩溃 bug
> （`Internal Error (g1HeapRegionManager.cpp:55) ... master free list MT safety protocol at a safepoint`），
> 会让进程无征兆退出。ZGC 绕开它，低延迟也更适合 20 TPS 的服务端。换更新的 JDK 补丁版也可以。

## 3. 快速开始

```bash
# 1) 上传解压（示例，按实际路径改）
unzip 服务端部署包-linux-26.2.zip -d /opt/pvpshot && cd /opt/pvpshot

# 2) 给脚本执行权限
chmod +x start.sh start-resourcepack-http.sh

# 3) 确认 eula.txt 里是 eula=true（包里已经写好）
cat eula.txt

# 4) 启动（前台；第一次会生成 logs/ 等目录，约 10 秒内出现 "Done ... For help, type help"）
./start.sh

# 5) 客户端连 <服务器IP>:25566
```

想后台常驻，用 screen/tmux 或 systemd（见第 6 节）。
**不要用 root 跑**（MC 服务端不需要 root，且有安全风险）。

## 4. 端口与防火墙

| 端口 | 用途 | 必需 |
|---|---|---|
| **25566/tcp** | 游戏端口（故意避开默认 25565） | 是 |
| 8080/tcp | 资源包下载服务（第 5 节） | 否 |

```bash
# ufw（Ubuntu/Debian）
sudo ufw allow 25566/tcp
sudo ufw allow 8080/tcp          # 只在要用资源包下载服务时

# firewalld（CentOS/RHEL）
sudo firewall-cmd --permanent --add-port=25566/tcp && sudo firewall-cmd --reload
```

云服务器（阿里云/腾讯云/AWS…）还要在**控制台安全组**里放行同样的端口，这一步最容易漏。
校园网内网互通的话，通常不用额外配置。

## 5. 登录方式（默认沿用作者测试服的"皮肤站外置登录"）

`server.properties` 里 `online-mode=true`，`start.sh` 通过 `authlib-injector` 把验证指向
`https://auth.lylighte.cc/skinapi`。玩家需要在启动器里把同一个地址加为"外置登录"并先登录一次，
否则会因为验证失败连不上。

想换成别的登录方式，改 `start.sh`：

* **正版（Mojang）登录**：删掉 `-javaagent:authlib-injector-1.2.8.jar=...` 这一行，`online-mode=true` 保持不变。
* **离线模式**：`server.properties` 里 `online-mode=false`（谁都能用任意 ID 进服，公开服不建议）。

## 6. 资源包（可选，建议开）

不装资源包也能玩，只是定位条上的点位字母会显示成紫黑缺失纹理。要自动分发：

```bash
./start-resourcepack-http.sh          # 8080 端口，把当前目录挂在网上
```

然后把 `server.properties` 改成（`<服务器IP>` 换成你的公网/内网地址，玩家要能访问到）：

```properties
resource-pack=http://<服务器IP>:8080/pvpshot-waypoints.zip
resource-pack-sha1=e37d44ce8a4bde81910fcfddf879680783ce178b
require-resource-pack=false
```

改完重启服务端生效。`require-resource-pack=false` 表示玩家可以拒绝下载（拒绝就看不到字母图标）。
不想开 HTTP 服务的话，也可以把 `pvpshot-waypoints.zip` 直接发给玩家，让他们丢进
`.minecraft/resourcepacks/` 并在"选项 → 资源包"里启用（然后重进一次服务器）。

## 7. 常驻运行

**screen（最省事）**

```bash
sudo apt install -y screen        # 或 yum install screen
screen -S pvpshot -d -m ./start.sh
screen -r pvpshot                 # 进去看控制台；Ctrl+A 然后 D 退出但不关服
# 关服：进去后输入 stop，或者在 RCON 里执行 stop
```

**systemd（推荐，能自动重启）**

```ini
# /etc/systemd/system/pvpshot.service
[Unit]
Description=PVP Shot Minecraft Server
After=network.target

[Service]
Type=simple
User=minecraft
WorkingDirectory=/opt/pvpshot
ExecStart=/opt/pvpshot/start.sh
Restart=on-failure
RestartSec=10
# 内存不够时优先保住服务端，别让 OOM killer 挑到它
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now pvpshot
journalctl -u pvpshot -f          # 看日志
```

## 8. 运维要点

* **关服**：在控制台输 `stop`（别直接 `kill -9`，会丢最近一次存档）。
* **备份**：整包备份 `world-ustc/` 即可（地图 + 数据包 + 复原模板维度都在里面），例如
  `tar czf /backup/pvpshot-$(date +%F).tgz world-ustc/`，建议每天定时跑；
  比赛日人多时也可以 `screen -r pvpshot` 里先输 `save-all flush` 再打包。
* **OP / 白名单**：直接编辑 `ops.json` / `whitelist.json`（改完重启或 `/reload`），
  也可以在控制台用 `op <玩家名>`；`white-list=false` 表示不限制进入。
* **RCON**：包里 `enable-rcon=false`（避免把已知密码带到公网）。要用的话改成 `true`
  并把 `rcon.password` 换成强密码，端口默认 25576（记得只对内网开放）。
* **日志**：`logs/latest.log` 是当前日志，历史会打包成 `logs/日期-序号.log.gz`。

## 9. 玩法与机制（部署后需要知道的）

* **地图与点位**：中区竞技场，A~E 五个占领点 + 红蓝基地 + 大厅（世界出生点）、80 个普通补给箱 + 2 个高级箱。
  三种模式：三点占领 / 五点占领 / 团队死斗，用大厅那面按钮墙切换（测试按钮受记分板 `#test.controls` 门控）。
* **整场复原**：一局结束后会把竞技场从**复原模板维度** `ustc_pvp:template`（在 `world-ustc/dimensions/` 里）
  分批抄回来，默认每 tick 搬 4 片、整场约 140 秒；期间服务器保持可响应。
  **不要删 `world-ustc/dimensions/ustc_pvp/`**，否则复原和"重置战场"就失效了。
* **设施保护**：大厅、基地、据点核心、补给箱等 181 个区域受保护（模组实现），
  保护生效时编辑会被拦下；需要人工改地形时把记分板 `#protection.edit` 置 1，改完置回 0。
* **数据包**：`world-ustc/datapacks/` 下的 `pvpshot`（武器/箱子/部署物等）、`ustc_pvp`（大地图逻辑：点位、模式、复原、重建）
  是玩法必需；`pvpshot-capture`（移植时用过的灌模板工具）与 `pvpshot-cleanup`（一次性清树工具）留着无害，
  但别误跑（`function pvpshot_cleanup:run` 会再清一遍点位附近的树）。
* **watchdog**：`server.properties` 里 `max-tick-time=-1`（关闭看门狗）。复原/重建时单 tick 可能短暂偏高，
  关掉看门狗可以避免被误杀；如果你更希望"卡死自动重启"，可以改回 60000。

## 10. 已知坑（照抄作者的踩坑记录）

1. **ECO（EntityCollisionOptimizer）在超大半径实体查询上会卡死主线程**：
   类似 `@e[...,distance=..1000000]` 的选择器会让服务端卡在原生代码里出不来，只能重启进程。
   正常玩法里的选择器半径都很小（`..2`/`..5`/`..24`），不受影响；
   但你自己写命令方块/脚本排查时，别用大半径 `@e`，改用 `x/y/z` + 小半径。
2. **模组保护每 tick 才刷新一次**：手跑重建函数时，同一 tick 内刚设的 `#protection.edit=1` 还没生效，
   方块编辑会被拦下。正常复位流程里保护本来就是关的，不用管；手动改地图时记得"先设记分板、等一拍、再改"。
3. **服务端一体化 jar 里没有客户端模组**（钠/Iris/小地图等），玩家自己装；
   也**不需要**玩家装任何模组就能进服。
4. 服务端用的模组：`pvpshot` 本体 + 嵌套的 Fabric API、Carpet、spark、ECO、FerriteCore、AppleSkin、Placeholder API。
   其中 Carpet 提供 `/player` 假人、`/tick` 等测试命令，spark 用来抓性能火焰图。

## 11. 出问题先看什么

| 现象 | 先看 |
|---|---|
| 起不来 / 秒退 | 控制台报错；`java -version` 是不是 25；`logs/latest.log`；`logs/hs_err_pid*.log` |
| 玩家连不上 | 端口是否放行（本机防火墙 + 云安全组）；`server.properties` 的 `server-port=25566` |
| 进服提示验证失败 | 第 5 节的登录方式：外置登录要在启动器里先登录皮肤站；或改成正版/离线 |
| 定位条字母是紫黑方块 | 资源包没装：按第 6 节配 `resource-pack=` 或手动分发 `pvpshot-waypoints.zip` |
| 卡顿 / 掉 TPS | `spark profiler start` → 复现 → `spark profiler stop`；确认没人在用大半径 `@e` 查询 |
