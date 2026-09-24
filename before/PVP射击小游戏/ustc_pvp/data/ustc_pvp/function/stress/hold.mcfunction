execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
execute as @e[type=item_display,tag=pvp.stress] run tp @s -1896 252 -1496 0 0
execute as @e[type=item_display,tag=pvp.stress] run scoreboard players set @s pvpshot.age 1
execute as @e[type=item_display,tag=pvp.stress] run scoreboard players set @s pvpshot.velocity 18000
execute as @e[type=item_display,tag=pvp.stress] at @s rotated as @s run function pvpshot:shot/tick
execute as @e[type=item_display,tag=pvp.stress] run tp @s -1896 252 -1496 0 0
scoreboard players add #stress.t ustc.clock 1
execute if score #stress.t ustc.clock matches ..140 run schedule function ustc_pvp:stress/hold 1t replace
