execute unless score @s pvpshot.shooter matches 1.. run function pvpshot:shot/assign
scoreboard players operation #owner pvpshot.shooter = @s pvpshot.shooter
execute at @s rotated as @s anchored eyes positioned ^ ^ ^0.6 summon item_display run function pvpshot:smg/init
function pvpshot:regen/in_combat
