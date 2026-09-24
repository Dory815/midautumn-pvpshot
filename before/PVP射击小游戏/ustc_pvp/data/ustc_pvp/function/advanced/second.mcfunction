execute if score #reset.active ustc.clock matches 1 run return 0
scoreboard players add #advanced.timer ustc.clock 1
execute if score #advanced.timer ustc.clock matches 300.. run function ustc_pvp:advanced/refill
