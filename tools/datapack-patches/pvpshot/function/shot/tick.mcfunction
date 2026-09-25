scoreboard players add @s pvpshot.age 1
execute if score @s pvpshot.age matches 100.. run return run kill @s
execute if entity @s[tag=pvpshot.smg_shot] if score @s pvpshot.age matches 17.. run return run kill @s
tag @s add pvpshot.current_projectile
scoreboard players operation #owner pvpshot.shooter = @s pvpshot.shooter
execute as @a if score @s pvpshot.shooter = #owner pvpshot.shooter run tag @s add pvpshot.damage_source
execute if score @s pvpshot.age matches ..2 run tag @a[tag=pvpshot.damage_source] add pvpshot.launch_protected
scoreboard players set #rocket pvpshot.cal 0
execute if entity @s[tag=pvpshot.rocket_shot] run scoreboard players set #rocket pvpshot.cal 1
execute unless entity @s[tag=pvpshot.fire_shot] run scoreboard players add @s pvpshot.velocity 1000
execute if entity @s[tag=pvpshot.fire_shot] run scoreboard players add @s pvpshot.velocity 1500
execute unless predicate pvpshot:in_water run scoreboard players operation @s pvpshot.velocity *= #95 pvpshot.cal
execute if predicate pvpshot:in_water run scoreboard players operation @s pvpshot.velocity *= #80 pvpshot.cal
scoreboard players operation @s pvpshot.velocity /= #100 pvpshot.cal
execute store result storage pvpshot:shot step double 0.00000625 run scoreboard players get @s pvpshot.velocity
scoreboard players set #hit pvpshot.cal 0
scoreboard players set #steps pvpshot.cal 16
execute store result storage pvpshot:shot dmg int 1 run scoreboard players get #dmg.rifle pvpshot.cfg
execute if entity @s[tag=pvpshot.smg_shot] run data modify storage pvpshot:shot dmg set value 2
execute if entity @s[tag=pvpshot.smg_shot] if score @s pvpshot.age matches 9.. run data modify storage pvpshot:shot dmg set value 1
function pvpshot:shot/step
execute if score #hit pvpshot.cal matches 1 run kill @s
tag @s remove pvpshot.current_projectile
tag @a[tag=pvpshot.damage_source] remove pvpshot.damage_source
tag @a[tag=pvpshot.launch_protected] remove pvpshot.launch_protected
