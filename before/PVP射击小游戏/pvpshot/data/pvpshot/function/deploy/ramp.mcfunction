function pvpshot:deploy/resolve_rotation
tag @a[tag=pvpshot.builder] remove pvpshot.builder
tag @s add pvpshot.builder
scoreboard players set #place.ok pvpshot.cal 0
execute at @s rotated ~ 0 positioned ^ ^ ^2 align xyz positioned ~0.5 ~ ~0.5 summon minecraft:marker run function pvpshot:deploy/ramp_build with storage pvpshot:place
execute unless score #place.ok pvpshot.cal matches 1 run loot give @s loot pvpshot:item/ramp
execute unless score #place.ok pvpshot.cal matches 1 run tellraw @s {text:"部署失败：触及据点、基地、补给箱保护区、基岩或世界边界，斜坡已退还。",color:"yellow"}
tag @s remove pvpshot.builder
