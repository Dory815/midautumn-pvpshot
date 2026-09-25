# 数据包补丁（世界目录不进 git，这里留可复现的版本）

`server/world/` 是测试存档，按 `.gitignore` 不入库；可是有些**只改数据包**的小修正
必须能被追溯和重建，所以把改好的文件按原来的目录结构放在这里。

## 现有补丁

### 1. `ustc_pvp:respawn/red`、`ustc_pvp:respawn/blue` —— 团队死斗固定基地重生

**问题（作者反馈 2026-09-25）**：团队死斗模式里重生点有概率落在 A~E 点位上 ——
那是抢点模式的设定（占领了哪个点，就在哪个点附近的前线重生点复活）。

**原因**：校园包的 `respawn/red`、`respawn/blue` 里各有一组
`execute if score #mode pvpshot.cfg matches 0 run tag @e[tag=ustc.spawn.A] add ustc.eligible`
（红队用 A、E，蓝队用 C、D），把"固定前线点"当成了死斗模式的候选重生点；
而 A~E 正是抢点点位所在处。

**改法**：删掉这两行（红队 2 行、蓝队 2 行），其余逻辑不动。
删掉后死斗模式没有任何"前线候选"，就会走文件末尾的兜底
`execute unless entity @e[tag=ustc.eligible] run tag @e[tag=pvpshot.spawn.red] add ustc.eligible`，
也就是**始终在红/蓝基地的固定重生点**（每队 3 个点位随机一个）。
抢点模式（`#mode=1`）的逻辑完全不变。

**生效方式**：把 `ustc_pvp/respawn/` 下的两个文件覆盖到
`server/world/datapacks/ustc_pvp/data/ustc_pvp/function/respawn/`，
然后 `/reload` 或重启服务器。

```powershell
Copy-Item 'D:\MC\MidAutumnMiniGame\tools\datapack-patches\ustc_pvp\respawn\*.mcfunction' `
          'D:\MC\MidAutumnMiniGame\server\world\datapacks\ustc_pvp\data\ustc_pvp\function\respawn\' -Force
```

### 2. `pvpshot:loot_table/item/grenade.json` —— 手雷改成"点火—松开投掷"（2026-09-25）

**改动**：`consumable.consume_seconds` 由 `0.05` 改成 **`3.0`**（原版使用时长 = 引信 3 秒），
描述改成"按下右键点火 · 引信 3 秒 · 松开右键扔出（按住不放就在手里炸）"。

**为什么**：作者要求手雷改成按住右键点火、引信 3 秒、松开扔出；按住超过 3 秒在手中爆炸。
计时与投掷由模组 `EquipmentSystems`（`FUSE_TICKS = 60`）负责，物品只是提供"可长按使用"的属性。

### 3. `pvpshot:advancement/use_grenade.json` → `.bak` —— 关掉旧的手雷触发

旧实现是"吃掉物品 → 进度触发函数投掷"，与新机制冲突（会双触发）。
把文件改名成 `.bak`（数据包只加载 `.json`）即等于停用；如果以后要回滚，
把模组的手雷处理去掉、再把 `.bak` 改回 `.json` 即可。

### 4. `pvpshot:loot_table/item/crossbow.json` —— 弩的描述更新

"每人限 1 把"已不适用，改成"每持有一把已装填的弩：缓慢 III"，
与模组 `EquipmentSystems.applyCrossbowWeight`（每 20 tick 检查一次，每把叠 3 级缓慢）一致。

### 5. 破拆火箭补给量：先 ×1.5，随后**退回原值**（2026-09-25 当天两轮）

第一轮（作者要求"刷新率太低"）把数量 ×1.5：普通箱 4→6、富箱 2→3、高级箱 2→3；
第二轮（作者反馈"刷新率有点高了，退回"）**全部改回原值**，也就是现在文件里的：

| 文件 | 现在（已退回） | 曾经的 ×1.5 |
|---|---|---|
| `pvpshot:chest/refill_one`（普通补给箱） | **4 发** | 6 发 |
| `pvpshot:chest/refill_rich`（体育馆富箱） | **2 发** | 3 发 |
| `ustc_pvp:advanced/one`（南北独立高级箱） | **2 发** | 3 发 |

（破拆火箭的投放是"定量插入"，没有随机概率，所以 ×1.5 落在数量上；退回即删掉多出来的几行。）
实测复核：在空地上放一个箱子执行 `pvpshot:chest/refill_one`，箱内 `firework_star`（破拆火箭）数量 = **4**。

### 6. `pvpshot:function/shot/tick.mcfunction` —— 鸡蛋冲锋枪近距离伤害 4 → 2（2026-09-25）

作者对比了鸡蛋冲锋枪与基础火焰弹的实测数值后决定削弱鸡蛋：飞行**前 9 tick** 的伤害由 4 HP 改成
**2 HP**（9 tick 之后仍是 1 HP），弹药/射速/近距窗口都不动。

| | 改前 | 改后 |
|---|---|---|
| 近距单发 | 4 HP | **2 HP** |
| 远端单发 | 1 HP | 1 HP |
| 近距 DPS（6.7 发/秒） | 26.7 | **13.3** |
| 一梭 48 发潜在总伤（全近距） | 192 HP | **96 HP** |

同一批还改了 `pvpshot:loot_table/item/egg.json` 的描述文字（近距 4 HP → 2 HP），两处必须同步改。

### 7. `ustc_pvp:function/build.mcfunction` + `ustc_pvp:function/protection/repair.mcfunction` —— 删掉两个基地的 base_menu 命令方块（2026-09-25，两轮才改对）

**问题（作者反馈）**：基地（队伍出生点）上那个 `base_menu` 命令方块要删掉；作者已手动删了蓝方的，
红方 `-2115 3 -1495` 还在。

**第一次只改了 repair，结果还是每局结束就冒出来**（作者反馈"那个命令方块还是在"）。真正的原因是
**复位流程的收尾会调用设施重建脚本**：

```
ustc_pvp:reset/finish_ready  →  …（拷贝复原模板 → 主世界）…  →  function ustc_pvp:build   （第 210 行）
```

`build.mcfunction` 才是"把大厅按钮墙、红/蓝基地、据点、补给箱整套重摆一遍"的主脚本，
里面同样有这两个 base_menu 命令方块（红 `-2115 3 -1495`、蓝 `-1585 3 -1530`）以及它们的按钮、
底座（`polished_deepslate`）和"补给 / 返回大厅"浮空文字。所以每次复位都会把它们放回来。
`protection/repair.mcfunction` 是另一套（按需触发的）保护区重建脚本，里面也有一份，两处都要改。

**改法**（关键点：写成"主动清空"而不是"删掉 setblock"）：

> 复位是"先把复原模板抄回主世界、再调用 build"，所以只要别处（例如模板维度）还残留命令方块，
> 只把 setblock 注释掉是没用的；必须在 build/repair 里显式 `setblock … air` 把它抹掉。
>
> 另一个坑：**保护区拦截**。模组每 tick 只刷新一次保护状态（`#protection.active==1 && #protection.edit!=1
> && #reset.active!=1` 时保护生效），而 `build` 第 1 行才把 `#protection.edit` 置 1 ——
> 单独手跑 `function ustc_pvp:build` 时同一 tick 内这些编辑会被保护拦下（真实复位流程里 `#reset.active=1`，
> 保护本来就关着，所以正常）。

实际改动（每处 4 条）：

```mcfunction
setblock -2115 3 -1495 minecraft:air      # 命令方块
setblock -2115 3 -1494 minecraft:air      # 按钮
setblock -2115 2 -1495 minecraft:air      # 底座
kill @e[type=text_display,tag=ustc.control,x=-2114.5,y=5,z=-1494.5,distance=..2]   # "补给 / 返回大厅"
```

蓝队基地（`-1585 3 -1530` / `-1585 3 -1529` / `-1585 2 -1530` / 对应文字）同理。
上述改动同步到了：**主世界 `world-ustc`**、`ustc_pvp:template` 维度（先 forceload 再改、改完撤掉）、
以及 `before/` 里所有模板副本（`发布/正式服代码`、`发布/测试服务端/world/datapacks`、
`ustc_pvp/` 代码目录、4 个 `测试存档`），并且把生成器 `tools/ustc_world/make_pack.py` 里
"基地补给按钮"的生成语句删掉（`发布/manifest.json` 的 `files_sha256` 已同步重算）。

**验证**：跑一遍真实复位（`function ustc_pvp:reset/start`，176 批、约 90 秒）后
`data get block -2115 3 -1495 Command` 返回"不是方块实体"、位置是空气，
浮空文字消失，大厅按钮墙、据点信标（E 点 `Levels=1`）与清树结果都保持正常。
注意：**不要用超大半径的选择器**（例如 `@e[...,distance=..1000000]`）做验证 —— 见
`docs/更新日志.md` 的"已知环境问题"：ECO 会在这条路径上把主线程卡死。

`ustc_pvp:base_menu` 函数本身保留（它只是 `kit` + 一条 `/trigger pvp_kit` 提示），
删掉命令方块后该函数暂时没有调用者；玩家补装备仍可走 `/trigger pvp_kit`（大厅装备按钮同理）。
