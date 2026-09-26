execute unless score #mode pvpshot.cfg matches 0 run return 0
execute unless score #match.state pvpshot.cal matches 1 run return 0
scoreboard players set #enemy.kills pvpshot.cal 0
execute if entity @s[team=pvpshot.red] run scoreboard players operation #enemy.kills pvpshot.cal = @s pvpshot.kill_blue
execute if entity @s[team=pvpshot.red] run scoreboard players operation #enemy.kills pvpshot.cal -= @s pvpshot.kb_old
execute if entity @s[team=pvpshot.red] if score #enemy.kills pvpshot.cal matches 1.. run scoreboard players operation Red pvpshot.score += #enemy.kills pvpshot.cal
execute if entity @s[team=pvpshot.blue] run scoreboard players operation #enemy.kills pvpshot.cal = @s pvpshot.kill_red
execute if entity @s[team=pvpshot.blue] run scoreboard players operation #enemy.kills pvpshot.cal -= @s pvpshot.kr_old
execute if entity @s[team=pvpshot.blue] if score #enemy.kills pvpshot.cal matches 1.. run scoreboard players operation Blue pvpshot.score += #enemy.kills pvpshot.cal
