$tp @s ~ ~ ~ $(yaw) 0
$execute at @s rotated as @s run function pvpshot:deploy/check_$(kind)
execute unless score #place.ok pvpshot.cal matches 1 run return run kill @s
scoreboard players set #template.ok pvpshot.cal 0
execute at @s store success score #template.ok pvpshot.cal run function pvpshot:deploy/place_template with storage pvpshot:place
execute unless score #template.ok pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute unless score #place.ok pvpshot.cal matches 1 run return run kill @s
tag @s add pvpshot.machine
$tag @s add pvpshot.$(kind)
data modify entity @s data.rotation set from storage pvpshot:place rotation
data modify entity @s data.owner set from entity @a[tag=pvpshot.builder,limit=1] UUID
scoreboard players set @s pvpshot.age 0
$execute at @s rotated as @s run function pvpshot:$(kind)/load
