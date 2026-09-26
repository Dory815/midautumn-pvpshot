execute if score #reset.index ustc.clock matches 176.. run return run function ustc_pvp:reset/finish
execute store result storage ustc_pvp:reset batch int 1 run scoreboard players get #reset.index ustc.clock
function ustc_pvp:reset/load_macro with storage ustc_pvp:reset
