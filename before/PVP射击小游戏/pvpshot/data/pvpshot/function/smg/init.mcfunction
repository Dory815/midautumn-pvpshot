function pvpshot:shot/init_fire
tag @s remove pvpshot.fire_shot
tag @s add pvpshot.smg_shot
data modify entity @s item set value {id:"minecraft:egg",count:1}
data modify entity @s transformation.scale set value [0.25f,0.25f,0.25f]
scoreboard players set @s pvpshot.velocity 12000
