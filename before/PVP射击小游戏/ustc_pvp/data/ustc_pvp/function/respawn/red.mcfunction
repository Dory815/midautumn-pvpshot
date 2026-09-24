execute if score #mode pvpshot.cfg matches 1 if entity @e[tag=ustc.point.A,tag=pvpshot.point,scores={pvpshot.owner=1}] run tag @e[tag=ustc.spawn.A] add ustc.eligible
execute if score #mode pvpshot.cfg matches 1 if entity @e[tag=ustc.point.B,tag=pvpshot.point,scores={pvpshot.owner=1}] run tag @e[tag=ustc.spawn.B] add ustc.eligible
execute if score #mode pvpshot.cfg matches 1 if entity @e[tag=ustc.point.C,tag=pvpshot.point,scores={pvpshot.owner=1}] run tag @e[tag=ustc.spawn.C] add ustc.eligible
execute if score #mode pvpshot.cfg matches 1 if entity @e[tag=ustc.point.D,tag=pvpshot.point,scores={pvpshot.owner=1}] run tag @e[tag=ustc.spawn.D] add ustc.eligible
execute if score #mode pvpshot.cfg matches 1 if entity @e[tag=ustc.point.E,tag=pvpshot.point,scores={pvpshot.owner=1}] run tag @e[tag=ustc.spawn.E] add ustc.eligible
execute if score #mode pvpshot.cfg matches 0 run tag @e[tag=ustc.spawn.A] add ustc.eligible
execute if score #mode pvpshot.cfg matches 0 run tag @e[tag=ustc.spawn.E] add ustc.eligible
execute as @e[tag=ustc.eligible] at @s if entity @a[team=pvpshot.blue,gamemode=!spectator,nbt=!{Health:0.0f},distance=..24] run tag @s remove ustc.eligible
execute as @e[tag=ustc.eligible] at @s unless block ~ ~ ~ air run tag @s remove ustc.eligible
execute as @e[tag=ustc.eligible] at @s unless block ~ ~1 ~ air run tag @s remove ustc.eligible
execute as @e[tag=ustc.eligible] at @s if block ~ ~-1 ~ #pvpshot:blast_passable run tag @s remove ustc.eligible
execute unless entity @e[tag=ustc.eligible] run tag @e[tag=pvpshot.spawn.red] add ustc.eligible
