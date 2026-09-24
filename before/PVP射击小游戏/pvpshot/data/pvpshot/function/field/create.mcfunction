scoreboard players set #field.owner pvpshot.shooter 0
execute as @a[tag=pvpshot.damage_source] unless score @s pvpshot.shooter matches 1.. run function pvpshot:shot/assign
execute as @a[tag=pvpshot.damage_source] run scoreboard players operation #field.owner pvpshot.shooter = @s pvpshot.shooter
execute summon minecraft:marker run function pvpshot:field/init
playsound minecraft:block.powder_snow.break player @a[distance=..24] ~ ~ ~ 0.5 0.8
