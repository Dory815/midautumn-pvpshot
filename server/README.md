# 测试服务端（Fabric 26.2 + pvpshot 模组）

与线上正式服隔离的一台本地测试服，用来验证模组功能与性能开销。

## 配置要点

| 项 | 值 | 说明 |
|---|---|---|
| 端口 | **25566** | 刻意避开默认 25565，避免与其它服务冲突 |
| 正版验证 | `online-mode=true` + `enforce-secure-profile=true` | 只允许正版/认证客户端进入 |
| 人数上限 | 12 | 与线上一致 |
| 视距 / 模拟距离 | **32 / 8**（2026-09-25 起临时，单人看远景用） | 原值 10 / 8；堆内存同时从 1G/3G 提到 2G/6G。测完把 `view-distance` 改回 10、`start.bat` 改回 `-Xms1G -Xmx3G` 即可 |
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
