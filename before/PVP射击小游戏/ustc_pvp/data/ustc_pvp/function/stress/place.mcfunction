execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
fill -1904 248 -1504 -1888 248 -1488 minecraft:stone
fill -1904 249 -1504 -1888 270 -1488 minecraft:air
execute if loaded -1896 252 -1496 run scoreboard players set #stress.loaded ustc.clock 1
execute if block -1896 252 -1496 minecraft:air run scoreboard players set #stress.air ustc.clock 1
