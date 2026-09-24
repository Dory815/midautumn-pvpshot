data modify block ~ ~ ~ Items set value []
execute store result score #aircraft.roll ustc.clock run random value 1..4
execute if score #aircraft.roll ustc.clock matches 1 run loot insert ~ ~ ~ loot pvpshot:item/fighter
execute if score #aircraft.roll ustc.clock matches 2 run loot insert ~ ~ ~ loot pvpshot:item/orbital380
execute if score #aircraft.roll ustc.clock matches 3 run loot insert ~ ~ ~ loot pvpshot:item/eagle500
execute if score #aircraft.roll ustc.clock matches 4 run loot insert ~ ~ ~ loot pvpshot:item/airburst
execute if score #aircraft.roll ustc.clock matches 4 run loot insert ~ ~ ~ loot pvpshot:item/airburst
execute store result score #rocket.roll ustc.clock run random value 1..2
execute if score #rocket.roll ustc.clock matches 1 run loot insert ~ ~ ~ loot pvpshot:item/rocket
loot insert ~ ~ ~ loot pvpshot:item/speed
loot insert ~ ~ ~ loot pvpshot:item/jump
loot insert ~ ~ ~ loot pvpshot:item/heal
loot insert ~ ~ ~ loot pvpshot:item/grenade
loot insert ~ ~ ~ loot pvpshot:item/bow
loot insert ~ ~ ~ loot pvpshot:item/crossbow
loot insert ~ ~ ~ loot pvpshot:item/shotgun
loot insert ~ ~ ~ loot pvpshot:item/bunker
execute store result score #mace.roll ustc.clock run random value 1..20
execute if score #mace.roll ustc.clock matches 1 run loot insert ~ ~ ~ loot pvpshot:item/mace
