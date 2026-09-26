$attribute @s minecraft:max_health base set $(hp)
effect give @s minecraft:instant_health 1 10 true
scoreboard players operation @s pvpshot.hp_set = #hp pvpshot.cfg
