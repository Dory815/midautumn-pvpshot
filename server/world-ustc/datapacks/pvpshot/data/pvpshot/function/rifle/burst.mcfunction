summon minecraft:marker ~ ~ ~ {Tags:["pvpshot.rifle_origin"]}
particle minecraft:explosion ~ ~ ~ 0 0 0 0 1 normal
playsound minecraft:entity.generic.explode player @a[distance=..24] ~ ~ ~ 0.2 1.8
execute as @a[gamemode=!spectator,nbt=!{Health:0.0f},tag=!pvpshot.rifle_direct,distance=..3] at @s run function pvpshot:rifle/target
kill @e[type=marker,tag=pvpshot.rifle_origin]
