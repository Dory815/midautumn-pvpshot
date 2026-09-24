execute unless score #mode pvpshot.cfg matches 1 run return 0
execute unless score #match.state pvpshot.cal matches 1 run return 0
scoreboard players set #point.pulse pvpshot.cal 0
scoreboard players add #point.clock pvpshot.cal 1
execute if score #point.clock pvpshot.cal >= #point.interval pvpshot.cfg run scoreboard players set #point.pulse pvpshot.cal 1
execute if score #point.pulse pvpshot.cal matches 1 run scoreboard players set #point.clock pvpshot.cal 0
scoreboard players operation #capture.min pvpshot.cal = #point.capture pvpshot.cfg
scoreboard players operation #capture.min pvpshot.cal *= #negative pvpshot.cal
execute as @e[type=minecraft:marker,tag=pvpshot.point] at @s run function pvpshot:point/tick_one
