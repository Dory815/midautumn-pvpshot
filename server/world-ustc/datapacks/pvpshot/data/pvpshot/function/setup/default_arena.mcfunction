summon minecraft:marker ~ ~ ~ {Tags:["pvpshot.arena"]}
setblock ~-8 ~-1 ~ minecraft:red_concrete
setblock ~8 ~-1 ~ minecraft:blue_concrete
setblock ~ ~-1 ~8 minecraft:gold_block
setblock ~6 ~-1 ~6 minecraft:gold_block
setblock ~-6 ~-1 ~6 minecraft:gold_block
setblock ~ ~-1 ~-6 minecraft:trapped_chest
summon minecraft:marker ~-8 ~ ~ {Tags:["pvpshot.spawn.red"]}
summon minecraft:marker ~8 ~ ~ {Tags:["pvpshot.spawn.blue"]}
summon minecraft:marker ~ ~ ~8 {Tags:["pvpshot.point"]}
summon minecraft:marker ~6 ~ ~6 {Tags:["pvpshot.point"]}
summon minecraft:marker ~-6 ~ ~6 {Tags:["pvpshot.point"]}
summon minecraft:marker ~ ~-1 ~-6 {Tags:["pvpshot.chest"]}
execute positioned ~ ~-1 ~-6 run function pvpshot:chest/refill_one
