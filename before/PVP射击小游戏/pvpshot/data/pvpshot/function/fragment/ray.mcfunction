execute unless block ~ ~ ~ #pvpshot:blast_passable run return 0
execute if entity @e[type=minecraft:marker,tag=pvpshot.fragment_origin,distance=..0.4,limit=1] run return run function pvpshot:fragment/hurt with storage pvpshot:fragment
scoreboard players remove #fragment.ray pvpshot.cal 1
execute if score #fragment.ray pvpshot.cal matches 1.. positioned ^ ^ ^0.25 run function pvpshot:fragment/ray
