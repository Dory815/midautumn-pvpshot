execute unless loaded ~ ~ ~ run return run kill @s
execute unless block ~ ~ ~ #pvpshot:blast_passable run return run function pvpshot:shot/block
execute positioned ~ ~-0.9 ~ as @a[gamemode=!spectator,nbt=!{Health:0.0f},tag=!pvpshot.launch_protected,distance=..1.5,sort=nearest] unless predicate pvpshot:crouching unless predicate pvpshot:low_pose if predicate pvpshot:hit_standing run function pvpshot:shot/hit_standing
execute positioned ~ ~-0.75 ~ as @a[gamemode=!spectator,nbt=!{Health:0.0f},tag=!pvpshot.launch_protected,distance=..1.4,sort=nearest] if predicate pvpshot:crouching unless predicate pvpshot:low_pose if predicate pvpshot:hit_crouching run function pvpshot:shot/hit_crouching
execute positioned ~ ~-0.3 ~ as @a[gamemode=!spectator,nbt=!{Health:0.0f},tag=!pvpshot.launch_protected,distance=..1.1,sort=nearest] if predicate pvpshot:low_pose if predicate pvpshot:hit_low run function pvpshot:shot/hit_low
execute if score #hit pvpshot.cal matches 1 run return 1
execute if score #steps pvpshot.cal matches 0 run return run tp @s ~ ~ ~
scoreboard players remove #steps pvpshot.cal 1
function pvpshot:shot/advance with storage pvpshot:shot
