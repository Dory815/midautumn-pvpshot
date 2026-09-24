execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
execute positioned ~ ~-0.9 ~ as @e[type=armor_stand,tag=pvp.fake,distance=..1.5,sort=nearest,limit=1] if entity @s[nbt=!{Health:0.0f}]
execute positioned ~ ~-0.75 ~ as @e[type=armor_stand,tag=pvp.fake,distance=..1.4,sort=nearest,limit=1] if entity @s[nbt=!{Health:0.0f}]
execute positioned ~ ~-0.3 ~ as @e[type=armor_stand,tag=pvp.fake,distance=..1.1,sort=nearest,limit=1] if entity @s[nbt=!{Health:0.0f}]
execute positioned ^ ^ ^0.5 run function ustc_pvp:stress/hitone
execute positioned ^ ^ ^1.0 run function ustc_pvp:stress/hitone
execute positioned ^ ^ ^1.5 run function ustc_pvp:stress/hitone
execute positioned ^ ^ ^2.0 run function ustc_pvp:stress/hitone
