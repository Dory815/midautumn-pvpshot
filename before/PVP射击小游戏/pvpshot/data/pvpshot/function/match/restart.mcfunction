function pvpshot:field/clear
execute unless score #mode pvpshot.cfg matches 0..1 run scoreboard players set #mode pvpshot.cfg 1
execute unless score #point.capture pvpshot.cfg matches 1.. run scoreboard players set #point.capture pvpshot.cfg 100
execute unless score #point.interval pvpshot.cfg matches 1.. run scoreboard players set #point.interval pvpshot.cfg 20
scoreboard players set Red pvpshot.score 0
scoreboard players set Blue pvpshot.score 0
scoreboard players set #point.clock pvpshot.cal 0
scoreboard players set #point.pulse pvpshot.cal 0
scoreboard players set #match.state pvpshot.cal 1
scoreboard players set #match.result pvpshot.cal 0
scoreboard players operation #match.mode pvpshot.cal = #mode pvpshot.cfg
scoreboard players set #negative pvpshot.cal -1
scoreboard players set #hundred pvpshot.cal 100
execute as @e[type=minecraft:marker,tag=pvpshot.point] at @s run function pvpshot:point/reset
execute as @a run function pvpshot:player/score_init
execute as @a run scoreboard players operation @s pvpshot.kills_old = @s pvpshot.kills
execute if score #mode pvpshot.cfg matches 0 run scoreboard objectives modify pvpshot.score displayname {text:"团队死斗 · 击杀得分",color:"gold"}
execute if score #mode pvpshot.cfg matches 1 run scoreboard objectives modify pvpshot.score displayname {text:"多点占领 · 据点得分",color:"gold"}
title @a clear
function pvpshot:match/ui
scoreboard players add #ordnance.epoch pvpshot.cal 1
