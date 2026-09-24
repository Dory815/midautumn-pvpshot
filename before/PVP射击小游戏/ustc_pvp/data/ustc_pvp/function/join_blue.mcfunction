execute if score #reset.active ustc.clock matches 1 run return 0
scoreboard players set @s ustc.join 0
team join pvpshot.blue @s
gamemode survival @s
function pvpshot:player/score_init
function ustc_pvp:spawn
