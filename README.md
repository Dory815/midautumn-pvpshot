# 中秋校园枪战小游戏（Minecraft 26.2 · Fabric 服务端模组版）

把原先用**数据包**写的校园枪战小游戏，重构为 **纯服务端 Fabric 模组**：
玩家端**零安装**（原版 26.2 客户端直连即可玩），地图、点位、出生点、设施保护与整场复原机制全部沿用原设计。

## 目录导览

| 目录 | 内容 |
|---|---|
| `mod/` | 模组源码（`pvpshot`，Java + Mixin）。构建：`powershell -File mod\build.ps1 build` |
| `server/` | 测试服务端：`world-ustc/` 是当前地图（含 `ustc_pvp:template` 复原模板维度与全部数据包），`mods/` 放一体化 jar |
| `specs/` | `PRD.md`（需求 + 逐次变更记录）、`SPEC.md`（设计细节） |
| `docs/` | `更新日志.md`、压测报告、反编译说明、崩溃记录等 |
| `tools/` | 打包脚本（客户端整合包 / Linux 服务端包）、压测工具、数据包补丁、资源包生成 |

## 快速开始

* **自己搭服（Linux）**：看 `tools/server-package/README-部署.md`，或直接用
  `tools/server-package/make-server-package.ps1` 生成整包（启动器 + 依赖 + 模组 + 地图 + 脚本）。
* **客户端整合包**：`tools/package-client-pack.ps1`（含多人列表、模组配置、小地图与 Voxy 数据）。
* **玩法与改动明细**：`docs/更新日志.md`（面向玩家/管理员）、`specs/PRD.md` 第 12 节（逐条变更记录）。

## 构建与测试

```powershell
# 生产构建（默认**不含**测试用模组：Carpet / spark）
powershell -NoProfile -ExecutionPolicy Bypass -File mod\build.ps1 build

# 本机测试服需要假人/性能分析时，把测试模组一起打进去
powershell -NoProfile -ExecutionPolicy Bypass -File mod\build.ps1 build -PwithTestMods
```

产出的 `mod/build/libs/pvpshot-<版本>.jar` 就是一体化服务端模组：内部嵌套
Fabric API、FerriteCore、ECO、AppleSkin、Placeholder API（用 `-PwithTestMods` 时再加 Carpet、spark）。
服务端只需要这一颗 jar；客户端不需要装任何模组。

## 已知注意事项

* **ECO（EntityCollisionOptimizer）对超大半径实体查询会卡死主线程**：别在命令方块/脚本里写
  `@e[...,distance=..1000000]` 这类选择器，用 `x/y/z` + 小半径代替。
* **复原机制**：一局结束后从 `ustc_pvp:template` 维度分批把竞技场抄回来，**不要删该维度**。
* **设施保护**：比赛期间大厅/基地/据点核心/补给箱等 181 个区域受保护，人工改地形前先把记分卡
  `#protection.edit` 置 1，改完置回 0（模组每 tick 刷新一次保护状态）。
* 测试服用的 JDK 25.0.2 的 G1 有内部崩溃 bug，启动参数用 `-XX:+UseZGC` 绕开（脚本里已带）。
