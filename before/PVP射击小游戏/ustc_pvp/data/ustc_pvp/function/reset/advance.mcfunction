scoreboard players add #reset.index ustc.clock 1
execute store result bossbar ustc_pvp:points value run scoreboard players get #reset.index ustc.clock
bossbar set ustc_pvp:points name [{text:"恢复战场："},{score:{name:"#reset.index",objective:"ustc.clock"}},{text:" / 176 批"}]
execute if score #reset.index ustc.clock matches 176.. run return run function ustc_pvp:reset/finish
function ustc_pvp:reset/load_batch
