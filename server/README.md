# 测试服务端（Fabric 26.2 + pvpshot 模组）

与线上正式服隔离的一台本地测试服，用来验证模组功能与性能开销。

## 配置要点

| 项 | 值 | 说明 |
|---|---|---|
| 端口 | **25566** | 刻意避开默认 25565，避免与其它服务冲突 |
| 正版验证 | `online-mode=true` + `enforce-secure-profile=true` | 只允许正版/认证客户端进入 |
| 人数上限 | 12 | 与线上一致 |
| 视距 / 模拟距离 | **10 / 8** | 作者要求（测试用，比线上的 8 / 6 更高）；2026-09-25 曾临时调到 32 看远景，已按作者要求改回 10 |
| 其它 | `sync-chunk-writes=false`、`max-tick-time=60000` | 降低磁盘等待，贴近线上表现 |

> **GC 选择（2026-09-25 变更）**：启动参数从 G1 换成 **ZGC**（`-XX:+UseZGC`）。
> 原因是 JDK 25.0.2 的 G1 出现内部崩溃（`g1HeapRegionManager.cpp:55`，
> "master free list MT safety protocol at a safepoint"，栈里只有 jvm.dll 帧），
> 详见 `docs/崩溃记录-2026-09-25-G1内部错误.md`。同时加了
> `-XX:ErrorFile=logs\hs_err_pid%p.log`，以后崩溃现场统一落在 `logs/`。

## 装的模组（`mods/`）

| 模组 | 用途 |
|---|---|
| `pvpshot-<版本>.jar` | **一体化 jar**：本项目模组 + 嵌套的 Fabric API / Carpet / spark / Entity Collision Optimizer。部署时 `mods/` 只放这一个文件即可。 |

> 一体化用 Fabric 的 jar-in-jar（`META-INF/jars/` + `fabric.mod.json` 的 `jars` 列表）。
> 构建方式见 `mod/build.gradle`：Fabric API 用官方坐标 `include`，另外三个先在
> `mod/make-local-maven.ps1` 里摆成本地 Maven 仓库再 `include local:<名>:<版本>`。
> 想拆开某一个模组：删掉 build.gradle 里对应那行 `include` 重新 build 即可。
> 单独下载的四个 jar 备份在 `mods-standalone-backup/`（不再被加载）。

嵌套进来的三个第三方组件：

| 组件 | 用途 |
|---|---|
| Fabric API 0.161.0+26.2 | 模组依赖（必须） |
| Carpet 26.2+v260616 | `/tick` 冻结与步进、性能诊断 |
| spark 1.10.187 | 火焰图、tick/内存/GC 诊断（`/spark`） |
| Entity Collision Optimizer 1.0.0-mc26.2-alpha.7 | 朋友的实体碰撞优化模组（作者 water2004，MIT，[仓库](https://github.com/water2004/EntityCollisionOptimizer)）：FFM 原生后端，自带三平台原生库；`/eco check` 显示 `FFM initialized=true` |
| AppleSkin 3.0.10 / FerriteCore 9.0.0 / Placeholder API 3.1.0 / Xaero 小地图 26.5.1 / Xaero 世界地图 1.46.1 | 从作者客户端实例里**原样复制**的 5 个 `env=*` 模组（带服务端组件）。服务端装它们只是让"装了对应客户端模组的人"获得完整功能（饥饿值 HUD、地图与航点共享、内存优化等）；**没装的玩家完全不受影响**，服务器不会因为这些模组要求客户端装东西。 |

> **客户端可选性说明**：上面所有嵌套模组只有两种——① 纯服务端逻辑（保护 / 复原 / 玩法 / 碰撞优化 / FerriteCore 内存优化）；
> ② 服务端侧只"多发一点可选数据"（AppleSkin 的饥饿同步、Xaero 的地图支持）。
> 服务端从不发"必须处理"的包；Fabric 默认会把客户端没注册的 payload 直接丢弃，
> 因此**原版（未装任何模组）客户端可以正常进服游玩**，只是看不到这些额外 HUD。
> 本项目的战斗视觉（伤害数字 / 头顶血条 / 尸体）全部用原版实体实现，原版客户端一样能看到。

### 只在客户端、**不需要**装到服务端的模组

作者客户端 `中秋校园枪战小游戏` 里这些模组的 `fabric.mod.json` 写着 `"environment": "client"`，
在专用服务器上 Fabric 会直接跳过（装了也不生效），所以**不要**放进服务端：

`sodium`（钠）、`iris`、`immediatelyfast`、`modmenu`、`imblocker`、`mousetweaks`、
`voxy`（渲染 LOD）、`chat_heads`（聊天头像）、`morechathistory`（更多聊天记录）。

其中聊天头像/更多聊天记录是纯客户端 HUD（已确认 jar 里没有服务端通信通道），
服务端无需任何配合；聊天头像只会给**玩家自己发出的聊天**加头像，系统消息（含游戏内计分/击杀播报）
没有玩家档案，所以不会带头像 —— 想要游戏播报也带头像需要改成"以玩家身份发送聊天"，属于额外改造。

### 纯原版（零模组）客户端能不能进？—— 能，但要按下面的方式登录

| 情况 | 能不能进 | 说明 |
|---|---|---|
| 原版客户端（**不装任何模组**）+ 启动器里用 **LyerSkin 外置登录** | ✅ **可以** | 启动器会自动给客户端加 authlib-injector（这是登录代理，不是模组），客户端本身保持原版。进服后一样能看到伤害数字 / 头顶血条 / 尸体（这些走原版实体渲染）。 |
| 原版客户端 + **微软正版账号** 或 离线昵称 | ❌ 不行 | 服务器是 `online-mode=true`，且验证被 authlib-injector 转到了 LyerSkin；拿不到 LyerSkin 会话就会被拒（"Failed to verify username"）。 |
| 装了任意客户端模组（钠 / Iris / 聊天头像 …） | ✅ 可以 | 客户端模组纯属个人体验，服务端不检查。 |

自检方法（不需要启动游戏）：

```powershell
python tools\server-status.py <服务器IP> 25566
```

输出里 `版本: 26.2 protocol 776`、`服务端上报的模组信息: 无` 就说明服务器对客户端**没有任何模组要求**，
原版客户端的服务器列表能看到它。

## 认证：LyerSkin 外置登录

服务器保持 `online-mode=true`，认证由 **authlib-injector 1.2.8** 转到 LyerSkin 皮肤站：

```
-javaagent:authlib-injector-1.2.8.jar=https://auth.lylighte.cc/skinapi
```

玩家侧（HMCL / PCL 等）：先在 <https://auth.lylighte.cc/> 注册并创建角色，
再在启动器里"添加外置登录"填 `https://auth.lylighte.cc/skinapi`，登录后选该角色启动 26.2。
离线（盗版）昵称无法进入。启动日志里 `Environment: Environment[sessionHost=http://127.0.0.1:<端口>/...]`
就是 authlib-injector 生效的标志。

## 对外入口与防火墙

| 用途 | 地址 | 说明 |
|---|---|---|
| 游戏 | `<服务器IP>:25566` | 本机校园网（eduroam / 以太网）地址；换网或重启后 IP 可能变，用 `ipconfig` 核对 |
| 资源包 | `http://<服务器IP>:8080/pvpshot-waypoints.zip` | 由 `python -m http.server 8080` 提供（工作目录 `server/`）；仅用于定位条 A~E 图标，下载失败也能进服 |

防火墙：`java.exe`（游戏）与 `python.exe`（资源包）在 **Public** 配置文件上已有入站放行规则
（校园网被 Windows 识别为"公用网络"），因此无需再加规则。若以后换机器或换 JDK 路径需要手加：

```powershell
New-NetFirewallRule -DisplayName "PVP Shot Test Server 25566" -Direction Inbound `
  -Protocol TCP -LocalPort 25566 -Action Allow -Profile Any
```

> 说明：ECO 是**第三方模组**，本项目只是把它装到测试服上做性能对照；它的 jar 与 release 校验和
> （`SHA256SUMS.txt`）都来自官方仓库的 release 页，下载后已核对 SHA-256 一致。

> 下载踩坑记录：Modrinth CDN 与 GitHub 用 PowerShell 的 `Invoke-WebRequest` 会被中断，
> 改用系统自带的 `curl.exe` 才成功。以后下载模组遇到同样情况可以照这个办法。

## 世界

`world/` 是从现有校园存档复制过来的，包含：

- 主世界（校园中区及周边）
- `ustc_pvp:template` 私有维度（整场复原用的"地形原件仓库"）
- 数据包 `pvpshot` 与 `ustc_pvp`（模组与数据包当前是**共存**状态）

## 启动

1. `eula.txt` 已由作者明确指示置为 `true`；
2. 双击 `start.bat`，或执行：

```powershell
cd D:\MC\MidAutumnMiniGame\server
.\start.bat
```

客户端连接：`localhost:25566`。

> 若要从其它设备连接，需要放行防火墙（需管理员权限的 PowerShell）：
> ```powershell
> New-NetFirewallRule -DisplayName "PVP Shot Test Server 25566" -Direction Inbound `
>   -Protocol TCP -LocalPort 25566 -Action Allow -Profile Any
> ```

## OP

`ops.json` 里已加入作者账号 **Dory815**（level 4），进服即可使用 `/pvpshot` 系列命令。
白名单当前关闭，其它正版账号也能进入。

## 启动后值得先看的东西

```
/pvpshot protect              保护区域是否载入（应为 181）
/pvpshot match visualize status   点位扫描结果与当前模式
/pvpshot restorestatus        复原任务状态
/tick query                   Carpet 提供的 tick 耗时统计
```
