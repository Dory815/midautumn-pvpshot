execute as @e[type=minecraft:snowball,nbt={Item:{components:{"minecraft:custom_data":{pvpshot:{weapon:"snowball"}}}}}] at @s run function pvpshot:combat/sweep
execute as @e[type=minecraft:egg,nbt={Item:{components:{"minecraft:custom_data":{pvpshot:{weapon:"egg"}}}}}] at @s run function pvpshot:combat/sweep
execute as @e[type=minecraft:arrow,tag=pvpshot.turret_arrow,nbt=!{inGround:1b}] at @s run function pvpshot:combat/sweep
execute as @e[type=minecraft:arrow,tag=pvpshot.turret_arrow,nbt=!{inGround:1b}] at @s run particle minecraft:end_rod ~ ~ ~ 0 0 0 0 1 normal
