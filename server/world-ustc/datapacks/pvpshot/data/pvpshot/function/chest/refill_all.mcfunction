scoreboard players set #chest.timer pvpshot.chest 0
execute as @e[type=minecraft:marker,tag=pvpshot.chest] at @s run function pvpshot:chest/refill_one
