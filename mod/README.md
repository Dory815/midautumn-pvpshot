# pvpshot 模组工程（M1 骨架，已验证可加载）

服务端专用 Fabric 模组，用来重构原来的 PVP 枪战数据包。

## 环境

| 项 | 值 |
|---|---|
| Minecraft | 26.2 |
| Java | 25（本机：`C:\Users\Lenovo\AppData\Local\Programs\Microsoft\jdk-25.0.2.10-hotspot`） |
| Gradle | 9.7.1（本机：`.tools\gradle-9.7.1`，从腾讯云镜像下载） |
| Fabric Loom | `1.17-SNAPSHOT`（实际解析为 1.17.21） |
| Fabric Loader | 0.19.5 |
| Fabric API | 0.161.0+26.2 |
| 映射 | **不需要**（见下） |

## 构建与运行

```powershell
.\build.ps1 build        # 构建，产物在 build\libs\pvpshot-<版本>.jar
.\build.ps1 runServer    # 启动开发用服务端
```

首次启动服务端前，需要自己确认一次 EULA：把 `run\eula.txt` 里的 `eula=false` 改成 `eula=true`
（这是法律确认，本项目不代为同意）。

## 关键技术事实（26.x 与旧版本的差别，已实测）

1. **Minecraft 26.x 的 jar 不再混淆**。把 `26.2` 的客户端/服务端 jar 打开可以看到
   `net/minecraft/server/level/ServerPlayer.class` 这样的官方名字；官方 version json 里
   因此**没有** `client_mappings` 字段。
2. 连带的后果：**Yarn 没有 26.x 版本**（查询返回 0 条）；Fabric 的 `intermediary` 退化为
   空的 `0.0.0`；Fabric Loader 启动时直接打印 `Mappings not present!`。
3. 所以构建脚本里**不写 `mappings` 行**，依赖用普通 `implementation` 而不是
   `modImplementation`（后者是为"需要重映射"的旧模式准备的）。这与 Fabric 官方示例模组
   `fabric-example-mod` 的写法一致。
4. **Loom 版本要够新**：已发布的 1.17.20 / 1.17.21 / 1.18.2 会报
   `Configuration 'mappings' has no dependencies`；官方示例模组用的是滚动快照
   `1.17-SNAPSHOT`，本工程沿用该版本。Loom 1.18.2 由 Gradle 9.7.0 构建，因此本机配了
   Gradle 9.7.1（原先的 9.5.1 会报 `No matching variant`）。
5. 好处：现有 `server_protection` 里那 694 行 Java 用的就是官方类名
   （`net.minecraft.server.level.ServerPlayer` 等），迁移时可以原样复用。

## 已验证（2026-09-24）

- `.\build.ps1 build` 成功，产出 `pvpshot-1.0.0-m1.jar`（3.4 KB，含 `fabric.mod.json` 与两个类）。
- `.\build.ps1 runServer` 实测加载：`Loading Minecraft 26.2 with Fabric Loader 0.19.5`、
  `Loading 44 mods`（Fabric API 全模块 + `pvpshot 1.0.0-m1`），模组初始化与事件注册日志均正常。
- 完整开服停在 EULA 确认处（`run\eula.txt`），需作者自行改为 `true`。

## M2a 设施保护（已实现，待运行时验证）

把旧插桩模块的 181 个保护区域搬进了模组：

- 区域数据：`src/main/resources/pvpshot/regions.tsv`（从 before 的 `protection/regions.tsv` 原样复制）。
- 判定逻辑：`pvpshot.protect.ProtectionRegions` —— 按区块分桶做 O(1) 查找；
  保护总开关每 tick 刷新一次（读记分板 `ustc.clock` 上的 `#protection.active` 等三项），
  避免每次方块更新都查询记分板。
- 拦截点（与旧插桩一一对应，改成了标准 Mixin）：

| Mixin | 目标方法 | 作用 |
|---|---|---|
| `LevelMixin` | `Level#setBlock(...II)Z` | 所有方块写入的总闸口 |
| `LevelMixin` | `Level#destroyBlock(...)Z` | 所有方块破坏的总闸口 |
| `ServerPlayerGameModeMixin` | `ServerPlayerGameMode#destroyBlock(BlockPos)Z` | 玩家挖掘（避免耐久/统计照走） |
| `BlockStateBaseMixin` | `BlockBehaviour$BlockStateBase#onExplosionHit(...)` | 爆炸对方块的影响（对玩家的爆炸伤害保留） |
| `PistonBaseBlockMixin` | `PistonBaseBlock#isPushable(...)` | 活塞推动 |
| `BlockInputMixin` | `BlockInput#place(ServerLevel, BlockPos, int)` | 命令放置（`/setblock`、`/fill`） |

沿用旧实现的关键细节：**只有"换成另一种方块"才拒绝**；按钮、箱盖、门、红石的
同种方块状态更新照常放行，否则设施会失去交互能力。

> 说明：Mixins 的目标签名已逐个用 `javap` 与 26.2 反编译源码核对；
> 运行时行为（Mixin 是否成功应用）需要在能开服时再验证一次。

## 读源码的方式（后续复用原版逻辑用）

`.\build.ps1 genSources` 会生成 Minecraft 26.2 的反编译源码（Vineflower），
产物在 `mod\.gradle\loom-cache\minecraftMaven\net\minecraft\minecraft-merged-*-sources.jar`。
本项目已把它解压到 `D:\Programs\.tmp\mmg\mcsrc`，可以直接用文本搜索查原版实现
（例如投射物运动、碰撞检测、指令复制方块的实现）。

## 设计约束（务必遵守）

- **`environment: server`**：模组只装在服务端，玩家端零安装（原版客户端可直接连）。
- **不做的事**：不注册自定义物品/方块/实体/粒子/音效/容器类型——这些会让原版客户端连不上；
  也不向未安装对应 Mod 的客户端发送自定义网络包（C 档客户端增强会先判断 `canSend`）。
