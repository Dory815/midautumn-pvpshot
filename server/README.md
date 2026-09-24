# 测试服务端（Fabric 26.2 + pvpshot 模组）

与线上正式服隔离的一台本地测试服，用来验证模组功能与性能开销。

## 配置要点

| 项 | 值 | 说明 |
|---|---|---|
| 端口 | **25566** | 刻意避开默认 25565，避免与其它服务冲突 |
| 正版验证 | `online-mode=true` + `enforce-secure-profile=true` | 只允许正版/认证客户端进入 |
| 人数上限 | 12 | 与线上一致 |
| 视距 / 模拟距离 | 8 / 6 | 与线上一致，便于横向对比 |
| 其它 | `sync-chunk-writes=false`、`max-tick-time=60000` | 降低磁盘等待，贴近线上表现 |

## 装的模组（`mods/`）

| 模组 | 用途 |
|---|---|
| `pvpshot-<版本>.jar` | 本项目模组（保护 / 复原 / 比赛引擎 / 点位可视化） |
| `fabric-api-0.161.0+26.2.jar` | Fabric API（模组依赖） |
| `fabric-carpet-26.2+v260616.jar` | Carpet：`/tick` 冻结与步进、性能相关诊断 |
| `spark-1.10.187-fabric.jar` | spark：火焰图、tick 统计、内存与 GC 诊断（`/spark` 命令） |

> 下载踩坑记录：Modrinth CDN 与 GitHub 用 PowerShell 的 `Invoke-WebRequest` 会被中断，
> 改用系统自带的 `curl.exe` 才成功。以后下载模组遇到同样情况可以照这个办法。

## 世界

`world/` 是从现有校园存档复制过来的，包含：

- 主世界（校园中区及周边）
- `ustc_pvp:template` 私有维度（整场复原用的"地形原件仓库"）
- 数据包 `pvpshot` 与 `ustc_pvp`（模组与数据包当前是**共存**状态）

## 启动

1. 先把 `eula.txt` 里的 `eula=false` 改成 `eula=true`（EULA 由使用者自行确认）；
2. 双击 `start.bat`，或执行：

```powershell
cd D:\MC\MidAutumnMiniGame\server
.\start.bat
```

客户端连接：`localhost:25566`。

## 启动后值得先看的东西

```
/pvpshot protect              保护区域是否载入（应为 181）
/pvpshot match visualize status   点位扫描结果与当前模式
/pvpshot restorestatus        复原任务状态
/tick query                   Carpet 提供的 tick 耗时统计
```
