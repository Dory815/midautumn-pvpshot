execute unless score @s pvpshot.point_init matches 1 run function pvpshot:point/reset
execute store result score #point.ymin pvpshot.cal run data get entity @s Pos[1] 100
scoreboard players operation #point.ymax pvpshot.cal = #point.ymin pvpshot.cal
scoreboard players operation #point.h pvpshot.cal = #point.height pvpshot.cfg
scoreboard players operation #point.h pvpshot.cal *= #hundred pvpshot.cal
scoreboard players operation #point.ymin pvpshot.cal -= #point.h pvpshot.cal
scoreboard players operation #point.ymax pvpshot.cal += #point.h pvpshot.cal
execute store result storage pvpshot:tmp radius int 1 run scoreboard players get #point.radius pvpshot.cfg
function pvpshot:point/count with storage pvpshot:tmp
# A numerical majority advances one tick; a tie freezes progress.
execute if score #red pvpshot.cal > #blue pvpshot.cal if score @s pvpshot.capture < #point.capture pvpshot.cfg run scoreboard players add @s pvpshot.capture 1
execute if score #blue pvpshot.cal > #red pvpshot.cal if score @s pvpshot.capture > #capture.min pvpshot.cal run scoreboard players remove @s pvpshot.capture 1
# Crossing zero neutralizes a hostile point before it can be captured.
execute if score @s pvpshot.owner matches 1 if score @s pvpshot.capture matches ..0 run scoreboard players set @s pvpshot.owner 0
execute if score @s pvpshot.owner matches 2 if score @s pvpshot.capture matches 0.. run scoreboard players set @s pvpshot.owner 0
execute if score @s pvpshot.capture >= #point.capture pvpshot.cfg run scoreboard players set @s pvpshot.owner 1
execute if score @s pvpshot.capture <= #capture.min pvpshot.cal run scoreboard players set @s pvpshot.owner 2
# Enemy presence stops income even while the point is still owned.
execute if score #point.pulse pvpshot.cal matches 1 if score @s pvpshot.owner matches 1 if score #blue pvpshot.cal matches 0 run scoreboard players operation Red pvpshot.score += #point.score pvpshot.cfg
execute if score #point.pulse pvpshot.cal matches 1 if score @s pvpshot.owner matches 2 if score #red pvpshot.cal matches 0 run scoreboard players operation Blue pvpshot.score += #point.score pvpshot.cfg
execute if score #point.clock pvpshot.cal matches 0 run function pvpshot:point/ui
execute if score #point.clock pvpshot.cal matches 10 run function pvpshot:point/ui
