scoreboard players set #protection.edit ustc.clock 1
gamerule minecraft:send_command_feedback false
gamerule minecraft:command_block_output false
gamerule minecraft:log_admin_commands false
gamerule minecraft:spawn_mobs false
gamerule minecraft:advance_time false
gamerule minecraft:advance_weather false
gamerule minecraft:natural_health_regeneration false
gamerule minecraft:keep_inventory true
gamerule minecraft:respawn_radius 0
gamerule minecraft:show_advancement_messages false
gamerule minecraft:command_blocks_work true
gamerule minecraft:fire_spread_radius_around_player 0
gamerule minecraft:random_tick_speed 0
time set noon
weather clear
difficulty normal
setworldspawn -2130 9 -1800 0 0
function ustc_pvp:anchors
kill @e[tag=ustc.decor]
kill @e[tag=ustc.marker]
summon marker -2130 9 -1800 {"Tags":["ustc.marker","pvpshot.arena"],"data":{}}
fill -2147 8 -1805 -2113 8 -1791 minecraft:smooth_stone
fill -2147 9 -1805 -2113 14 -1791 minecraft:air
setblock -2144 9 -1804 minecraft:polished_deepslate
setblock -2144 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:join_red",TrackOutput:0b}
setblock -2144 10 -1803 minecraft:stone_button[face=wall,facing=south]
summon text_display -2143.5 12 -1803.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"加入红队","color":"red"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2137 9 -1804 minecraft:polished_deepslate
setblock -2137 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:join_blue",TrackOutput:0b}
setblock -2137 10 -1803 minecraft:stone_button[face=wall,facing=south]
summon text_display -2136.5 12 -1803.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"加入蓝队","color":"blue"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2130 9 -1804 minecraft:polished_deepslate
setblock -2130 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/three",TrackOutput:0b}
setblock -2130 10 -1803 minecraft:stone_button[face=wall,facing=south]
summon text_display -2129.5 12 -1803.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"三点占领","color":"yellow"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2123 9 -1804 minecraft:polished_deepslate
setblock -2123 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/five",TrackOutput:0b}
setblock -2123 10 -1803 minecraft:stone_button[face=wall,facing=south]
summon text_display -2122.5 12 -1803.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"五点占领","color":"gold"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2116 9 -1804 minecraft:polished_deepslate
setblock -2116 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/deathmatch",TrackOutput:0b}
setblock -2116 10 -1803 minecraft:stone_button[face=wall,facing=south]
summon text_display -2115.5 12 -1803.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"团队死斗","color":"aqua"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2144 9 -1793 minecraft:polished_deepslate
setblock -2144 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:reset/request",TrackOutput:0b}
setblock -2144 10 -1792 minecraft:stone_button[face=wall,facing=south]
summon text_display -2143.5 12 -1792.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"重置战场","color":"white"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2137 9 -1793 minecraft:polished_deepslate
setblock -2137 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:kit",TrackOutput:0b}
setblock -2137 10 -1792 minecraft:stone_button[face=wall,facing=south]
summon text_display -2136.5 12 -1792.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"补齐装备","color":"white"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2130 9 -1793 minecraft:polished_deepslate
setblock -2130 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/mobility_0",TrackOutput:0b}
setblock -2130 10 -1792 minecraft:stone_button[face=wall,facing=south]
summon text_display -2129.5 12 -1792.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"领取速度 V","color":"white"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2123 9 -1793 minecraft:polished_deepslate
setblock -2123 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/mobility_1",TrackOutput:0b}
setblock -2123 10 -1792 minecraft:stone_button[face=wall,facing=south]
summon text_display -2122.5 12 -1792.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"领取跳跃 V","color":"white"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2116 9 -1793 minecraft:polished_deepslate
setblock -2116 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/refill",TrackOutput:0b}
setblock -2116 10 -1792 minecraft:stone_button[face=wall,facing=south]
summon text_display -2115.5 12 -1792.5 {"Tags":["ustc.decor","ustc.control"],"text":{"text":"补充奖励箱","color":"white"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2148 9 -1806 -2112 9 -1806 minecraft:stone_brick_wall
fill -2148 9 -1790 -2112 9 -1790 minecraft:stone_brick_wall
fill -2148 9 -1806 -2148 9 -1790 minecraft:stone_brick_wall
fill -2112 9 -1806 -2112 9 -1790 minecraft:stone_brick_wall
summon text_display -2129.5 14 -1797.5 {"Tags":["ustc.decor","ustc.lobby"],"text":{"text":"科大中区对战场\n选择队伍进入；顶部显示比分\n三点 / 五点 / 团队死斗","color":"aqua"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2118 1 -1498 -2102 1 -1482 minecraft:red_terracotta
fill -2118 2 -1498 -2102 6 -1482 minecraft:air
fill -2118 2 -1498 -2118 4 -1482 minecraft:stone_bricks
fill -2118 2 -1498 -2113 4 -1498 minecraft:stone_bricks
fill -2107 2 -1498 -2102 4 -1498 minecraft:stone_bricks
fill -2118 2 -1482 -2113 4 -1482 minecraft:stone_bricks
fill -2107 2 -1482 -2102 4 -1482 minecraft:stone_bricks
summon marker -2109.5 2 -1491.5 {"Tags":["ustc.marker","pvpshot.spawn.red"],"data":{}}
summon marker -2109.5 2 -1489.5 {"Tags":["ustc.marker","pvpshot.spawn.red"],"data":{}}
summon marker -2109.5 2 -1487.5 {"Tags":["ustc.marker","pvpshot.spawn.red"],"data":{}}
summon text_display -2109.5 8 -1489.5 {"Tags":["ustc.decor","ustc.base.red"],"text":{"text":"红队基地","color":"red"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -2115 2 -1495 minecraft:polished_deepslate
# 2026-09-25 作者要求：基地出生点的 base_menu 命令方块（含按钮、"补给 / 返回大厅"说明与底座）删除。
# 这里必须写成"主动清空"：复位流程是"先把复原模板抄回主世界、再调用本函数"，
# 所以只要模板里还残留命令方块，只删 setblock 是没用的（之前只改了 protection/repair，
# 结果每局结束又冒出来）。补给仍可用 /trigger pvp_kit。
setblock -2115 3 -1495 minecraft:air
setblock -2115 3 -1494 minecraft:air
setblock -2115 2 -1495 minecraft:air
kill @e[type=text_display,tag=ustc.control,x=-2114.5,y=5,z=-1494.5,distance=..2]
fill -1598 1 -1533 -1582 1 -1517 minecraft:blue_terracotta
fill -1598 2 -1533 -1582 6 -1517 minecraft:air
fill -1582 2 -1533 -1582 4 -1517 minecraft:stone_bricks
fill -1598 2 -1533 -1593 4 -1533 minecraft:stone_bricks
fill -1587 2 -1533 -1582 4 -1533 minecraft:stone_bricks
fill -1598 2 -1517 -1593 4 -1517 minecraft:stone_bricks
fill -1587 2 -1517 -1582 4 -1517 minecraft:stone_bricks
summon marker -1589.5 2 -1526.5 {"Tags":["ustc.marker","pvpshot.spawn.blue"],"data":{}}
summon marker -1589.5 2 -1524.5 {"Tags":["ustc.marker","pvpshot.spawn.blue"],"data":{}}
summon marker -1589.5 2 -1522.5 {"Tags":["ustc.marker","pvpshot.spawn.blue"],"data":{}}
summon text_display -1589.5 8 -1524.5 {"Tags":["ustc.decor","ustc.base.blue"],"text":{"text":"蓝队基地","color":"blue"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
setblock -1585 2 -1530 minecraft:polished_deepslate
# 蓝队基地同上：命令方块、按钮、说明文字与底座一并清空
setblock -1585 3 -1530 minecraft:air
setblock -1585 3 -1529 minecraft:air
setblock -1585 2 -1530 minecraft:air
kill @e[type=text_display,tag=ustc.control,x=-1584.5,y=5,z=-1529.5,distance=..2]
function ustc_pvp:v8/facilities
scoreboard players set #protection.edit ustc.clock 1
function ustc_pvp:points/build
fill -1931 1 -1311 -1929 1 -1309 minecraft:smooth_stone
setblock -1930 2 -1310 minecraft:trapped_chest[facing=north]
summon marker -1929.5 2 -1309.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.0","ustc.gym","pvpshot.chest.rich"],"data":{}}
summon text_display -1929.5 5 -1309.5 {"Tags":["ustc.decor","ustc.cache.0.label"],"text":{"text":"体育馆补给 1","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1866 1 -1301 -1864 1 -1299 minecraft:smooth_stone
setblock -1865 2 -1300 minecraft:trapped_chest[facing=north]
summon marker -1864.5 2 -1299.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.1","ustc.gym","pvpshot.chest.rich"],"data":{}}
summon text_display -1864.5 5 -1299.5 {"Tags":["ustc.decor","ustc.cache.1.label"],"text":{"text":"体育馆补给 2","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1791 1 -1301 -1789 1 -1299 minecraft:smooth_stone
setblock -1790 2 -1300 minecraft:trapped_chest[facing=north]
summon marker -1789.5 2 -1299.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.2","ustc.gym","pvpshot.chest.rich"],"data":{}}
summon text_display -1789.5 5 -1299.5 {"Tags":["ustc.decor","ustc.cache.2.label"],"text":{"text":"体育馆补给 3","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1761 1 -1261 -1759 1 -1259 minecraft:smooth_stone
setblock -1760 2 -1260 minecraft:trapped_chest[facing=north]
summon marker -1759.5 2 -1259.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.3","ustc.gym","pvpshot.chest.rich"],"data":{}}
summon text_display -1759.5 5 -1259.5 {"Tags":["ustc.decor","ustc.cache.3.label"],"text":{"text":"体育馆补给 4","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1761 1 -1191 -1759 1 -1189 minecraft:smooth_stone
setblock -1760 2 -1190 minecraft:trapped_chest[facing=north]
summon marker -1759.5 2 -1189.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.4","ustc.gym","pvpshot.chest.rich"],"data":{}}
summon text_display -1759.5 5 -1189.5 {"Tags":["ustc.decor","ustc.cache.4.label"],"text":{"text":"体育馆补给 5","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1836 1 -1181 -1834 1 -1179 minecraft:smooth_stone
setblock -1835 2 -1180 minecraft:trapped_chest[facing=north]
summon marker -1834.5 2 -1179.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.5","ustc.gym","pvpshot.chest.rich"],"data":{}}
summon text_display -1834.5 5 -1179.5 {"Tags":["ustc.decor","ustc.cache.5.label"],"text":{"text":"体育馆补给 6","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1911 1 -1191 -1909 1 -1189 minecraft:smooth_stone
setblock -1910 2 -1190 minecraft:trapped_chest[facing=north]
summon marker -1909.5 2 -1189.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.6","ustc.gym","pvpshot.chest.rich"],"data":{}}
summon text_display -1909.5 5 -1189.5 {"Tags":["ustc.decor","ustc.cache.6.label"],"text":{"text":"体育馆补给 7","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1956 1 -1261 -1954 1 -1259 minecraft:smooth_stone
setblock -1955 2 -1260 minecraft:trapped_chest[facing=north]
summon marker -1954.5 2 -1259.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.7","ustc.gym","pvpshot.chest.rich"],"data":{}}
summon text_display -1954.5 5 -1259.5 {"Tags":["ustc.decor","ustc.cache.7.label"],"text":{"text":"体育馆补给 8","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2016 1 -1511 -2014 1 -1509 minecraft:smooth_stone
setblock -2015 2 -1510 minecraft:trapped_chest[facing=north]
summon marker -2014.5 2 -1509.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.8"],"data":{}}
summon text_display -2014.5 5 -1509.5 {"Tags":["ustc.decor","ustc.cache.8.label"],"text":{"text":"战地补给 1","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1836 1 -1516 -1834 1 -1514 minecraft:smooth_stone
setblock -1835 2 -1515 minecraft:trapped_chest[facing=north]
summon marker -1834.5 2 -1514.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.9"],"data":{}}
summon text_display -1834.5 5 -1514.5 {"Tags":["ustc.decor","ustc.cache.9.label"],"text":{"text":"战地补给 2","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1656 1 -1511 -1654 1 -1509 minecraft:smooth_stone
setblock -1655 2 -1510 minecraft:trapped_chest[facing=north]
summon marker -1654.5 2 -1509.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.10"],"data":{}}
summon text_display -1654.5 5 -1509.5 {"Tags":["ustc.decor","ustc.cache.10.label"],"text":{"text":"战地补给 3","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1661 1 -1681 -1659 1 -1679 minecraft:smooth_stone
setblock -1660 2 -1680 minecraft:trapped_chest[facing=north]
summon marker -1659.5 2 -1679.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.11"],"data":{}}
summon text_display -1659.5 5 -1679.5 {"Tags":["ustc.decor","ustc.cache.11.label"],"text":{"text":"战地补给 4","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2061 1 -1381 -2059 1 -1379 minecraft:smooth_stone
setblock -2060 2 -1380 minecraft:trapped_chest[facing=north]
summon marker -2059.5 2 -1379.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.12"],"data":{}}
summon text_display -2059.5 5 -1379.5 {"Tags":["ustc.decor","ustc.cache.12.label"],"text":{"text":"战地补给 5","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1785 1 -1678 -1783 1 -1676 minecraft:smooth_stone
setblock -1784 2 -1677 minecraft:trapped_chest[facing=north]
summon marker -1783.5 2 -1676.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.13"],"data":{}}
summon text_display -1783.5 5 -1676.5 {"Tags":["ustc.decor","ustc.cache.13.label"],"text":{"text":"战地补给 6","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1827 1 -1650 -1825 1 -1648 minecraft:smooth_stone
setblock -1826 2 -1649 minecraft:trapped_chest[facing=north]
summon marker -1825.5 2 -1648.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.14"],"data":{}}
summon text_display -1825.5 5 -1648.5 {"Tags":["ustc.decor","ustc.cache.14.label"],"text":{"text":"战地补给 7","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1603 1 -1650 -1601 1 -1648 minecraft:smooth_stone
setblock -1602 2 -1649 minecraft:trapped_chest[facing=north]
summon marker -1601.5 2 -1648.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.15"],"data":{}}
summon text_display -1601.5 5 -1648.5 {"Tags":["ustc.decor","ustc.cache.15.label"],"text":{"text":"战地补给 8","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1785 1 -1622 -1783 1 -1620 minecraft:smooth_stone
setblock -1784 2 -1621 minecraft:trapped_chest[facing=north]
summon marker -1783.5 2 -1620.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.16"],"data":{}}
summon text_display -1783.5 5 -1620.5 {"Tags":["ustc.decor","ustc.cache.16.label"],"text":{"text":"战地补给 9","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1939 1 -1594 -1937 1 -1592 minecraft:smooth_stone
setblock -1938 2 -1593 minecraft:trapped_chest[facing=north]
summon marker -1937.5 2 -1592.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.17"],"data":{}}
summon text_display -1937.5 5 -1592.5 {"Tags":["ustc.decor","ustc.cache.17.label"],"text":{"text":"战地补给 10","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1603 1 -1594 -1601 1 -1592 minecraft:smooth_stone
setblock -1602 2 -1593 minecraft:trapped_chest[facing=north]
summon marker -1601.5 2 -1592.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.18"],"data":{}}
summon text_display -1601.5 5 -1592.5 {"Tags":["ustc.decor","ustc.cache.18.label"],"text":{"text":"战地补给 11","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1869 1 -1566 -1867 1 -1564 minecraft:smooth_stone
setblock -1868 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1867.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.19"],"data":{}}
summon text_display -1867.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.19.label"],"text":{"text":"战地补给 12","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1729 1 -1566 -1727 1 -1564 minecraft:smooth_stone
setblock -1728 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1727.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.20"],"data":{}}
summon text_display -1727.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.20.label"],"text":{"text":"战地补给 13","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1645 1 -1566 -1643 1 -1564 minecraft:smooth_stone
setblock -1644 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1643.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.21"],"data":{}}
summon text_display -1643.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.21.label"],"text":{"text":"战地补给 14","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1939 1 -1538 -1937 1 -1536 minecraft:smooth_stone
setblock -1938 2 -1537 minecraft:trapped_chest[facing=north]
summon marker -1937.5 2 -1536.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.22"],"data":{}}
summon text_display -1937.5 5 -1536.5 {"Tags":["ustc.decor","ustc.cache.22.label"],"text":{"text":"战地补给 15","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1659 1 -1538 -1657 1 -1536 minecraft:smooth_stone
setblock -1658 2 -1537 minecraft:trapped_chest[facing=north]
summon marker -1657.5 2 -1536.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.23"],"data":{}}
summon text_display -1657.5 5 -1536.5 {"Tags":["ustc.decor","ustc.cache.23.label"],"text":{"text":"战地补给 16","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1869 1 -1510 -1867 1 -1508 minecraft:smooth_stone
setblock -1868 2 -1509 minecraft:trapped_chest[facing=north]
summon marker -1867.5 2 -1508.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.24"],"data":{}}
summon text_display -1867.5 5 -1508.5 {"Tags":["ustc.decor","ustc.cache.24.label"],"text":{"text":"战地补给 17","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1771 1 -1482 -1769 1 -1480 minecraft:smooth_stone
setblock -1770 2 -1481 minecraft:trapped_chest[facing=north]
summon marker -1769.5 2 -1480.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.25"],"data":{}}
summon text_display -1769.5 5 -1480.5 {"Tags":["ustc.decor","ustc.cache.25.label"],"text":{"text":"战地补给 18","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2079 1 -1426 -2077 1 -1424 minecraft:smooth_stone
setblock -2078 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -2077.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.26"],"data":{}}
summon text_display -2077.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.26.label"],"text":{"text":"战地补给 19","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1995 1 -1426 -1993 1 -1424 minecraft:smooth_stone
setblock -1994 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1993.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.27"],"data":{}}
summon text_display -1993.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.27.label"],"text":{"text":"战地补给 20","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1911 1 -1426 -1909 1 -1424 minecraft:smooth_stone
setblock -1910 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1909.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.28"],"data":{}}
summon text_display -1909.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.28.label"],"text":{"text":"战地补给 21","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1827 1 -1426 -1825 1 -1424 minecraft:smooth_stone
setblock -1826 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1825.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.29"],"data":{}}
summon text_display -1825.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.29.label"],"text":{"text":"战地补给 22","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1743 1 -1426 -1741 1 -1424 minecraft:smooth_stone
setblock -1742 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1741.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.30"],"data":{}}
summon text_display -1741.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.30.label"],"text":{"text":"战地补给 23","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1659 1 -1426 -1657 1 -1424 minecraft:smooth_stone
setblock -1658 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1657.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.31"],"data":{}}
summon text_display -1657.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.31.label"],"text":{"text":"战地补给 24","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2116 1 -1403 -2114 1 -1401 minecraft:smooth_stone
setblock -2115 2 -1402 minecraft:trapped_chest[facing=north]
summon marker -2114.5 2 -1401.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.32"],"data":{}}
summon text_display -2114.5 5 -1401.5 {"Tags":["ustc.decor","ustc.cache.32.label"],"text":{"text":"战地补给 25","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2037 1 -1398 -2035 1 -1396 minecraft:smooth_stone
setblock -2036 2 -1397 minecraft:trapped_chest[facing=north]
summon marker -2035.5 2 -1396.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.33"],"data":{}}
summon text_display -2035.5 5 -1396.5 {"Tags":["ustc.decor","ustc.cache.33.label"],"text":{"text":"战地补给 26","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1953 1 -1398 -1951 1 -1396 minecraft:smooth_stone
setblock -1952 2 -1397 minecraft:trapped_chest[facing=north]
summon marker -1951.5 2 -1396.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.34"],"data":{}}
summon text_display -1951.5 5 -1396.5 {"Tags":["ustc.decor","ustc.cache.34.label"],"text":{"text":"战地补给 27","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1869 1 -1398 -1867 1 -1396 minecraft:smooth_stone
setblock -1868 2 -1397 minecraft:trapped_chest[facing=north]
summon marker -1867.5 2 -1396.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.35"],"data":{}}
summon text_display -1867.5 5 -1396.5 {"Tags":["ustc.decor","ustc.cache.35.label"],"text":{"text":"战地补给 28","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1785 1 -1398 -1783 1 -1396 minecraft:smooth_stone
setblock -1784 2 -1397 minecraft:trapped_chest[facing=north]
summon marker -1783.5 2 -1396.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.36"],"data":{}}
summon text_display -1783.5 5 -1396.5 {"Tags":["ustc.decor","ustc.cache.36.label"],"text":{"text":"战地补给 29","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1696 1 -1403 -1694 1 -1401 minecraft:smooth_stone
setblock -1695 2 -1402 minecraft:trapped_chest[facing=north]
summon marker -1694.5 2 -1401.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.37"],"data":{}}
summon text_display -1694.5 5 -1401.5 {"Tags":["ustc.decor","ustc.cache.37.label"],"text":{"text":"战地补给 30","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1612 1 -1403 -1610 1 -1401 minecraft:smooth_stone
setblock -1611 2 -1402 minecraft:trapped_chest[facing=north]
summon marker -1610.5 2 -1401.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.38"],"data":{}}
summon text_display -1610.5 5 -1401.5 {"Tags":["ustc.decor","ustc.cache.38.label"],"text":{"text":"战地补给 31","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1995 1 -1370 -1993 1 -1368 minecraft:smooth_stone
setblock -1994 2 -1369 minecraft:trapped_chest[facing=north]
summon marker -1993.5 2 -1368.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.39"],"data":{}}
summon text_display -1993.5 5 -1368.5 {"Tags":["ustc.decor","ustc.cache.39.label"],"text":{"text":"战地补给 32","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2065 1 -1342 -2063 1 -1340 minecraft:smooth_stone
setblock -2064 2 -1341 minecraft:trapped_chest[facing=north]
summon marker -2063.5 2 -1340.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.40"],"data":{}}
summon text_display -2063.5 5 -1340.5 {"Tags":["ustc.decor","ustc.cache.40.label"],"text":{"text":"战地补给 33","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1953 1 -1342 -1951 1 -1340 minecraft:smooth_stone
setblock -1952 2 -1341 minecraft:trapped_chest[facing=north]
summon marker -1951.5 2 -1340.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.41"],"data":{}}
summon text_display -1951.5 5 -1340.5 {"Tags":["ustc.decor","ustc.cache.41.label"],"text":{"text":"战地补给 34","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2051 1 -1314 -2049 1 -1312 minecraft:smooth_stone
setblock -2050 2 -1313 minecraft:trapped_chest[facing=north]
summon marker -2049.5 2 -1312.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.42"],"data":{}}
summon text_display -2049.5 5 -1312.5 {"Tags":["ustc.decor","ustc.cache.42.label"],"text":{"text":"战地补给 35","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2065 1 -1286 -2063 1 -1284 minecraft:smooth_stone
setblock -2064 2 -1285 minecraft:trapped_chest[facing=north]
summon marker -2063.5 2 -1284.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.43"],"data":{}}
summon text_display -2063.5 5 -1284.5 {"Tags":["ustc.decor","ustc.cache.43.label"],"text":{"text":"战地补给 36","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1934 1 -1263 -1932 1 -1261 minecraft:smooth_stone
setblock -1933 2 -1262 minecraft:trapped_chest[facing=north]
summon marker -1932.5 2 -1261.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.44"],"data":{}}
summon text_display -1932.5 5 -1261.5 {"Tags":["ustc.decor","ustc.cache.44.label"],"text":{"text":"战地补给 37","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1939 1 -1202 -1937 1 -1200 minecraft:smooth_stone
setblock -1938 2 -1201 minecraft:trapped_chest[facing=north]
summon marker -1937.5 2 -1200.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.45"],"data":{}}
summon text_display -1937.5 5 -1200.5 {"Tags":["ustc.decor","ustc.cache.45.label"],"text":{"text":"战地补给 38","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1883 1 -1650 -1881 1 -1648 minecraft:smooth_stone
setblock -1882 2 -1649 minecraft:trapped_chest[facing=north]
summon marker -1881.5 2 -1648.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.46"],"data":{}}
summon text_display -1881.5 5 -1648.5 {"Tags":["ustc.decor","ustc.cache.46.label"],"text":{"text":"战地补给 39","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1855 1 -1650 -1853 1 -1648 minecraft:smooth_stone
setblock -1854 2 -1649 minecraft:trapped_chest[facing=north]
summon marker -1853.5 2 -1648.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.47"],"data":{}}
summon text_display -1853.5 5 -1648.5 {"Tags":["ustc.decor","ustc.cache.47.label"],"text":{"text":"战地补给 40","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1743 1 -1650 -1741 1 -1648 minecraft:smooth_stone
setblock -1742 2 -1649 minecraft:trapped_chest[facing=north]
summon marker -1741.5 2 -1648.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.48"],"data":{}}
summon text_display -1741.5 5 -1648.5 {"Tags":["ustc.decor","ustc.cache.48.label"],"text":{"text":"战地补给 41","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1659 1 -1650 -1657 1 -1648 minecraft:smooth_stone
setblock -1658 2 -1649 minecraft:trapped_chest[facing=north]
summon marker -1657.5 2 -1648.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.49"],"data":{}}
summon text_display -1657.5 5 -1648.5 {"Tags":["ustc.decor","ustc.cache.49.label"],"text":{"text":"战地补给 42","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1925 1 -1622 -1923 1 -1620 minecraft:smooth_stone
setblock -1924 2 -1621 minecraft:trapped_chest[facing=north]
summon marker -1923.5 2 -1620.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.50"],"data":{}}
summon text_display -1923.5 5 -1620.5 {"Tags":["ustc.decor","ustc.cache.50.label"],"text":{"text":"战地补给 43","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1808 1 -1627 -1806 1 -1625 minecraft:smooth_stone
setblock -1807 2 -1626 minecraft:trapped_chest[facing=north]
summon marker -1806.5 2 -1625.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.51"],"data":{}}
summon text_display -1806.5 5 -1625.5 {"Tags":["ustc.decor","ustc.cache.51.label"],"text":{"text":"战地补给 44","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1729 1 -1632 -1727 1 -1630 minecraft:smooth_stone
setblock -1728 2 -1631 minecraft:trapped_chest[facing=north]
summon marker -1727.5 2 -1630.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.52"],"data":{}}
summon text_display -1727.5 5 -1630.5 {"Tags":["ustc.decor","ustc.cache.52.label"],"text":{"text":"战地补给 45","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1967 1 -1594 -1965 1 -1592 minecraft:smooth_stone
setblock -1966 2 -1593 minecraft:trapped_chest[facing=north]
summon marker -1965.5 2 -1592.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.53"],"data":{}}
summon text_display -1965.5 5 -1592.5 {"Tags":["ustc.decor","ustc.cache.53.label"],"text":{"text":"战地补给 46","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1799 1 -1594 -1797 1 -1592 minecraft:smooth_stone
setblock -1798 2 -1593 minecraft:trapped_chest[facing=north]
summon marker -1797.5 2 -1592.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.54"],"data":{}}
summon text_display -1797.5 5 -1592.5 {"Tags":["ustc.decor","ustc.cache.54.label"],"text":{"text":"战地补给 47","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1743 1 -1594 -1741 1 -1592 minecraft:smooth_stone
setblock -1742 2 -1593 minecraft:trapped_chest[facing=north]
summon marker -1741.5 2 -1592.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.55"],"data":{}}
summon text_display -1741.5 5 -1592.5 {"Tags":["ustc.decor","ustc.cache.55.label"],"text":{"text":"战地补给 48","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2009 1 -1566 -2007 1 -1564 minecraft:smooth_stone
setblock -2008 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -2007.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.56"],"data":{}}
summon text_display -2007.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.56.label"],"text":{"text":"战地补给 49","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1981 1 -1566 -1979 1 -1564 minecraft:smooth_stone
setblock -1980 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1979.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.57"],"data":{}}
summon text_display -1979.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.57.label"],"text":{"text":"战地补给 50","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1813 1 -1566 -1811 1 -1564 minecraft:smooth_stone
setblock -1812 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1811.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.58"],"data":{}}
summon text_display -1811.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.58.label"],"text":{"text":"战地补给 51","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1785 1 -1566 -1783 1 -1564 minecraft:smooth_stone
setblock -1784 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1783.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.59"],"data":{}}
summon text_display -1783.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.59.label"],"text":{"text":"战地补给 52","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1701 1 -1566 -1699 1 -1564 minecraft:smooth_stone
setblock -1700 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1699.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.60"],"data":{}}
summon text_display -1699.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.60.label"],"text":{"text":"战地补给 53","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1673 1 -1566 -1671 1 -1564 minecraft:smooth_stone
setblock -1672 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1671.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.61"],"data":{}}
summon text_display -1671.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.61.label"],"text":{"text":"战地补给 54","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1617 1 -1566 -1615 1 -1564 minecraft:smooth_stone
setblock -1616 2 -1565 minecraft:trapped_chest[facing=north]
summon marker -1615.5 2 -1564.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.62"],"data":{}}
summon text_display -1615.5 5 -1564.5 {"Tags":["ustc.decor","ustc.cache.62.label"],"text":{"text":"战地补给 55","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1967 1 -1538 -1965 1 -1536 minecraft:smooth_stone
setblock -1966 2 -1537 minecraft:trapped_chest[facing=north]
summon marker -1965.5 2 -1536.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.63"],"data":{}}
summon text_display -1965.5 5 -1536.5 {"Tags":["ustc.decor","ustc.cache.63.label"],"text":{"text":"战地补给 56","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1771 1 -1538 -1769 1 -1536 minecraft:smooth_stone
setblock -1770 2 -1537 minecraft:trapped_chest[facing=north]
summon marker -1769.5 2 -1536.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.64"],"data":{}}
summon text_display -1769.5 5 -1536.5 {"Tags":["ustc.decor","ustc.cache.64.label"],"text":{"text":"战地补给 57","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1743 1 -1538 -1741 1 -1536 minecraft:smooth_stone
setblock -1742 2 -1537 minecraft:trapped_chest[facing=north]
summon marker -1741.5 2 -1536.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.65"],"data":{}}
summon text_display -1741.5 5 -1536.5 {"Tags":["ustc.decor","ustc.cache.65.label"],"text":{"text":"战地补给 58","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1603 1 -1538 -1601 1 -1536 minecraft:smooth_stone
setblock -1602 2 -1537 minecraft:trapped_chest[facing=north]
summon marker -1601.5 2 -1536.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.66"],"data":{}}
summon text_display -1601.5 5 -1536.5 {"Tags":["ustc.decor","ustc.cache.66.label"],"text":{"text":"战地补给 59","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2093 1 -1510 -2091 1 -1508 minecraft:smooth_stone
setblock -2092 2 -1509 minecraft:trapped_chest[facing=north]
summon marker -2091.5 2 -1508.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.67"],"data":{}}
summon text_display -2091.5 5 -1508.5 {"Tags":["ustc.decor","ustc.cache.67.label"],"text":{"text":"战地补给 60","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1813 1 -1510 -1811 1 -1508 minecraft:smooth_stone
setblock -1812 2 -1509 minecraft:trapped_chest[facing=north]
summon marker -1811.5 2 -1508.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.68"],"data":{}}
summon text_display -1811.5 5 -1508.5 {"Tags":["ustc.decor","ustc.cache.68.label"],"text":{"text":"战地补给 61","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1678 1 -1515 -1676 1 -1513 minecraft:smooth_stone
setblock -1677 2 -1514 minecraft:trapped_chest[facing=north]
summon marker -1676.5 2 -1513.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.69"],"data":{}}
summon text_display -1676.5 5 -1513.5 {"Tags":["ustc.decor","ustc.cache.69.label"],"text":{"text":"战地补给 62","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1612 1 -1515 -1610 1 -1513 minecraft:smooth_stone
setblock -1611 2 -1514 minecraft:trapped_chest[facing=north]
summon marker -1610.5 2 -1513.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.70"],"data":{}}
summon text_display -1610.5 5 -1513.5 {"Tags":["ustc.decor","ustc.cache.70.label"],"text":{"text":"战地补给 63","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1939 1 -1482 -1937 1 -1480 minecraft:smooth_stone
setblock -1938 2 -1481 minecraft:trapped_chest[facing=north]
summon marker -1937.5 2 -1480.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.71"],"data":{}}
summon text_display -1937.5 5 -1480.5 {"Tags":["ustc.decor","ustc.cache.71.label"],"text":{"text":"战地补给 64","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1603 1 -1482 -1601 1 -1480 minecraft:smooth_stone
setblock -1602 2 -1481 minecraft:trapped_chest[facing=north]
summon marker -1601.5 2 -1480.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.72"],"data":{}}
summon text_display -1601.5 5 -1480.5 {"Tags":["ustc.decor","ustc.cache.72.label"],"text":{"text":"战地补给 65","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2093 1 -1454 -2091 1 -1452 minecraft:smooth_stone
setblock -2092 2 -1453 minecraft:trapped_chest[facing=north]
summon marker -2091.5 2 -1452.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.73"],"data":{}}
summon text_display -2091.5 5 -1452.5 {"Tags":["ustc.decor","ustc.cache.73.label"],"text":{"text":"战地补给 66","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2051 1 -1426 -2049 1 -1424 minecraft:smooth_stone
setblock -2050 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -2049.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.74"],"data":{}}
summon text_display -2049.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.74.label"],"text":{"text":"战地补给 67","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -2023 1 -1426 -2021 1 -1424 minecraft:smooth_stone
setblock -2022 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -2021.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.75"],"data":{}}
summon text_display -2021.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.75.label"],"text":{"text":"战地补给 68","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1967 1 -1426 -1965 1 -1424 minecraft:smooth_stone
setblock -1966 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1965.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.76"],"data":{}}
summon text_display -1965.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.76.label"],"text":{"text":"战地补给 69","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1939 1 -1426 -1937 1 -1424 minecraft:smooth_stone
setblock -1938 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1937.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.77"],"data":{}}
summon text_display -1937.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.77.label"],"text":{"text":"战地补给 70","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1883 1 -1426 -1881 1 -1424 minecraft:smooth_stone
setblock -1882 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1881.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.78"],"data":{}}
summon text_display -1881.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.78.label"],"text":{"text":"战地补给 71","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
fill -1855 1 -1426 -1853 1 -1424 minecraft:smooth_stone
setblock -1854 2 -1425 minecraft:trapped_chest[facing=north]
summon marker -1853.5 2 -1424.5 {"Tags":["ustc.marker","pvpshot.chest","ustc.cache.79"],"data":{}}
summon text_display -1853.5 5 -1424.5 {"Tags":["ustc.decor","ustc.cache.79.label"],"text":{"text":"战地补给 72","color":"green"},"billboard":"center","background":1073741824,"line_width":260,"shadow":true}
scoreboard players set #preset ustc.clock 5
scoreboard players set #reset.active ustc.clock 0
data modify storage ustc_pvp:state prepared set value 1b
function ustc_pvp:apply_preset
function ustc_pvp:refill
scoreboard players set #protection.active ustc.clock 1
scoreboard players set #protection.edit ustc.clock 0
function ustc_pvp:respawn/build
function ustc_pvp:advanced/build
scoreboard players set #drops.clear ustc.clock 1
gamerule minecraft:block_drops false
gamerule minecraft:entity_drops false
gamerule minecraft:mob_drops false
data modify storage ustc_pvp:state balance_v7 set value 1b
data modify storage ustc_pvp:state balance_v8 set value 1b
