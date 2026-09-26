execute unless score #match.state pvpshot.cal matches 1 run return 0
execute if score #mode pvpshot.cfg matches 0 run scoreboard players operation #match.limit pvpshot.cal = #tdm.max pvpshot.cfg
execute if score #mode pvpshot.cfg matches 1 run scoreboard players operation #match.limit pvpshot.cal = #cap.max pvpshot.cfg
execute unless score #match.limit pvpshot.cal matches 1.. run scoreboard players set #match.limit pvpshot.cal 60
execute unless score Red pvpshot.score >= #match.limit pvpshot.cal unless score Blue pvpshot.score >= #match.limit pvpshot.cal run return 0
execute if score Red pvpshot.score > Blue pvpshot.score run return run function pvpshot:point/win_red
execute if score Blue pvpshot.score > Red pvpshot.score run return run function pvpshot:point/win_blue
function pvpshot:match/draw
