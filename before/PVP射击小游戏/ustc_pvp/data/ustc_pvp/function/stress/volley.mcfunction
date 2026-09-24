execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
summon item_display -1900 252 -1500 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
scoreboard players remove #stress.n ustc.clock 1
execute if score #stress.n ustc.clock matches 1.. run function ustc_pvp:stress/volley
