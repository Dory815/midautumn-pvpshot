scoreboard players set #mode pvpshot.cfg 0
function pvpshot:match/restart
tellraw @a [{text:"已开启团队死斗：击杀敌队加 1 分，据点不计分。目标 "},{score:{name:"#tdm.max",objective:"pvpshot.cfg"}},{text:" 分。"}]
