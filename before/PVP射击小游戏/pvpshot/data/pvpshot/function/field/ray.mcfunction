execute unless block ~ ~ ~ #pvpshot:blast_passable run return 0
execute if entity @e[type=marker,tag=pvpshot.field_current,distance=..0.22,limit=1] run return run function pvpshot:field/affect
scoreboard players remove #field.ray pvpshot.cal 1
execute if score #field.ray pvpshot.cal matches 1.. positioned ^ ^ ^0.2 run function pvpshot:field/ray
