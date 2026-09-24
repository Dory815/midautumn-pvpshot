tag @s add pvpshot.shot
tag @s add pvpshot.rocket_shot
scoreboard players operation @s pvpshot.shooter = #owner pvpshot.shooter
scoreboard players set @s pvpshot.age 0
scoreboard players set @s pvpshot.velocity 12000
tp @s ~ ~ ~ ~ ~
data merge entity @s {item:{id:"minecraft:firework_rocket",count:1},billboard:"center",view_range:4f,teleport_duration:1,brightness:{block:15,sky:15},transformation:{scale:[0.5f,0.5f,0.5f]}}
