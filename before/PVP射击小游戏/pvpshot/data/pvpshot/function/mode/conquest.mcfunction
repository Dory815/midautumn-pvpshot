scoreboard players set #mode pvpshot.cfg 1
function pvpshot:match/restart
tellraw @a [{text:"已开启多点占领：占领后持续计分，击杀不加分。目标 "},{score:{name:"#cap.max",objective:"pvpshot.cfg"}},{text:" 分。"}]
