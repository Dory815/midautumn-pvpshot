execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
scoreboard players set #stress.t ustc.clock 999
kill @e[type=item_display,tag=pvp.stress]
kill @e[type=armor_stand,tag=pvp.stress]
kill @e[type=tnt,tag=pvp.stress]
fill -1912 248 -1512 -1888 270 -1488 minecraft:air
forceload remove -1904 -1504
