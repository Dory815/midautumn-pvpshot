execute if block ~ ~ ~ #pvpshot:point_core unless entity @e[type=minecraft:marker,tag=pvpshot.point,distance=..1.5] run summon minecraft:marker ~ ~1 ~ {Tags:["pvpshot.point"]}
execute if block ~ ~ ~ #pvpshot:spawn_red unless entity @e[type=minecraft:marker,tag=pvpshot.spawn.red,distance=..2] run summon minecraft:marker ~ ~1 ~ {Tags:["pvpshot.spawn.red"]}
execute if block ~ ~ ~ #pvpshot:spawn_blue unless entity @e[type=minecraft:marker,tag=pvpshot.spawn.blue,distance=..2] run summon minecraft:marker ~ ~1 ~ {Tags:["pvpshot.spawn.blue"]}
execute if block ~ ~ ~ minecraft:trapped_chest unless entity @e[type=minecraft:marker,tag=pvpshot.chest,distance=..1.5] run function pvpshot:discover/chest
