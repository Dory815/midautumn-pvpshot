execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
forceload add -1896 -1496
fill -1912 248 -1512 -1888 248 -1488 minecraft:stone
fill -1912 249 -1512 -1888 270 -1488 minecraft:air
kill @e[type=item_display,tag=pvp.stress]
kill @e[type=tnt,tag=pvp.stress]
