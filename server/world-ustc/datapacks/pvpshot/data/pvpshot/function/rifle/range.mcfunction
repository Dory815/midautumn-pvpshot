execute unless entity @e[type=marker,tag=pvpshot.rifle_origin,distance=..1.5,limit=1] run return 0
data modify storage pvpshot:shot dmg set value 1
execute if entity @e[type=marker,tag=pvpshot.rifle_origin,distance=..1,limit=1] run data modify storage pvpshot:shot dmg set value 3
scoreboard players set #rifle.ray pvpshot.cal 18
execute facing entity @e[type=marker,tag=pvpshot.rifle_origin,limit=1] feet run function pvpshot:rifle/ray
