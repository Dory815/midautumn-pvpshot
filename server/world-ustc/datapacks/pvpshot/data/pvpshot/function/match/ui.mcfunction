execute if score #mode pvpshot.cfg matches 0 run scoreboard players operation #match.limit pvpshot.cal = #tdm.max pvpshot.cfg
execute if score #mode pvpshot.cfg matches 1 run scoreboard players operation #match.limit pvpshot.cal = #cap.max pvpshot.cfg
execute unless score #match.limit pvpshot.cal matches 1.. run scoreboard players set #match.limit pvpshot.cal 60
bossbar set pvpshot:red players @a
bossbar set pvpshot:blue players @a
execute store result bossbar pvpshot:red max run scoreboard players get #match.limit pvpshot.cal
execute store result bossbar pvpshot:blue max run scoreboard players get #match.limit pvpshot.cal
execute store result bossbar pvpshot:red value run scoreboard players get Red pvpshot.score
execute store result bossbar pvpshot:blue value run scoreboard players get Blue pvpshot.score
data modify storage pvpshot:tmp mode_name set value "多点占领"
execute if score #mode pvpshot.cfg matches 0 run data modify storage pvpshot:tmp mode_name set value "团队死斗"
data modify storage pvpshot:tmp phase set value ""
execute if score #match.state pvpshot.cal matches 2 run data modify storage pvpshot:tmp phase set value " · 已结束"
function pvpshot:match/ui_names with storage pvpshot:tmp
