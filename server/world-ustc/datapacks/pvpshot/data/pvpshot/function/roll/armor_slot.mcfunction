execute store result score #r pvpshot.cal run random value 1..3
execute if score #r pvpshot.cal matches 1 run data modify storage pvpshot:roll slot set value "chestplate"
execute if score #r pvpshot.cal matches 2 run data modify storage pvpshot:roll slot set value "leggings"
execute if score #r pvpshot.cal matches 3 run data modify storage pvpshot:roll slot set value "boots"
