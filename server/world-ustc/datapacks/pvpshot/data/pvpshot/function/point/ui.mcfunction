data modify storage pvpshot:tmp point_name set value "据点"
execute if data entity @s data.label run data modify storage pvpshot:tmp point_name set from entity @s data.label
data modify storage pvpshot:tmp owner set value "中立"
data modify storage pvpshot:tmp color set value "gray"
execute if score @s pvpshot.owner matches 1 run data modify storage pvpshot:tmp owner set value "红队"
execute if score @s pvpshot.owner matches 1 run data modify storage pvpshot:tmp color set value "red"
execute if score @s pvpshot.owner matches 2 run data modify storage pvpshot:tmp owner set value "蓝队"
execute if score @s pvpshot.owner matches 2 run data modify storage pvpshot:tmp color set value "blue"
data modify storage pvpshot:tmp side set value "红方"
execute if score @s pvpshot.capture matches ..-1 run data modify storage pvpshot:tmp side set value "蓝方"
scoreboard players operation #progress pvpshot.cal = @s pvpshot.capture
execute if score #progress pvpshot.cal matches ..-1 run scoreboard players operation #progress pvpshot.cal *= #negative pvpshot.cal
scoreboard players operation #progress pvpshot.cal *= #hundred pvpshot.cal
scoreboard players operation #progress pvpshot.cal /= #point.capture pvpshot.cfg
execute store result storage pvpshot:tmp progress int 1 run scoreboard players get #progress pvpshot.cal
data modify storage pvpshot:tmp status set value ""
execute if score #red pvpshot.cal matches 1.. if score #blue pvpshot.cal matches 1.. run data modify storage pvpshot:tmp status set value " | 争夺中"
function pvpshot:point/ui_show with storage pvpshot:tmp
