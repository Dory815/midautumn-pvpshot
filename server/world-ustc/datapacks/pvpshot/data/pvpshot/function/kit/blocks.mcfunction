execute if entity @s[team=pvpshot.red] run give @s minecraft:red_terracotta 64
execute if entity @s[team=pvpshot.blue] run give @s minecraft:blue_terracotta 64
execute unless entity @s[team=pvpshot.red] unless entity @s[team=pvpshot.blue] run give @s minecraft:terracotta 64
