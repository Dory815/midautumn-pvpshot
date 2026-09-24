tag @e[tag=ustc.point] remove pvpshot.point
execute if score #preset ustc.clock matches 3..5 run tag @e[tag=ustc.point.A] add pvpshot.point
execute if score #preset ustc.clock matches 3..5 run tag @e[tag=ustc.point.B] add pvpshot.point
execute if score #preset ustc.clock matches 3..5 run tag @e[tag=ustc.point.C] add pvpshot.point
execute if score #preset ustc.clock matches 5 run tag @e[tag=ustc.point.D] add pvpshot.point
execute if score #preset ustc.clock matches 5 run tag @e[tag=ustc.point.E] add pvpshot.point
scoreboard players set #mode pvpshot.cfg 1
execute if score #preset ustc.clock matches 0 run scoreboard players set #mode pvpshot.cfg 0
scoreboard players set #cap.max pvpshot.cfg 600
execute if score #preset ustc.clock matches 5 run scoreboard players set #cap.max pvpshot.cfg 1000
execute as @e[tag=ustc.point] at @s run function pvpshot:point/reset
scoreboard players set @e[tag=ustc.point] ustc.owner_old -1
function pvpshot:match/restart
function ustc_pvp:hud
execute as @a[team=pvpshot.red] run function ustc_pvp:spawn
execute as @a[team=pvpshot.blue] run function ustc_pvp:spawn
function ustc_pvp:advanced/refill
