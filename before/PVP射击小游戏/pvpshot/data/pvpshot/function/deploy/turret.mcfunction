data modify storage pvpshot:place structure set value "face_turret"
data modify storage pvpshot:place kind set value "turret"
function pvpshot:deploy/resolve_rotation
tag @a[tag=pvpshot.builder] remove pvpshot.builder
tag @s add pvpshot.builder
scoreboard players set #place.ok pvpshot.cal 0
function pvpshot:deploy/start with storage pvpshot:place
execute unless score #place.ok pvpshot.cal matches 1 run loot give @s loot pvpshot:item/turret_dye
execute unless score #place.ok pvpshot.cal matches 1 run tellraw @s {text:"部署失败：触及据点、基地、补给箱保护区、基岩或世界边界，部署物已退还。",color:"yellow"}
tag @s remove pvpshot.builder
