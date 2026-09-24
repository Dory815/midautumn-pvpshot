execute unless block ~ ~ ~ #pvpshot:blast_passable run return 0
execute if entity @e[type=marker,tag=pvpshot.rifle_origin,distance=..0.12,limit=1] run return run function pvpshot:shot/damage with storage pvpshot:shot
scoreboard players remove #rifle.ray pvpshot.cal 1
execute if score #rifle.ray pvpshot.cal matches 1.. positioned ^ ^ ^0.1 run function pvpshot:rifle/ray
