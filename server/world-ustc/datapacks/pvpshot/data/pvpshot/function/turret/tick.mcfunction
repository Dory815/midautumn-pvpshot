scoreboard players operation #phase pvpshot.cal = @s pvpshot.age
scoreboard players operation #phase pvpshot.cal %= #twenty pvpshot.cal
execute if score @s pvpshot.age matches 20..360 if score #phase pvpshot.cal matches 0 run function pvpshot:turret/fire
execute if score #phase pvpshot.cal matches 6 run function pvpshot:turret/unpower
execute if score @s pvpshot.age matches 380.. run kill @s
