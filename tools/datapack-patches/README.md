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

### 5. 破拆火箭补给量 ×1.5（2026-09-25）

| 文件 | 原 | 现 |
|---|---|---|
| `pvpshot:chest/refill_one`（普通补给箱） | 4 发 | **6 发** |
| `pvpshot:chest/refill_rich`（体育馆富箱） | 2 发 | **3 发** |
| `ustc_pvp:advanced/one`（南北独立高级箱） | 2 发 | **3 发** |

（破拆火箭的投放是"定量插入"，没有随机概率，所以 ×1.5 落在数量上。）
