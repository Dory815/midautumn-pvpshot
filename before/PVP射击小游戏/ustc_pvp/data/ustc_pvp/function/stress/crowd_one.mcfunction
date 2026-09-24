execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
summon armor_stand -1900 252 -1500 {Tags:["pvp.fake","pvp.stress"],NoGravity:1b,Marker:1b,Invisible:1b}
scoreboard players remove #stress.n ustc.clock 1
execute if score #stress.n ustc.clock matches 1.. positioned -1900 252 -1500 run function ustc_pvp:stress/crowd_one
