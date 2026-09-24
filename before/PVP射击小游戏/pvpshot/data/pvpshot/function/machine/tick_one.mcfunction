scoreboard players add @s pvpshot.age 1
execute if entity @s[tag=pvpshot.cannon] run function pvpshot:cannon/tick
execute if entity @s[tag=pvpshot.turret] run function pvpshot:turret/tick
