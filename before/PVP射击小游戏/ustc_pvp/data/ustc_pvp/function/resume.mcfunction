execute if score #reset.active ustc.clock matches 1 run return run function ustc_pvp:reset/load_batch
execute unless score #preset ustc.clock matches 0..5 run scoreboard players set #preset ustc.clock 5
function ustc_pvp:apply_preset
