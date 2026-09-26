data modify storage pvpshot:place rotation set value "none"
data modify storage pvpshot:place yaw set value 0
execute if entity @s[y_rotation=45..135] run data modify storage pvpshot:place rotation set value "clockwise_90"
execute if entity @s[y_rotation=45..135] run data modify storage pvpshot:place yaw set value 90
execute if entity @s[y_rotation=135..180] run data modify storage pvpshot:place rotation set value "180"
execute if entity @s[y_rotation=135..180] run data modify storage pvpshot:place yaw set value 180
execute if entity @s[y_rotation=-180..-135] run data modify storage pvpshot:place rotation set value "180"
execute if entity @s[y_rotation=-180..-135] run data modify storage pvpshot:place yaw set value 180
execute if entity @s[y_rotation=-135..-45] run data modify storage pvpshot:place rotation set value "counterclockwise_90"
execute if entity @s[y_rotation=-135..-45] run data modify storage pvpshot:place yaw set value -90
