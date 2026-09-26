data modify storage pvpshot:shot owner set from entity @s data.owner
data modify storage pvpshot:shot rotation set from entity @s data.rotation
execute positioned ^1 ^1 ^4 as @e[type=minecraft:tnt,tag=!pvpshot.seen,tag=!pvpshot.cannon_shell,distance=..1.1] unless data entity @s owner run function pvpshot:cannon/launch
