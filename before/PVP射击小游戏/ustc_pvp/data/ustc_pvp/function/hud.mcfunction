bossbar set ustc_pvp:points players @a
execute if score #reset.active ustc.clock matches 1 run return 0
bossbar set ustc_pvp:points max 1
bossbar set ustc_pvp:points value 0
bossbar set ustc_pvp:points visible true
execute if score #preset ustc.clock matches 0 run bossbar set ustc_pvp:points visible false
data modify storage ustc_pvp:hud a set value "gray"
execute if entity @e[tag=ustc.point.A,tag=pvpshot.point,scores={pvpshot.owner=1}] run data modify storage ustc_pvp:hud a set value "red"
execute if entity @e[tag=ustc.point.A,tag=pvpshot.point,scores={pvpshot.owner=2}] run data modify storage ustc_pvp:hud a set value "blue"
execute as @e[tag=ustc.point.A] unless score @s ustc.owner_old = @s pvpshot.owner run function ustc_pvp:flag/a
data modify storage ustc_pvp:hud b set value "gray"
execute if entity @e[tag=ustc.point.B,tag=pvpshot.point,scores={pvpshot.owner=1}] run data modify storage ustc_pvp:hud b set value "red"
execute if entity @e[tag=ustc.point.B,tag=pvpshot.point,scores={pvpshot.owner=2}] run data modify storage ustc_pvp:hud b set value "blue"
execute as @e[tag=ustc.point.B] unless score @s ustc.owner_old = @s pvpshot.owner run function ustc_pvp:flag/b
data modify storage ustc_pvp:hud c set value "gray"
execute if entity @e[tag=ustc.point.C,tag=pvpshot.point,scores={pvpshot.owner=1}] run data modify storage ustc_pvp:hud c set value "red"
execute if entity @e[tag=ustc.point.C,tag=pvpshot.point,scores={pvpshot.owner=2}] run data modify storage ustc_pvp:hud c set value "blue"
execute as @e[tag=ustc.point.C] unless score @s ustc.owner_old = @s pvpshot.owner run function ustc_pvp:flag/c
data modify storage ustc_pvp:hud d set value "gray"
execute if entity @e[tag=ustc.point.D,tag=pvpshot.point,scores={pvpshot.owner=1}] run data modify storage ustc_pvp:hud d set value "red"
execute if entity @e[tag=ustc.point.D,tag=pvpshot.point,scores={pvpshot.owner=2}] run data modify storage ustc_pvp:hud d set value "blue"
execute as @e[tag=ustc.point.D] unless score @s ustc.owner_old = @s pvpshot.owner run function ustc_pvp:flag/d
data modify storage ustc_pvp:hud e set value "gray"
execute if entity @e[tag=ustc.point.E,tag=pvpshot.point,scores={pvpshot.owner=1}] run data modify storage ustc_pvp:hud e set value "red"
execute if entity @e[tag=ustc.point.E,tag=pvpshot.point,scores={pvpshot.owner=2}] run data modify storage ustc_pvp:hud e set value "blue"
execute as @e[tag=ustc.point.E] unless score @s ustc.owner_old = @s pvpshot.owner run function ustc_pvp:flag/e
execute if score #preset ustc.clock matches 3 run function ustc_pvp:hud_three with storage ustc_pvp:hud
execute if score #preset ustc.clock matches 5 run function ustc_pvp:hud_five with storage ustc_pvp:hud
