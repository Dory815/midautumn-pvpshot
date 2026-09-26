execute if score #reset.active ustc.clock matches 1 run return 0
scoreboard players set #preset ustc.clock 5
function ustc_pvp:apply_preset
tellraw @a {text:"已切换模式并开启新局。恢复地形请使用重置战场。",color:"gold"}
