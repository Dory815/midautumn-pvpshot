execute as @e[type=minecraft:marker,tag=pvpshot.machine] at @s rotated as @s run function pvpshot:machine/tick_one
# Next tick only freshly dispensed entities can be claimed at a muzzle.
tag @e[type=minecraft:tnt] add pvpshot.seen
