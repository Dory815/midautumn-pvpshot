# SPEC · 用纯服务端 Fabric 模组重构枪战小游戏

> 本文是实现前的事实核对与技术设计。结论都附了验证方式，可复查。
> 面向读者：项目作者（物理系本科生，粗通 Java，不熟悉前端）。
> 需求与验收标准见同目录 [PRD.md](PRD.md)。

---

## 0. 结论速览

| 问题 | 结论 |
|---|---|
| 能不能用**纯服务端**模组重构？ | **能。**现有玩法的每一项判定都在服务端，没有任何一项必须由客户端计算。 |
| 玩家还要不要装 Mod？ | **不用。**原版 26.2 客户端直连即可完整体验（与现状一致）。 |
| 客户端 Mod 有没有价值？ | **有，但纯属增强**：HUD 数字、命中反馈、后坐力/开镜、自定义按键、更细的声音定位。列为可选档 C。 |
| 性能能从根子上解决吗？ | **能。**数据包的性能问题来自"每 tick 用命令轮询 + NBT 匹配 + 逐格命令"，换 Java 后这些全部消失。 |
| 现有 Java 代码要重写多少？ | 业务逻辑（伤害、判定、生命周期）**大头可复用**；挂载方式（插桩 → Mixin/事件）**必须重写**。 |
| 主要代价 | 需要重建构建/发布流程；需要一批新的 Mixin 适配点；视觉表现要靠资源包和粒子，不如真客户端 Mod 华丽。 |

---

## 1. 事实核对

### 1.1 版本与环境（来自 `开发框架与服务器汇总-2026-09-23.md` 与线上只读查询）

| 项目 | 值 | 验证方式 |
|---|---|---|
| Minecraft | 官方 Java **26.2**，协议 776，数据包格式 107.1 | 服务器日志与 `pack.mcmeta` 的 `min_format/max_format: [107,1]` |
| Java 运行时 | OpenJDK **25**（本地与线上一致） | 服务器启动日志 |
| 服务端 | 官方 `server.jar`（非 Paper/非 Fabric） | `发布/测试服务端/server.jar`，58.1 MB |
| 认证 | LyerSkin `https://auth.lylighte.cc/skinapi` + authlib-injector 1.2.8 | 玩家教程与服务器配置 |
| 线上 | `<服务器IP>:28898`，Ubuntu 24.04，`-Xmx3G`，上限 12 人 | 只读状态查询 |
| 客户端 Mod | **当前为零** | 玩家教程只要求 HMCL + LyerSkin 登录 |

### 1.2 现有代码规模（实测）

| 部分 | 规模 | 说明 |
|---|---|---|
| `pvpshot` 数据包 | 216 个 `.mcfunction`，265 KB | 通用玩法 |
| `ustc_pvp` 数据包 | 580 个 `.mcfunction`，2.18 MB | 其中 176 个是地形复原批次目录 |
| 合计 | **796 个 `.mcfunction`** | 另加 101 个 JSON（物品、谓词、伤害类型、结构） |
| Java 模块 | 5 个类，**694 行** | `ProtectionAgent` 118、`ProtectionRules` 82、`GameplayBridge` 24、`GameplayRules` 236、`GameplayV8` 234 |
| Python 工具 | 22 个脚本 | 生成器、世界构建、打包、部署、状态查询 |
| 玩法配置 | 36 个 loot_table | 每种武器一份 |

### 1.3 性能瓶颈定位（逐条附证据，可复查）

| # | 现象 | 位置 | 为什么慢 |
|---|---|---|---|
| 1 | 每 tick 全员轮询 | `ustc_pvp:tick.mcfunction`：8 次 `as @a` + 5 次 `scoreboard players enable @a` | 命令选择器要遍历实体列表并逐个求值；轮询是人类写游戏逻辑的下策，但数据包只能这样 |
| 2 | 单文件 137.9 KB | `pvpshot/function/deploy/check_bunker.mcfunction` | 生成器暴力展开的放置检查；一次调用即数千条命令 |
| 3 | 弹体小步扫描 | `pvpshot/function/shot/step.mcfunction`（7 条命令/步）+ `shot/tick.mcfunction`（每 tick 循环 5 步） | 每弹体每 tick ≈ 35~50 条命令，且含 `as @a[distance=..1.5]` 选人 |
| 4 | 每 tick NBT 匹配 | `pvpshot/function/combat/proj_tick.mcfunction` | `nbt={Item:{components:{"minecraft:custom_data":{...}}}}` 需序列化实体数据后比较 |
| 5 | 地形复原命令化 | `ustc_pvp/function/reset/batch_0..175/copy.mcfunction`，每份 9.8 KB | 逐格 `clone`/`setblock`，176 批串行 |
| 6 | 大体积维护脚本 | `ustc_pvp/build.mcfunction` 42.1 KB、`v8/ready.mcfunction` 23.7 KB、`protection/repair.mcfunction` 22.8 KB | 地图改动只能靠重新生成整批函数 |

**推算**：单人时 tick 平均 2.0 ms（P95 2.3 / P99 4.9）。这条链路的开销随"实体数 × 命令数"增长，12 人交火时弹体、部署物、掉落物、爆炸同时增多，是当前的主要风险点。

### 1.4 现有 Java 模块的处境（迁移时最需要理解的一段）

现在这个模块（`server_protection/`）用的是 **Java 25 的 Instrumentation + Class-File API**：在类加载时把官方 `server.jar` 里的方法改掉，插进自己的调用。它做了两件事：

1. **保护**（`ProtectionRules`）：拦截方块放置/破坏/爆炸/活塞/命令放置，按 `regions.tsv` 的 181 个区域判定是否放行。已按区块建索引，本身不慢。
2. **玩法**（`GameplayRules` / `GameplayV8`）：弓弩射线与近炸、风弹、温雷、战斗机、SMG、霰弹枪、三种重武器、掉落物拦截、玩家 tick 与离线处理。

它的脆弱点，代码里写明了两处：

- 启动时**硬编码官方 jar 的 SHA-1**（`823e2250…`），不匹配就拒绝启动；
- 每个类要求**精确的挂钩数量**（`Expected N hooks, found M`），不匹配直接 `Runtime.halt(78)`。

这说明作者已经在用"非官方支持的方式"给官方服务端加玩法。**Fabric 提供的就是这件事的官方做法**：Mixin 用于改方法行为，Fabric API 用于事件与命令注册。迁移不是"从零重写"，而是**把挂载方式换成标准做法，把业务代码搬过来**。

### 1.5 兼容性事实（决定架构的硬约束）

| 事实 | 影响 |
|---|---|
| 数据包现在提供 `ustc_pvp:template` 自定义维度（`dimension/template.json`，flat + the_void）作为复原原件 | 模组方案可以直接沿用该维度，无需重建 |
| 世界存档格式在 26.2 内一致 | Fabric 服务端能直接打开现有世界，玩家数据、点位 marker、保护区配置都在 |
| 玩法状态几乎全部存在记分板/命令存储/实体标签/物品组件 | 可以在模组里保留读取能力，实现**平滑迁移**（先接管一部分，另一部分仍走旧数据包） |

---

## 2. 关键判断：纯服务端可行性逐项对照

这是本文最重要的一张表。判定标准：**原版客户端能不能看见/理解**，以及**服务端能不能独立算完**。

| 现有功能 | 现在的实现 | 纯服务端模组能不能做 | 具体做法 |
|---|---|---|---|
| 模式/计分/胜负 | scoreboard + tick 函数 | ✅ 更容易 | Java 内存状态机 + `SavedData` 存档 |
| 队伍、颜色、友伤 | scoreboard team | ✅ | `Scoreboard` API 或自建队伍模型 |
| 大厅菜单与入队 | 容器 GUI + `/trigger` | ✅ | 原版容器类型（如箱子菜单）+ 服务端拦截点击；或 26.2 的原版对话框 |
| 开局发装 | loot_table | ✅ | Java 直接构造 `ItemStack`（更可控） |
| 死亡识别与前线复活 | 比较死亡计数 | ✅ 更准 | 原生死亡事件；复活点候选规则直接写成算法 |
| 火焰弹 / 破拆火箭 | `item_display` 弹体 + 小步扫描 | ✅ 更快更准 | 一次几何射线（`Level#clip`）+ 粒子表现弹道 |
| SMG 连射 | Java 玩家 tick + 数据包弹体 | ✅ | 服务端输入检测 + 射速计时 |
| 霰弹枪 / 轨道 380 / 飞鹰 500 / 空爆 | Java 射线 | ✅ | 现有逻辑直接搬到模组 |
| 弓弩（含近炸、单弩限制） | 原生实体 + Java 挂钩 | ✅ | Mixin 到箭的 tick/命中；保留原版曲线与结算 |
| 雪球 / 鸡蛋 / 三叉戟 | NBT 匹配扫描 | ✅ 更快 | 实体生成事件 + 命中事件 |
| 手雷 / 温雷 | Java + 原生 TNT | ✅ | 直接移植计时与投掷 |
| 战斗机 | Java + 鞘翅 + TNT | ✅ | 直接移植；鞘翅与缓降都是原版机制 |
| 炮 / 炮塔 | 数据包结构 + 137 KB 检查函数 | ✅ 大幅改善 | 方块读写 + 结构放置 API，检查改成体积枚举 |
| 补给箱（80 + 2） | loot_table + 计时 + 保护 | ✅ | 服务端定时任务 + 原版容器 |
| 高级箱概率抽取 | loot_table 权重 | ✅ | Java 随机 + 权重表 |
| 设施保护（181 区域） | 插桩挂钩 | ✅ 更稳 | Mixin + 区块索引（现有 `ProtectionRules` 思路可移植） |
| 整场地形复原 | 176 批命令 | ✅ 大幅改善 | 读模板维度区块数据直接写入 + 分帧预算 |
| 命中发光 / 脱战回血 / 饱食度 | 数据包 | ✅ | 原生效果与属性 API |
| 比分 Bossbar / 点位条 | 数据包 | ✅ | `BossBar` API |
| 掉落物清理 | 三层拦截 | ✅ 更干净 | 实体生成事件里直接拒绝 |
| 武器数值配置 | 生成器脚本 + 覆盖层 | ✅ | 单一 JSON + 常量 |
| 枪械外观（模型/贴图） | 无 | ⚠️ 需资源包 | 服务器下发资源包；**仍不需要客户端 Mod** |
| 枪声 | 原版音效 | ⚠️ 需资源包 | 覆盖原版已有音效的音频文件 |
| 弹药 HUD 数字、准星旁信息 | 无 | ❌ 原版客户端不可定制 | 只能用 actionbar / Bossbar / 物品 tooltip 近似；真正的 HUD 需客户端 Mod |
| 后坐力、开镜、第一人称动画 | 无 | ❌ | 需客户端 Mod |
| 命中反馈（hitmarker）、伤害数字 | 无 | ❌ | 需客户端 Mod |
| 自定义实体（如"子弹实体"） | 用 `item_display` | ⚠️ **不要做** | 新增实体类型会让原版客户端连接失败/显示异常；必须复用原版实体或用纯服务端虚拟弹体 |

**结论**：唯一"做不到"的只有**纯观感与手感**的部分，而它们恰好是"不做也不影响公平与完整玩法"的部分。**核心玩法 100% 可以纯服务端实现。**

---

## 3. 原版客户端的能力边界（决定设计自由度）

### 3.1 原版客户端就能看到的（大胆用）

- **物品**：任意原版物品 + `custom_data` 标记身份 + 名称/描述/附魔光效/属性修饰符；`item_model` 组件可指向资源包里的自定义模型。
- **实体**：所有原版实体类型，包括 `item_display`、`block_display`、`text_display`、`marker`、`interaction`、`armor_stand`。
- **粒子**：原版粒子类型（火焰、烟、暴击、末影、尘土着色等）可自由组合出枪口火光、弹道轨迹、爆炸、命中火花。
- **音效**：原版音效库。
- **UI**：聊天、actionbar、title/subtitle、Bossbar、记分板侧栏、原版容器界面、26.2 的原版对话框（数据包驱动的原生 UI）。
- **效果**：状态效果、发光、属性修改、队伍颜色与友伤规则。

### 3.2 需要服务器资源包（仍然不需要 Mod）

- 枪械/装备的**模型与贴图**（通过 `item_model` / `custom_model_data` 指向自定义模型）。
- **音效替换**：资源包可覆盖原版音效的音频文件，因此可以把某个原版音效换成真实枪声。
  - 限制：**不能新增独立音效 ID**，只能覆盖已有音效；因此"不同枪用不同音效"要靠选择不同的原版音效槽位。
- UI 贴图替换（准星、按钮等），以及语言文本。
- 资源包由服务器下发（`server.properties` 的 `resource-pack` / `resource-pack-sha1` / `require-resource-pack`），Fabric 服务端同样适用。

### 3.3 必须客户端 Mod 才能做的

- 自定义 HUD 元素（弹药数字、血条、击杀播报面板）——原版协议里没有给服务端"画 HUD"的通道。
- 第一人称视角动画、枪械模型动画、后坐力、开镜视野、镜头抖动。
- 命中反馈特效（hitmarker）、飘字伤害数字。
- 自定义按键绑定（如独立换弹键）。
- 客户端预测（在自己这台机器上先把动作演出来，再等服务端确认），用于降低延迟感。

这些统一归入**档 C**：客户端的 `HudRenderCallback` / 渲染事件里画，数据由服务端通过自定义网络包供给。

### 3.4 可选客户端增强的通信用法（关键）

原版客户端不认识自定义网络包。若服务端无条件发送，会因为"客户端未注册该通道"而报错甚至断开连接。

正确做法：

```java
// 只在客户端确实装了对应 Mod（声明过该通道）时才发送
if (ServerPlayNetworking.canSend(player, PvpShotNet.HUD_STATE)) {
    ServerPlayNetworking.send(player, new HudStatePayload(...));
}
```

`canSend` 由 Fabric 在握手阶段协商，因此**同一个服务端可以同时服务装了和没装 Mod 的玩家**。这是档 C 能安全存在的前提。

---

## 4. 技术选型

### 4.1 为什么是 Fabric 服务端模组（而不是别的）

| 方案 | 评价 |
|---|---|
| 继续用数据包 | 天花板已到：性能与可维护性都无法达标 |
| 继续用插桩 hook 官方服务端 | 现状。结论：脆弱（硬编码 SHA-1、精确挂钩计数）、难调试、无法用常规构建链 |
| Paper/Spigot 插件 | 需要等服务端实现跟进 26.2，且会改变原版机制细节（爆炸/伤害/实体行为），与本项目大量依赖的原版结算语义冲突；插件模型对"逐 tick 精确控制"也不如直接改代码 |
| **Fabric 服务端模组** | ✅ 轻量、紧跟官方版本、有官方支持的 Mixin 与事件系统、**支持只装服务端**、能用标准 Java 工具链与 IDE 调试 |

### 4.2 版本与依赖（**待核实项**，见第 9 节）

| 项 | 计划 | 状态 |
|---|---|---|
| Minecraft | 26.2（与现状一致） | 已确认 |
| Java | 25（与现状一致） | 已确认 |
| Fabric Loader | 支持 26.2 的版本 | **需现查** | 
| Fabric API | 对应 26.2 的版本 | **需现查** |
| 映射 | Yarn 或官方 Mojang mappings | 建议用官方 mappings：现有 Java 代码全部按官方类名写（`net.minecraft.server.level.ServerPlayer` 等），可**直接复用** |
| 构建 | Gradle + fabric-loom | 标准模板 |

> 说明：现有 `server_protection` 的代码用的是官方名称（`ServerLevel`、`ServerPlayer`、`AbstractArrow`、`DamageSource`…）。选**官方 mappings** 可以让这 694 行逻辑几乎原样搬进模组，这是重要的迁移捷径。

### 4.3 事件 vs Mixin 的分工

| 需求 | 用什么 | 说明 |
|---|---|---|
| 每 tick 更新（玩家、弹体、计时） | `ServerTickEvents.END_SERVER_TICK` | 事件，安全 |
| 玩家加入/离开/死亡/复活 | `ServerPlayConnectionEvents`、`ServerPlayerEvents`、原生事件 | 事件 |
| 注册命令 | `CommandRegistrationCallback`（fabric-command-api-v2） | 事件 |
| 右键使用物品 / 攻击实体 / 破坏方块 | `UseItemCallback`、`UseBlockCallback`、`AttackEntityCallback`、`PlayerBlockBreakEvents` | 事件优先 |
| 爆炸影响方块 | Mixin（`BlockStateBase#onExplosionHit` / `Explosion`） | 需要精确干预，事件不覆盖 |
| 活塞推动 / 命令放置方块 | Mixin（`PistonBaseBlock#isPushable`、`BlockInput#place`） | 沿用现有思路 |
| 方块变化统一拦截（保护核心） | Mixin（`Level#setBlock` / `Level#destroyBlock`） | 与现有 `ProtectionRules` 对应 |
| 箭的飞行与命中（近炸、单弩限制） | Mixin（`AbstractArrow#tick/onHitEntity/onHitBlock`） | 与现有挂钩一一对应 |
| 掉落物拦截 | 实体生成事件或 `ServerLevel#addFreshEntity` 的 Mixin | 事件够用就优先事件 |

原则：**能用事件就不用 Mixin；必须改原版方法行为时才用 Mixin，并且把 Mixin 类写得尽可能薄（只做转发），逻辑放在普通 Java 类里**。这样出问题时容易定位，也避免"挂钩数量不匹配就整套崩"的老问题。

### 4.4 明确不做的事（避免踩坑）

1. **不注册自定义物品、方块、实体类型、粒子、音效、附魔、容器菜单类型**——这些都会进入注册表同步，原版客户端无法接受。
2. **不向未声明通道的客户端发送自定义网络包**（必须先 `canSend`）。
3. **不在 Mixin 里写业务逻辑**（只做转发）。
4. **不用记分板当状态仓库**（改用内存结构 + `SavedData`/数据附件），仅在需要与原版或旧数据包兼容时读写记分板。

---

## 5. 架构设计

### 5.1 模块划分

```
pvpshot（模组）
├── 入口与注册        PvpShotMod：事件、命令、配置加载
├── config            配置（武器数值、地图点位、保护区、补给规则）
├── arena             场地数据：点位、基地、大厅、复活候选、保护区
├── match             模式、计分、胜负、Bossbar
├── lobby             大厅、入队、开局发装、模式切换
├── player            玩家状态：命中发光、回血、饱食度、掉落清理、离线清理
├── weapon            武器定义与使用入口
│   ├── hitscan       射线类：火焰弹、SMG、霰弹枪、重武器、弓弩的近炸部分
│   ├── projectile    投射物类：雪球、鸡蛋、三叉戟、风弹
│   └── deployable    部署类：炮、炮塔、掩体
├── projectile        虚拟弹体（位置/速度/扫掠线段命中/生命周期/粒子表现）
├── supply            普通箱与高级箱（补货计时、概率、保护）
├── vehicle           战斗机（起飞、弹药、限时、退出清理）
├── restore           地形复原（模板读取、分帧写入、进度反馈）
├── protect           设施保护（区块索引、判定入口）
├── ui                提示、Bossbar、对话框/菜单
├── admin             管理命令与状态查询
└── net               档 C：可选客户端通信（HUD/命中反馈/动画指令）
```

### 5.2 建议目录结构

```
MidAutumnMiniGame/
├── before/                 ← 现状参考（只读素材，文本源码纳入 git）
├── specs/                  ← PRD / SPEC / ARCHITECTURE
├── mod/                    ← 新模组工程（Gradle）
│   ├── build.gradle
│   ├── gradle.properties
│   └── src/main/
│       ├── java/…          上面的包结构
│       └── resources/
│           ├── fabric.mod.json
│           ├── pvpshot.mixins.json
│           ├── config/     武器与地图配置 JSON（可热重载）
│           └── data/       仍需数据包提供的内容（维度定义、结构 NBT）
├── tools/                  ← 保留可用的构建/打包脚本（逐步替换生成器）
└── docs/                   ← 部署与运维说明
```

### 5.3 状态与数据

| 数据 | 存哪 | 说明 |
|---|---|---|
| 一局状态（模式、比分、是否结束） | 内存 + `SavedData` | 存档可恢复；重启不丢比赛进度 |
| 玩家状态（队伍、弹药、冷却、连射窗口） | 内存 Map + 数据附件 | 断线重连后按规则重算，不依赖记分板 |
| 场地数据（点位、基地、保护区、复活候选、箱子） | 配置 JSON（单一来源） | 改地图只改 JSON；启动时构建区块索引 |
| 地形原件 | 现有 `ustc_pvp:template` 维度 | 沿用，不重建 |
| 待定/临时任务（延时爆炸、分帧复原、弹体） | 内存队列 | 每 tick 消费；换局时按规则清理 |

### 5.4 主循环（每 tick 做什么）

```
ServerTickEvents.END_SERVER_TICK
├── 1. 遍历在线玩家（O(玩家数)）
│      ├── 输入与武器使用
│      ├── 战斗状态（命中发光计时、脱战回血）
│      └── 载具状态（战斗机）
├── 2. 推进活跃弹体（O(弹体数)，每个一次几何判定）
├── 3. 消费任务队列（延时爆炸、部署、复原分片，带时间预算）
├── 4. 每 N tick：补给、计分、UI 刷新、胜负判定
└── 5. 清理（掉落物、离场玩家残留、换局残留）
```

与旧方案的本质区别：**没有"问一遍世界"的过程**。旧方案每 tick 用命令去问"谁拿着什么、附近有谁、某个值是不是等于 1"，新方案是所有状态都在内存里，直接读字段。

### 5.5 武器统一模型（解决"三套实现路径"的问题）

现在武器有三条实现路径并存，导致改一把枪要先判断它属于哪条。重构后用**一个描述表 + 三个执行器**：

```java
record WeaponSpec(
    String id,              // "fire_charge" / "smg" / "shotgun" ...
    Item   baseItem,        // 用哪个原版物品承载
    DamageMode mode,        // HITSCAN / PROJECTILE / DEPLOY
    float  damage,
    double range,
    int    cooldownTicks,
    int    magazine,        // 0 表示无限
    int    reloadTicks,
    double spread,          // 散布
    int    pellets,         // 弹丸数（霰弹枪 > 1）
    String soundKey,        // 用哪个原版音效槽
    String particleKey
) {}
```

改数值 = 改配置；新增武器 = 加一条记录 + （必要时）一个执行器分支。

### 5.6 弹体方案（性能最关键的一处）

**不用实体，用数据结构：**

```java
record VirtualProjectile(
    UUID owner,
    Vec3 position,          // 当前位置
    Vec3 velocity,          // 每 tick 位移
    int  lifeTicks,         // 剩余寿命
    WeaponSpec spec,
    Consumer<HitResult> onHit
) {}
```

每 tick：
1. 计算 `next = position + velocity`；
2. 用 `Level#clip(from, to, COLLIDER, NONE, null)` 找**方块**遮挡点；
3. 用实体的 `AABB` 与线段 `from→to` 求交，找**最近的玩家**（用 `AABB.inflate()` + 线段求交，配合 `EntityGetter#getEntities(Entity, AABB, Predicate)` 做空间查询，而不是遍历全世界）；
4. 命中则结算伤害/爆炸并移除，否则把 `position = next`；
5. 用粒子把 `from→to` 这段画出来（`level.sendParticles` 只发给附近的玩家）。

收益：
- 每弹体每 tick 的判定次数从"几十条命令"降到"一次射线 + 一次附近实体查询"；
- 高速弹不会穿透（线段判定天然覆盖两帧之间的全部路径，不需要"小步走"补丁）；
- 不需要 `item_display` 实体，也就没有实体数量压力。

### 5.7 地形复原方案（M2b 已实现）

**先摸清现状**（实测数据包）：复原范围 X=-2144…-1569、Z=-1776…-1153、Y=-16…127，
原始做法是 176 个批次目录、共 **2808 条 `clone` 命令**，每条复制一个
`16×72×16` 的柱段（Y 分成 -16..55 与 56..127 两段），模式为 `replace force`；
复原后还要跑 `anchors` → 清理实体 → `build`（42 KB！）→ `apply_preset` → `refill`。

**模组实现**（`pvpshot.restore.ArenaRestore`）：

| 项 | 做法 |
|---|---|
| 粒度 | 与数据包**完全相同**：`16×72×16` 柱段，共 `36×39×2 = 2808` 段（与 2808 条 clone 命令一一对应） |
| 搬运 | **复用原版 `StructureTemplate`**：`fillFromWorld` 读、`placeInWorld` 写；方块实体（箱子内容等）由原版一并还原，不用自己处理 NBT |
| 空气处理 | `ignoreBlocks` 传空列表 → 连空气一起复制，目标区域多出来的方块才会被覆盖 |
| 写入标志 | `Block.UPDATE_CLIENTS`（原版 `/clone` 非 strict 模式实际写入用的值） |
| 分帧 | 每 tick 预算 5 ms（`System.nanoTime` 控制），到点就停，下一 tick 继续 |
| 安全性 | 复原期间自动打开保护的 bypass，否则自己写回去的方块会被自己的保护拦下 |
| 区块 | 每段处理前确保两侧区块已就绪（未加载时 `getBlockState` 会返回空气，导致地形缺失） |
| 顺序 | 上层先做、下层后做，避免下层变化触发上方形状更新 |

**尚未接管**：实体清理、点位 marker 重建（`anchors`/`build`）、模式预设与箱子补充
（`apply_preset`/`refill`）属于比赛状态管理，与 M3 一起做；目前这些仍由旧数据包负责。

**触发方式**：`/pvpshot restore` 开始、`/pvpshot restorestatus` 查进度
（需要管理员权限）。M3 会接入正式的复原流程与进度条 UI。

### 5.8 设施保护方案（M2a 已实现）

已按下列方案实现，见 `mod/src/main/java/pvpshot/protect/ProtectionRegions.java` 与 `pvpshot/mixin/*.java`：

1. 模组初始化时从内置资源 `pvpshot/regions.tsv` 读入 181 个区域，按区块建立
   `Map<Long, List<Region>>` 索引（区块坐标编码为 long 键）；
2. 保护总开关**每 tick 刷新一次**（读记分板 `ustc.clock` 上的 `#protection.active`、
   `#protection.edit`、`#reset.active`），Mixin 里只读内存标志位，不查记分板；
3. 六个拦截点（与旧插桩一一对应）：`Level#setBlock`、`Level#destroyBlock`、
   `ServerPlayerGameMode#destroyBlock`、`BlockBehaviour$BlockStateBase#onExplosionHit`、
   `PistonBaseBlock#isPushable`、`BlockInput#place`；
4. **只拒绝"换成另一种方块"**：按钮、箱盖、门、红石等同一方块的属性变化必须放行，
   否则设施失去交互能力（这一条是从旧实现继承的关键细节）。

与现状的差别：**不再需要硬编码 jar 的 SHA-1、不再需要"挂钩数量校验"**，升级版本时只需重新编译。
尚未验证：Mixin 在真实服务端上的应用情况与运行表现（作者指示暂缓开服/EULA 相关步骤）。

### 5.8.1 编码原则：优先复用原版实现

作者明确要求：能用原版代码的地方就不要再自创一套。已确认可复用的方向：

| 需求 | 原版可复用之处 | 位置 |
|---|---|---|
| 常规投射物（枪械弹丸） | 风弹 `AbstractWindCharge` / `WindCharge` 的直线运动与命中处理 | `net/minecraft/world/entity/projectile/hurtingprojectile/windcharge/` |
| 与玩家的碰撞检测 | 箭矢 `AbstractArrow`（含扫掠式线段判定，避免高速穿透）与末影珍珠 `ThrownEnderpearl` | `.../projectile/arrow/AbstractArrow.java`、`.../throwableitemprojectile/ThrownEnderpearl.java` |
| 区域方块复制（地形复原） | `/clone` 命令的实现：先读源区域状态到内存，再逐格写入，并用 BARRIER 遮蔽源避免复制期间被干扰 | `net/minecraft/server/commands/CloneCommands.java` |
| 结构放置 | `StructureTemplate` / `StructureTemplateManager` | `.../levelgen/structure/templatesystem/` |

工作方式：`.\build.ps1 genSources` 生成 26.2 反编译源码，本项目已解压到
`D:\Programs\.tmp\mmg\mcsrc`，可直接检索原版实现后再动手写。

### 5.9 档 C：客户端可选增强的协议（先设计，后实现）

| 通道 | 方向 | 内容 |
|---|---|---|
| `hud_state` | 服务端 → 客户端 | 弹药、剩余冷却、比分、队伍、连杀等（供 HUD 绘制） |
| `hit_feedback` | 服务端 → 客户端 | 命中/击毁事件（供 hitmarker 与伤害数字） |
| `view_kick` | 服务端 → 客户端 | 开火后坐力、开镜状态（仅视觉） |

规则：
- 所有通道都必须先 `canSend` 判断；
- 客户端 Mod **只能表现**，不能参与判定；服务端永远按自己的计算结算伤害；
- 服务端不得因为玩家装了 Mod 而给予任何优势。

---

### 5.10 比赛引擎（M3 已实现核心）

`pvpshot.match` 三个类，逻辑逐条对照现状数据包写成（不是重新设计玩法）：

| 类 | 职责 |
|---|---|
| `MatchConfig` | 参数常量：半径 9、高度容差 3、占领满值 100（5 秒）、每秒每点 1 分、目标分 600/1000/60 |
| `CapturePoint` | 单点状态：归属（中/红/蓝）+ 进度（-100..100）+ 红蓝人数统计 |
| `MatchEngine` | 点位扫描、主循环、计分、胜负、比分条、模式切换 |

**判定规则复刻自 `pvpshot:point/tick_one` + `point/count`**：

- 参与统计：本方队伍、非旁观、非创造、存活；3D 距离 ≤ 9 格；脚部高度差 ≤ 3 格；
- 人多的那方每 tick 推进 1 点进度，人数相同则冻结；
- 进度跨过 0 先中立化（`owner=0`），再由对方占满（±100）；
- 计分脉冲（每 20 tick）：点归己方**且敌方无人站在点内**才 +1 分；
- 任一方达到目标分即结束（同时到线判定平局）。

**点位数据来源**：不写死在代码里，而是扫描世界中的 marker 实体
（`tag=ustc.point`，点位名取自 `ustc.point.A` 这类标签），
所以地图怎么摆、点位叫什么名字，模组就怎么用——沿用现有地图，不需要改数据包。

**交接安全**：`MatchEngine.enabled` **默认 false**，此时模组完全不干预比赛，
旧数据包照常驱动；实测确认行为一致后再 `/pvpshot match on` 打开，避免两套逻辑同时计分。

**尚未覆盖**：团队死斗的击杀计分（需要玩家死亡/复活事件，与复活规则一起做）、
队伍入队与大厅流程、复活候选筛选。

---

### 5.11 点位可视化（M3 附加功能，已实现）

`pvpshot.match.PointVisuals`。全部在"纯服务端 + 原版客户端"的约束内实现：

| 功能 | 实现 | 为什么这样做 |
|---|---|---|
| 占领**范围边框** | 原版 **火焰粒子**圆环：先用 `Heightmap.MOTION_BLOCKING` 找出点位所在地面，从地面起每 2 格一层（3~7 层，最下层贴地），半径 = 判定半径 `POINT_RADIUS`，36 个采样点里每 4 个插一个**队伍色** `dust` 点标明归属；每 10 tick 重画，且只在点位 64 格内有玩家时画 | 火焰粒子亮、自带闪烁、昏暗环境也显眼（作者反馈"粉尘环又细又暗"）；不动地图方块、不注册自定义粒子 |
| 点位**发光标记 + 定位条航点** | 每个点位一个**隐形史莱姆**（不可见、无 AI、静音、无敌、抗性提升 V），埋在点位中心下方 2 格，外面用 **3×3×3 基岩**包起来；`Entity#setGlowingTag(true)` 决定发光轮廓，队伍 `pvpshot.mark.<id>` 的颜色决定轮廓色；同一个实体把 `waypoint_transmit_range` 设为 1000，就成了**原版定位条航点**，样式 `pvpshot:a`~`pvpshot:e`（服务器资源包里的 A~E 字母图标） | 发光颜色只能来自队伍；原版定位条航点只由 `LivingEntity` 实现，盔甲架（旧方案）太不显眼且会被打；史莱姆埋地下 + 基岩包裹 → 玩家看不见也挖不走 |
| **信标光柱换色** | 把据点信标**上方那一格**的白色染色玻璃换成归属队伍的染色玻璃（红 / 蓝 / 中立白）。原版 `BeaconBlockEntity.tick` 会周期性重扫光柱颜色，玻璃一换光柱自动跟着变，**不需要任何自定义渲染** | 完全复用原版机制。写入点位于受保护的点位核心区内，写入前后临时打开 `ProtectionRegions` 的 bypass，否则会被模组自己的保护逻辑拦下（这正是"染色玻璃放不上去"的原因） |
| **定位条字母换色** | 归属变化时重建一次航点连接（`ServerWaypointManager#untrackWaypoint` + `trackWaypoint`） | 原版 `Waypoint.Icon#cloneAndAssignStyle` 是**在建立连接那一刻**把队伍颜色复制进图标快照的；不重建连接，字母会永远停在旧颜色（作者反馈的第二个 bug） |

**归属数据来源（关键，易错）**：`MatchEngine.enabled` 默认 `false`（比赛仍由数据包驱动），
此时归属**必须读数据包**写在点位 marker 实体上的记分项 `pvpshot.owner`
（由 `pvpshot:point/tick_one` 维护；0 = 中立、1 = 红、2 = 蓝），
引擎接管后才改用引擎自己的状态。此前可视化只读引擎状态 → 归属恒为"中立"，
发光轮廓、信标玻璃、定位条字母三样都不变色，这就是作者反馈"玻璃没有被放置"的根因。

关键行为（对应作者要求）：

- 点位在当前模式下**不启用**（三点模式的 D、E）时不发光、颜色置灰，信标玻璃写回白色；
- 可视化**独立于比赛引擎**：引擎未接管时，模式从数据包写在记分板 `ustc.clock` 上的
  `#preset` 读取（3 = 三点、5 = 五点、1 = 死斗）；
- 航点所在区块用 `setChunkForced` **常加载**：不常加载时区块一卸载实体就被卸载，
  定位条上的点位会消失、下一 tick 还会重复创建（历史上堆出过 1166 个隐形史莱姆）；
- 性能约束：仅当点位 64 格内有玩家才画粒子；队伍颜色与信标玻璃只在变化时更新（并 `onTeamChanged`）；
  点位扫描失败时以 100 tick 为间隔重试，不每 tick 空转。

命令：`/pvpshot match visualize on|off|status`。

**部署物（炮/炮塔/掩体）退还排查结论（2026-09-25）**：数据包侧的部署链路是好的。
用假人 + `advancement grant <player> only pvpshot:use_cannon`（原版会立刻执行该进度的
`rewards.function`，等价于玩家吃下部署物）实测：

- 站在**空地**（如 `-1950 2 -1450`）：`#place.ok` 终点为 1，`place template` 成功落结构，
  **不退还**物品；
- 站在**保护区**（如大厅 `-2130 9 -1800`）：`#place.ok` 为 0，结构不落，按设计**退还**物品并提示。

即"每次部署都退还"= 每次都在保护区（基地 / 据点核心 / 大厅 / 楼顶设施 / 补给箱）里部署，
属于 2026-08 版《说明.md》写明的既有规则，不是本轮重构引入的 bug。顺带纠正一个易误判点：
26.2 **确实**有 `execute summon <实体> run <命令>` 这个子命令（`ExecuteCommand` 里
`summon` 会 redirect 回 `execute` 根节点），所以 `pvpshot:deploy/start` 那种写法是合法的，
不是语法错误。

---

### 5.12 部署物扣账（2026-09-25 修复）

部署物（TNT 炮 / 炮塔 / 掩体）是"吃下就部署"的道具：物品带
`minecraft:consumable`（`consume_seconds: 0.05` = 1 tick）+
`minecraft:use_cooldown`（炮 5 s / 炮塔 3 s，带 `cooldown_group`），
原版进度 `pvpshot:use_cannon`（`consume_item` 触发器）的奖励函数就是
`pvpshot:deploy/cannon`，失败时数据包用 `loot give` 退还一件。

**原版扣物品的顺序（关键）**：`Consumable#onConsume` 里

1. 先 `CriteriaTriggers.CONSUME_ITEM.trigger(...)` —— 数据包在这里部署/退还；
2. 再 `ItemStack#consume(1, user)` —— **而这一步对"无限材料"玩家（创造模式）不扣**。

所以账目在两种模式下不一样：

| 模式 | 部署成功 | 部署失败 | 作者看到的现象 |
|---|---|---|---|
| 生存 | 净 -1（正常） | 净 0（退还一件，正常） | — |
| 创造 | 净 0（**看起来像退还**） | 净 +1（**净赚一件**） | "成功退一个、失败退两个" |

**修复**：新增 `pvpshot.weapon.DeployRefundWatch`，

- 用部署物的 `use_cooldown` **冷却从"无"变"有"**作为"刚完成一次部署"的可靠信号
  （`UseCooldown#apply` 由 `Consumable#onConsume` 里的 `ConsumableListener` 调用，
  两种模式都会打上冷却）；
- **只在创造模式下补扣一件**（就地 `stack.shrink(1)`），让创造模式与生存模式账目一致：
  成功 -1、失败 0；
- 同时把每次"消耗 / 退还"写进服务器日志（玩家名、模式、坐标、数量变化），
  作为常驻的低成本可观测手段（每 tick 只读 41 个背包槽位）。

生存模式路径不做任何干预，行为与原版 + 数据包完全一致。

---

## 6. 性能目标与测量方法

### 6.1 目标

| 指标 | 目标 | 测量方法 |
|---|---|---|
| 空载 tick | ≤ 3 ms | `/tick query` 平均 |
| 12 人交火 tick | ≤ 25 ms | 12 个假人/真人 + 脚本化交火，取 5 分钟 P95 |
| 复原期间额外开销 | ≤ 5 ms/tick | 复原过程中持续采样 |
| 复原总耗时 | ≤ 30 s（目标 10 s 内） | 计时命令 |
| 单弹体每 tick 成本 | < 1 µs 量级 | JMH 微基准或 tick 采样对比 |
| 内存 | 稳态无持续增长（12 小时） | 堆转储对比 |

### 6.2 测量纪律（沿用现状文档的好习惯）

- 单人快照**不能**作为性能结论（现有文档已经写明这点）。
- 压力测试必须包含：霰弹枪齐射、空爆火箭筒、TNT 连爆、战斗机、整场复原。
- 记录宿主机状态（本项目宿主机的 Swap 使用偏高，是干扰因素）。
- 每次性能结论都要附：时间、在线人数、模式、tick 采样、测试脚本。

---

## 7. 迁移方案（分阶段，随时可回滚）

| 阶段 | 内容 | 关键动作 | 回滚点 |
|---|---|---|---|
| M0 | 仓库与文档 | `git init`、`.gitignore`、PRD/SPEC 定稿、首次提交 | — |
| M1 | 骨架 | 建 Gradle 工程、核实 Fabric 版本、模组加载成功、用**现有世界**开服、玩家能连 | 删除模组即可回到现状 |
| M2 | 地形与保护 | 移植设施保护与复原；对照旧版本验证 181 区域与整场复原 | 关闭模组保护，回退到旧数据包 |
| M3 | 比赛骨架 | 队伍、大厅、模式、计分、复活、UI | 旧数据包仍在世界中，可切换回旧 tick 链 |
| M4 | 武器 | 全部武器与投射物；数值对齐《武器平衡表》 | 单武器级别开关（便于逐个排查） |
| M5 | 场景与载具 | 炮/炮塔、补给箱、战斗机、高级箱 | 同上 |
| M6 | 验收与切换 | 自动测试 + 线上单局验证 + 正式替换 | 保留旧版本与存档备份 |
| M7 | 档 B/C | 服务器资源包、客户端 Mod | 与主玩法解耦，随时可撤 |

**并行运行策略**：M2 起可以让模组与旧数据包**共存**——模组先接管一部分（例如保护与复原），旧数据包继续跑其余部分，逐块替换。这样每一阶段都能开服实测，而不是等全部写完才知道行不行。

---

## 8. 测试与验收

| 层次 | 做法 | 覆盖 |
|---|---|---|
| 单元测试 | 纯逻辑类（复活候选筛选、伤害公式、保护区判定、复原分片） | 不依赖服务器，秒级反馈 |
| 游戏内自动化 | 延续现有 GameTest（8 组、1131 条检查） | 行为正确性 |
| 对照测试 | 同一操作在 before 与新版各跑一次，比对结果（伤害数值、坐标、物品数量） | 玩法不缩水 |
| 压力测试 | 12 人脚本化交火 + 复原 | 性能目标 |
| 兼容测试 | **原版客户端**（不装任何 Mod）与装有档 C Mod 的客户端同时在线 | 零安装底线 |
| 长跑测试 | 12 小时连续运行 | 内存与稳定性 |

---

## 9. 技术核实清单

### 9.1 已核实（2026-09-24 实测，M1）

| # | 问题 | 结论 | 证据 |
|---|---|---|---|
| 1 | Fabric 是否支持 26.2 | ✅ 支持 | `meta.fabricmc.net/v2/versions/loader/26.2` 返回 253 个版本；Loader 最新 0.19.5；Fabric API 对 26.2 有 14 个版本，最新 `0.161.0+26.2` |
| 2 | **26.2 的映射机制** | ✅ **不需要映射** | 打开 26.2 的 client/server jar，里面是 `net/minecraft/server/level/ServerPlayer.class` 这类**官方名字**（未混淆）；官方 version json 的 `downloads` 只有 `client`/`server`，**没有** `client_mappings` |
| 3 | Yarn 是否可用 | ✅ 不可用（已废弃） | `meta.fabricmc.net/v2/versions/yarn` 共 3412 条，**26.x 为 0 条** |
| 4 | intermediary 情况 | ✅ 退化为空映射 | `net.fabricmc:intermediary:0.0.0` 存在，`intermediary-0.0.0-v2.jar` 仅 578 字节；Fabric Loader 启动日志直接打印 `Mappings not present!` |
| 5 | 现有 Java 代码能否复用 | ✅ 能，且零改动 | 现有 `server_protection` 用的就是官方类名；26.x 下开发命名空间 = 运行时类名，无需重映射 |
| 6 | 工具链版本组合 | ✅ 已验证可用 | JDK 25.0.2 + Gradle 9.7.1 + Loom `1.17-SNAPSHOT`；已发布的 Loom 1.17.20 / 1.17.21 / 1.18.2 都会报 `Configuration 'mappings' has no dependencies`；Loom 1.18.2 另需 Gradle 9.7（否则 `No matching variant`） |
| 7 | 骨架能否真的加载 | ✅ 已实测 | `Loading Minecraft 26.2 with Fabric Loader 0.19.5` / `Loading 44 mods`（含 `pvpshot 1.0.0-m1`）/ 模组初始化与事件注册日志正常 |

### 9.2 待核实（进入对应里程碑时确认）

1. **26.2 是否仍支持数据包提供自定义维度**（现有 `ustc_pvp:template` 依赖它；M2 复原功能开工前确认）。
2. **26.2 是否提供原版对话框（dialog）及其 Java 侧调用方式**（决定大厅菜单用对话框还是原版容器；M3 前确认）。
3. **`SavedData` / 数据附件在 26.2 的 API 签名**（用于比赛状态持久化；M3 前确认）。
4. **服务器资源包字段与下发时机**（决定档 B 的实现细节；M7 前确认）。
5. **26.2 客户端"按住攻击键连发"的实际行为**（原版有攻击冷却，连发武器建议用右键；若必须用左键，需要调整攻击速度属性并实测；M4 前确认）。
6. **Mixin 目标方法的准确签名**（26.2 的类名可直接读，但仍需用 `javap` 逐个确认方法描述符；M2 开工时逐个核对，避免 Mixin 应用失败）。

---

## 10. 变更记录

> 注：2026-09-25 的 **v0.6** 条目为"部署物扣账修复"（创造模式与生存模式账目对齐 +
> 部署物消耗/退还日志），技术细节见 **5.12 节**，需求侧说明见 PRD 的 **11.1 节**。

| 日期 | 版本 | 改动内容 | 原因 | 涉及文件 |
|---|---|---|---|---|
| 2026-09-24 | v0.1 | 建立 SPEC：核实现状事实（版本、796 个函数、694 行 Java、瓶颈逐条取证）、判定纯服务端可行性逐项对照、原版客户端能力边界、技术选型（Fabric + 官方 mappings + 事件/Mixin 分工）、模块与目录设计、弹体/复原/保护方案、性能目标与测量纪律、分阶段迁移与回滚策略、待核实清单 | 把"能不能用纯服务端模组重构"从感觉变成可复查的结论，并给出可执行路线 | `specs/SPEC.md`（重写）、`specs/PRD.md`（同批） |
| 2026-09-24 | v0.2 | 同步作者已确认的三条决策：A 档优先（玩家零安装）、C 档仅预留接口不实现、地图与全部点位/出生点/保护区/复原范围保持不变、git 排除规则认可；并记录环境写入权限的变更 | 与 PRD 保持同步，作为后续 M1 的输入 | `specs/SPEC.md`、`specs/PRD.md` |
| 2026-09-24 | v0.3 | 把第 9 节从"待核实清单"改为"技术核实清单"：记录 M1 实测得到的七条结论（Fabric 支持情况、**26.2 不再混淆因而不需要映射**、Yarn 无 26.x、intermediary 为空、现有 Java 代码可零改动复用、工具链版本组合、骨架实际加载成功），并保留六项待后续里程碑确认的问题 | 26.x 的映射机制与旧版本差异极大，是本次重构最重要的技术前提，必须留档以免后续误配构建脚本 | `specs/SPEC.md` |
| 2026-09-24 | v0.4 | 第 5.8 节从"方案"改写为"已实现"（181 区域 + 区块索引 + 每 tick 刷新总开关 + 六个 Mixin 拦截点 + 同种方块状态放行的细节），并标明运行时验证尚未进行；新增 5.8.1 节确立"优先复用原版实现"的编码原则，列出四处可直接复用的原版代码（风弹 / 箭矢与末影珍珠 / `/clone` 命令 / `StructureTemplate`）及其源码位置，同时记录 26.2 反编译源码的就位位置 | 作者要求尽可能复用原版实现，避免自创一套运动与碰撞逻辑；这一原则需要写进设计文档并在后续里程碑（M2b 复原、M4 武器）中执行 | `specs/SPEC.md`、`specs/PRD.md`、`mod/src/main/java/pvpshot/protect/ProtectionRegions.java`、`mod/src/main/java/pvpshot/mixin/*.java` |
| 2026-09-25 | v0.5 | ① **补记 M2b/M3/M4 与测试服阶段的设计结论**（这些改动此前只进了 git、没进文档）：整场复原走原版 `StructureTemplate` + 每 tick 限时 5 ms 分帧；比赛引擎 `pvpshot.match` 复刻占领/计分规则且默认不接管；武器与载具全部移植到模组；测试服端口 25566 + 正版验证 + Carpet/spark；控制台乱码根因是"log4j 固定 UTF-8，必须 `chcp 65001`"。② **第 5.11 节按实际实现重写**：范围边框改为贴地火焰粒子环（每 4 点一个队伍色粉尘）；点位标记改为"地下隐形史莱姆 + 3×3×3 基岩 + 抗性提升 V"，并兼任原版定位条航点（A~E 字母来自服务器资源包）；新增"信标光柱换色"（换信标上方染色玻璃，原版自动重算光柱）与"定位条字母换色"（归属变化时重建航点连接，原版图标颜色是建立连接时的快照）两项；③ **记录归属数据来源的关键坑**：引擎默认关闭时必须读数据包写在点位 marker 上的 `pvpshot.owner`，否则归属恒为中立、发光/光柱/字母都不变色（作者反馈的"玻璃没有放置"即此）；④ **附部署退还的端到端排查结论**：用假人 + `advancement grant` 复现玩家吃下部署物的完整链路 —— 空地部署成功且不退还，保护区内按设计失败并退还；并注明 26.2 的 `execute summon <实体> run <命令>` 是合法子命令（`ExecuteCommand#summon` 会 redirect 回 `execute` 根节点），避免后续误判为语法错误 | 作者要求"每次改动都写进文档"；本轮两个反馈（玻璃不变色、定位条字母不变色）都是真实缺陷，且根因都在"可视化只读模组引擎状态"这一处，必须写清楚以免重犯；部署退还的排查结论也需要留档，防止以后重复排查 | 更新 `specs/SPEC.md`、`specs/PRD.md`、`mod/src/main/java/pvpshot/match/PointVisuals.java`、`tools/waypoint-resourcepack/make_waypoint_pack.py`（把资源包生成脚本纳入仓库） |
