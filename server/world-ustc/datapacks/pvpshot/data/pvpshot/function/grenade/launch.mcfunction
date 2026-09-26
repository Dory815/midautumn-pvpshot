advancement revoke @s only pvpshot:use_grenade
data modify storage pvpshot:grenade owner set from entity @s UUID
execute store result storage pvpshot:grenade fuse int 1 run scoreboard players get #grenade.fuse pvpshot.cfg
execute rotated as @s positioned 0.0 0.2 0.0 positioned ^ ^ ^0.9 summon minecraft:marker run function pvpshot:grenade/vector
execute at @s rotated as @s anchored eyes positioned ^ ^ ^0.8 run function pvpshot:grenade/spawn with storage pvpshot:grenade
execute at @s run playsound minecraft:entity.snowball.throw player @a[distance=..24] ~ ~ ~ 0.8 0.6
function pvpshot:regen/in_combat
