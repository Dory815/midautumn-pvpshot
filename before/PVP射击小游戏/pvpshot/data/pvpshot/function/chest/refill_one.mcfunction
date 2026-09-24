data modify block ~ ~ ~ Items set value []
function pvpshot:roll/primary
function pvpshot:chest/insert_primary with storage pvpshot:roll
function pvpshot:roll/special
function pvpshot:chest/insert_special with storage pvpshot:roll
function pvpshot:roll/primary
function pvpshot:chest/insert_primary with storage pvpshot:roll
function pvpshot:roll/special
function pvpshot:chest/insert_special with storage pvpshot:roll
function pvpshot:chest/insert_armor
function pvpshot:chest/insert_deploy
execute store result score #rocket.roll pvpshot.cal run random value 1..2
execute if score #rocket.roll pvpshot.cal matches 1 run loot insert ~ ~ ~ loot pvpshot:item/rocket
loot insert ~ ~ ~ loot pvpshot:item/grenade
loot insert ~ ~ ~ loot pvpshot:item/grenade
loot insert ~ ~ ~ loot pvpshot:item/speed
loot insert ~ ~ ~ loot pvpshot:item/jump
loot insert ~ ~ ~ loot pvpshot:item/heal
loot insert ~ ~ ~ loot pvpshot:item/arrows_supply
execute if entity @e[type=marker,tag=pvpshot.chest.rich,distance=..1,limit=1] run function pvpshot:chest/refill_rich
loot insert ~ ~ ~ loot pvpshot:item/shotgun
execute store result score #bunker.roll pvpshot.cal run random value 1..4
execute if score #bunker.roll pvpshot.cal matches 1 run loot insert ~ ~ ~ loot pvpshot:item/bunker
execute store result score #mace.roll pvpshot.cal run random value 1..20
execute if score #mace.roll pvpshot.cal matches 1 run loot insert ~ ~ ~ loot pvpshot:item/mace
