# 科大中区服务端玩法与设施保护模块

仅服务端运行，适用于本项目已校验的官方 Minecraft Java 26.2 服务端和 Java 25。客户端不需要 Mod，不修改官方 `server.jar`。通过 Java 标准的 agent / Class-File API 在启动时加入保护判断，模块没有第三方依赖。

保护范围由 `tools/ustc_world/make_pack.py` 的 `protection_regions()` 统一生成，包括：大厅、两队基地的地板/围墙/复活空间、五个据点的中心与旗杆及地面标记、80 个普通补给箱、2 个高级航空箱及其底座/开盖空间。周边普通建筑和道路仍可破坏。

- 阻止挖掘、原版爆炸、破拆火箭、步枪和部署结构破坏设施。
- 阻止活塞移动设施，以及在复活空间或箱盖上方搭方块堵塞。
- 保留箱子原版界面、取物和定时补给；基地按钮仍可激活。
- 不改写 TNT 对玩家的原版伤害、击退、遮挡减伤或归属。
- 地图初始化和管理员地形复原期间自动允许必要的方块修改，完成后恢复保护。

第八轮同时提供弓弩距离结算与近炸、风暴弹、冲锋枪自动连射、温雷、战斗机30 秒生命周期、霰弹枪、重武器、楼顶弹射器和掉落物拦截。弓保留原版移动，弩改为直线匀速、240 格射程；弩 3 秒装填通过客户端同步的自定义附魔实现。完整玩法需要本模块，单独复制数据包到未加载模块的单人游戏不构成第八轮完整安装。

## 构建和启动

```bash
python3 server_protection/build.py --java-home /path/to/java25 --output /tmp/pvp-protection
```

将生成的两个 JAR 和 `regions.tsv` 放进服务端 `protection/`。根目录放置 `protection-required.txt`，使用配套 `start.sh` 或 `start.bat` 启动。启动脚本会检查完整性；agent 会检查官方服务端 SHA-1，拒绝对其他版本静默应用补丁。

需要同时安装本次更新后的 `pvpshot` 和 `ustc_pvp` 数据包。不要重新运行首次世界安装脚本覆盖已在使用的世界。

维护命令：`function ustc_pvp:protection/repair` 只重建设施，不改变据点归属，也不清空现有箱内物资。只在箱体已缺失时重建并补充该箱。整张地图复原仍使用 `function ustc_pvp:reset/start`。

管理员手工修改设施可先执行 `scoreboard players set #protection.edit ustc.clock 1`，完成后务必设回 `0`。玩法按钮与 trigger 对所有玩家开放。不要在对战过程中保持维护开关开启。

本模块随服务端启动，普通 HMCL 单人存档如果未加载模块，就不具备这些原生挖掘和 TNT 保护。连接配套服务端即可测试完整保护功能。Windows 启动脚本仅做了代码检查，尚未在 Windows 机器上实跑。
