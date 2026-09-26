# The owner travels in the ammunition, so neighbouring turrets cannot claim
# each other's arrows; setup happens in the native dispenser spawn callback.
data modify entity @s Owner set from entity @s item.components."minecraft:custom_data".pvpshot.owner
data modify entity @s Motion set from entity @s item.components."minecraft:custom_data".pvpshot.motion
tag @s add pvpshot.turret_arrow
data modify entity @s damage set value 0.0d
data modify entity @s crit set value 0b
data modify entity @s pickup set value 0b
execute at @s run function pvpshot:combat/sweep
