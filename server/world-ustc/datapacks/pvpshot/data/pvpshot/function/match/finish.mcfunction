scoreboard players set #match.state pvpshot.cal 2
scoreboard players operation #final.red pvpshot.cal = Red pvpshot.score
scoreboard players operation #final.blue pvpshot.cal = Blue pvpshot.score
tellraw @a [{text:"本局结束，最终比分 "},{score:{name:"Red",objective:"pvpshot.score"},color:"red"},{text:" : "},{score:{name:"Blue",objective:"pvpshot.score"},color:"blue"},{text:"。已停止计分，重置场地或由管理员开启下一局。"}]
