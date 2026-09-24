tag @e[tag=pvpshot.selected_spawn] remove pvpshot.selected_spawn
execute if entity @s[team=pvpshot.red] run tag @e[type=marker,tag=pvpshot.spawn.red,sort=random,limit=1] add pvpshot.selected_spawn
execute if entity @s[team=pvpshot.blue] run tag @e[type=marker,tag=pvpshot.spawn.blue,sort=random,limit=1] add pvpshot.selected_spawn
execute at @e[tag=pvpshot.selected_spawn,limit=1] run tp @s ~ ~ ~
execute at @e[tag=pvpshot.selected_spawn,limit=1] run spawnpoint @s ~ ~ ~
tag @e[tag=pvpshot.selected_spawn] remove pvpshot.selected_spawn
