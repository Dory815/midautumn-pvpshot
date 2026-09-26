data modify storage ustc_pvp:flag owner set value "中立"
data modify storage ustc_pvp:flag color set value "gray"
execute if score @s pvpshot.owner matches 1 run data modify storage ustc_pvp:flag owner set value "红队"
execute if score @s pvpshot.owner matches 1 run data modify storage ustc_pvp:flag color set value "red"
execute if score @s pvpshot.owner matches 2 run data modify storage ustc_pvp:flag owner set value "蓝队"
execute if score @s pvpshot.owner matches 2 run data modify storage ustc_pvp:flag color set value "blue"
execute unless entity @s[tag=pvpshot.point] run data modify storage ustc_pvp:flag owner set value "本模式停用"
data modify storage ustc_pvp:flag key set value "B"
data modify storage ustc_pvp:flag label set value "B · 中央院落"
function ustc_pvp:flag/text with storage ustc_pvp:flag
scoreboard players operation @s ustc.owner_old = @s pvpshot.owner
