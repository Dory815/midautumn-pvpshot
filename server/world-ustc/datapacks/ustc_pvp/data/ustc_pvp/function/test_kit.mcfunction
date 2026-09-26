clear @s
function pvpshot:ammo/reset
function pvpshot:regen/in_combat
loot give @s loot pvpshot:item/cannon_dye
loot give @s loot pvpshot:item/turret_dye
loot give @s loot pvpshot:item/fire_charge
loot give @s loot pvpshot:item/grenade
loot give @s loot pvpshot:item/pickaxe
function pvpshot:kit/blocks
loot give @s loot pvpshot:item/egg
loot give @s loot pvpshot:item/bow
loot give @s loot pvpshot:item/crossbow
loot give @s loot pvpshot:item/trident
loot give @s loot pvpshot:item/snowball
loot give @s loot pvpshot:item/rocket
loot give @s loot pvpshot:item/speed
loot give @s loot pvpshot:item/jump
loot give @s loot pvpshot:item/fighter
loot give @s loot pvpshot:item/wind
loot give @s loot pvpshot:item/pearl
loot give @s loot pvpshot:item/harming
loot give @s loot pvpshot:item/slow
loot give @s loot pvpshot:item/blind
loot give @s loot pvpshot:item/heal
loot give @s loot pvpshot:item/linger
loot give @s loot pvpshot:item/tnt
loot give @s loot pvpshot:item/shield
item modify entity @s hotbar.0 ustc_pvp:deploy_count
item modify entity @s hotbar.1 ustc_pvp:deploy_count
give @s minecraft:arrow 36
effect give @s minecraft:instant_health 1 10 true
effect give @s minecraft:saturation 1 10 true
tellraw @s {text:"全套测试装备：1 TNT 炮 / 2 炮塔 / 3 火焰弹 / 4 手雷 / 5 铁镐 / 6 队色陶瓦。",color:"green"}
loot give @s loot pvpshot:item/shotgun
loot give @s loot pvpshot:item/bunker
loot give @s loot pvpshot:item/orbital380
loot give @s loot pvpshot:item/eagle500
loot give @s loot pvpshot:item/airburst
