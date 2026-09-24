$tp @s ~ ~ ~ $(yaw) 0
data modify storage pvpshot:place stair set value "south"
execute if entity @s[y_rotation=45..135] run data modify storage pvpshot:place stair set value "west"
execute if entity @s[y_rotation=135..180] run data modify storage pvpshot:place stair set value "north"
execute if entity @s[y_rotation=-180..-135] run data modify storage pvpshot:place stair set value "north"
execute if entity @s[y_rotation=-135..-45] run data modify storage pvpshot:place stair set value "east"
execute at @s rotated as @s run function pvpshot:deploy/check_ramp
execute unless score #place.ok pvpshot.cal matches 1 run return run kill @s
execute at @s rotated as @s run function pvpshot:deploy/place_ramp with storage pvpshot:place
scoreboard players set #place.ok pvpshot.cal 1
kill @s
