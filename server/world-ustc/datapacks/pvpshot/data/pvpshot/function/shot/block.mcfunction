scoreboard players set #hit pvpshot.cal 1
execute if score #rocket pvpshot.cal matches 1 run return run function pvpshot:rocket/burst
execute if entity @s[tag=pvpshot.smg_shot] run return 0
execute positioned ^ ^ ^-0.15 run function pvpshot:rifle/burst
execute if block ~ ~ ~ #pvpshot:destructible run setblock ~ ~ ~ air
