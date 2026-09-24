execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
execute as @e[type=item_display,tag=pvp.stress] at @s run function ustc_pvp:stress/hitload
execute as @e[type=item_display,tag=pvp.stress] run tp @s -1896 252 -1496 0 0
execute as @e[type=armor_stand,tag=pvp.fake] run function pvpshot:regen/player
execute as @e[type=armor_stand,tag=pvp.fake] run function pvpshot:player/feed
scoreboard players add #stress.t ustc.clock 1
execute if score #stress.t ustc.clock matches ..100 run schedule function ustc_pvp:stress/wave 1t replace
