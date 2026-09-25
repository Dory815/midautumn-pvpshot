data modify block ~ ~ ~ Items set value []
loot insert ~ ~ ~ loot pvpshot:item/rocket
loot insert ~ ~ ~ loot pvpshot:item/rocket
loot insert ~ ~ ~ loot pvpshot:item/speed
loot insert ~ ~ ~ loot pvpshot:item/jump
loot insert ~ ~ ~ loot pvpshot:item/heal
loot insert ~ ~ ~ loot pvpshot:item/grenade
loot insert ~ ~ ~ loot pvpshot:item/bow
loot insert ~ ~ ~ loot pvpshot:item/crossbow
loot insert ~ ~ ~ loot pvpshot:item/shotgun
loot insert ~ ~ ~ loot pvpshot:item/bunker
execute store result score #aircraft.roll ustc.clock run random value 1..16
execute if score #aircraft.roll ustc.clock matches 1 run loot insert ~ ~ ~ loot pvpshot:item/fighter
execute if score #aircraft.roll ustc.clock matches 2 run loot insert ~ ~ ~ loot pvpshot:item/orbital380
execute if score #aircraft.roll ustc.clock matches 3 run loot insert ~ ~ ~ loot pvpshot:item/eagle500
execute if score #aircraft.roll ustc.clock matches 4 run loot insert ~ ~ ~ loot pvpshot:item/airburst
