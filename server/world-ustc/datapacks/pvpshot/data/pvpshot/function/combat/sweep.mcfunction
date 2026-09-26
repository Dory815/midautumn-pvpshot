# Predict the next native movement segment, including drag/gravity. The native
# entity still handles travel; this function only supplies PVP collision damage.
tag @s add pvpshot.current_projectile
execute on origin if entity @s[type=minecraft:player] run tag @s add pvpshot.damage_source
# Ignore the launcher's body only until vanilla confirms the projectile left it.
# A returning snowball/egg or a turret arrow can then hit its owner normally.
execute unless entity @s[nbt={LeftOwner:1b}] on origin if entity @s[type=minecraft:player] run tag @s add pvpshot.launch_protected
execute if entity @s[type=minecraft:egg] store result storage pvpshot:tmp dmg int 1 run scoreboard players get #dmg.egg pvpshot.cfg
execute if entity @s[type=minecraft:arrow] store result storage pvpshot:tmp dmg int 1 run scoreboard players get #dmg.turret pvpshot.cfg
execute store result score #vx pvpshot.cal run data get entity @s Motion[0] 1000000
execute store result score #vy pvpshot.cal run data get entity @s Motion[1] 1000000
execute store result score #vz pvpshot.cal run data get entity @s Motion[2] 1000000
execute unless entity @s[nbt={NoGravity:1b}] unless entity @s[type=minecraft:arrow] run scoreboard players remove #vy pvpshot.cal 30000
execute store result storage pvpshot:ray dx double 0.000000061875 run scoreboard players get #vx pvpshot.cal
execute store result storage pvpshot:ray dy double 0.000000061875 run scoreboard players get #vy pvpshot.cal
execute store result storage pvpshot:ray dz double 0.000000061875 run scoreboard players get #vz pvpshot.cal
execute if predicate pvpshot:in_water store result storage pvpshot:ray dx double 0.00000005 run scoreboard players get #vx pvpshot.cal
execute if predicate pvpshot:in_water store result storage pvpshot:ray dy double 0.00000005 run scoreboard players get #vy pvpshot.cal
execute if predicate pvpshot:in_water store result storage pvpshot:ray dz double 0.00000005 run scoreboard players get #vz pvpshot.cal
# Arrows apply drag/gravity after their collision trace rather than before it.
execute if entity @s[type=minecraft:arrow] store result storage pvpshot:ray dx double 0.0000000625 run scoreboard players get #vx pvpshot.cal
execute if entity @s[type=minecraft:arrow] store result storage pvpshot:ray dy double 0.0000000625 run scoreboard players get #vy pvpshot.cal
execute if entity @s[type=minecraft:arrow] store result storage pvpshot:ray dz double 0.0000000625 run scoreboard players get #vz pvpshot.cal
execute store result score #back pvpshot.cal run data get storage pvpshot:ray dx 1000000
execute store result storage pvpshot:ray back_x double -0.000001 run scoreboard players get #back pvpshot.cal
execute store result score #back pvpshot.cal run data get storage pvpshot:ray dy 1000000
execute store result storage pvpshot:ray back_y double -0.000001 run scoreboard players get #back pvpshot.cal
execute store result score #back pvpshot.cal run data get storage pvpshot:ray dz 1000000
execute store result storage pvpshot:ray back_z double -0.000001 run scoreboard players get #back pvpshot.cal
scoreboard players set #steps pvpshot.cal 16
scoreboard players set #hit pvpshot.cal 0
function pvpshot:combat/ray_step
execute if score #hit pvpshot.cal matches 1 run kill @s
tag @s remove pvpshot.current_projectile
tag @a[tag=pvpshot.launch_protected] remove pvpshot.launch_protected
tag @a[tag=pvpshot.damage_source] remove pvpshot.damage_source
