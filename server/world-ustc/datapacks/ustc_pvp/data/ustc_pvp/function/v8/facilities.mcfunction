scoreboard players set #protection.edit ustc.clock 1
kill @e[tag=ustc.launch]
kill @e[tag=ustc.roof_label]
fill -1999 27 -1544 -1981 27 -1526 smooth_stone
fill -1999 28 -1544 -1981 32 -1526 air
fill -1992 27 -1555 -1988 27 -1544 smooth_stone
fill -1992 28 -1555 -1988 30 -1544 air
fill -1995 -1 -1565 -1985 -1 -1555 bedrock
fill -1995 0 -1565 -1985 1 -1555 stone_bricks
fill -1994 0 -1564 -1986 1 -1556 water
fill -1995 2 -1565 -1985 3 -1555 air
fill -1992 1 -1570 -1988 1 -1566 polished_deepslate
fill -1992 2 -1570 -1988 4 -1566 air
setblock -1990 1 -1568 slime_block
summon marker -1989.5 2 -1567.5 {"Tags":["ustc.marker","ustc.launch","ustc.launch.A","pvp.launch:-1989.5,28,-1541.5"]}
summon text_display -1989.5 5 -1567.5 {"Tags":["ustc.decor","ustc.roof_label"],"text":{"text":"A 楼顶弹射器 · 站上中心","color":"aqua"},"billboard":"center","background":1073741824}
summon text_display -1989.5 30 -1554.5 {"Tags":["ustc.decor","ustc.roof_label"],"text":{"text":"下楼落水区 ↓","color":"aqua"},"billboard":"center","background":1073741824}
fill -1719 28 -1544 -1701 28 -1526 smooth_stone
fill -1719 29 -1544 -1701 33 -1526 air
fill -1712 28 -1555 -1708 28 -1544 smooth_stone
fill -1712 29 -1555 -1708 31 -1544 air
fill -1715 -1 -1565 -1705 -1 -1555 bedrock
fill -1715 0 -1565 -1705 1 -1555 stone_bricks
fill -1714 0 -1564 -1706 1 -1556 water
fill -1715 2 -1565 -1705 3 -1555 air
fill -1712 1 -1570 -1708 1 -1566 polished_deepslate
fill -1712 2 -1570 -1708 4 -1566 air
setblock -1710 1 -1568 slime_block
summon marker -1709.5 2 -1567.5 {"Tags":["ustc.marker","ustc.launch","ustc.launch.C","pvp.launch:-1709.5,29,-1541.5"]}
summon text_display -1709.5 5 -1567.5 {"Tags":["ustc.decor","ustc.roof_label"],"text":{"text":"C 楼顶弹射器 · 站上中心","color":"aqua"},"billboard":"center","background":1073741824}
summon text_display -1709.5 31 -1554.5 {"Tags":["ustc.decor","ustc.roof_label"],"text":{"text":"下楼落水区 ↓","color":"aqua"},"billboard":"center","background":1073741824}
scoreboard players set #protection.edit ustc.clock 0
