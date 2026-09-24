execute unless score #mode pvpshot.cfg matches 0..1 run scoreboard players set #mode pvpshot.cfg 1
execute unless score #match.mode pvpshot.cal = #mode pvpshot.cfg run function pvpshot:match/restart
