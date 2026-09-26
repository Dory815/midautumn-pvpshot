scoreboard players set #hit pvpshot.cal 1
execute if entity @e[type=minecraft:snowball,tag=pvpshot.current_projectile] run function pvpshot:field/create
