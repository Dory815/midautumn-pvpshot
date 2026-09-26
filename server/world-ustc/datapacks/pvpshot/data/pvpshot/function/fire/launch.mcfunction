advancement revoke @s only pvpshot:use_fire_charge
execute unless score @s pvpshot.shooter matches 1.. run function pvpshot:shot/assign
scoreboard players operation #owner pvpshot.shooter = @s pvpshot.shooter
execute at @s rotated as @s anchored eyes positioned ^ ^ ^0.6 summon minecraft:item_display run function pvpshot:shot/init_fire
execute at @s run playsound minecraft:item.firecharge.use player @a[distance=..32] ~ ~ ~ 0.6 1.2
function pvpshot:regen/in_combat
