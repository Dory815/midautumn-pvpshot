scoreboard players add #clock pvpshot.field_time 1
execute as @e[type=marker,tag=pvpshot.field] at @s run function pvpshot:field/tick_one
