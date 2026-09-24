execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
execute unless score #debug pvpshot.cfg matches 1 run return fail
function pvpshot:kit/base
loot give @s loot pvpshot:item/egg
loot give @s loot pvpshot:item/bow
loot give @s loot pvpshot:item/crossbow
loot give @s loot pvpshot:item/trident
loot give @s loot pvpshot:item/rocket
loot give @s loot pvpshot:item/snowball
loot give @s loot pvpshot:item/speed
loot give @s loot pvpshot:item/wind
loot give @s loot pvpshot:item/pearl
loot give @s loot pvpshot:item/harming
loot give @s loot pvpshot:item/slow
loot give @s loot pvpshot:item/blind
loot give @s loot pvpshot:item/heal
loot give @s loot pvpshot:item/linger
loot give @s loot pvpshot:item/tnt
loot give @s loot pvpshot:item/shield
loot give @s loot pvpshot:item/turret_dye
loot give @s loot pvpshot:item/cannon_dye
give @s minecraft:leather_chestplate
give @s minecraft:leather_leggings
give @s minecraft:leather_boots
give @s minecraft:golden_chestplate
give @s minecraft:golden_leggings
give @s minecraft:golden_boots
give @s minecraft:chainmail_chestplate
give @s minecraft:chainmail_leggings
give @s minecraft:chainmail_boots
give @s minecraft:iron_chestplate
give @s minecraft:iron_leggings
give @s minecraft:iron_boots
give @s minecraft:diamond_chestplate
give @s minecraft:diamond_leggings
give @s minecraft:diamond_boots
function pvpshot:kit/cap_red
