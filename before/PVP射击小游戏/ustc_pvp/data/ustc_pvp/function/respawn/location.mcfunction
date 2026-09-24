tag @e[tag=ustc.eligible] remove ustc.eligible
tag @e[tag=ustc.selected] remove ustc.selected
execute if entity @s[team=pvpshot.red] run function ustc_pvp:respawn/red
execute if entity @s[team=pvpshot.blue] run function ustc_pvp:respawn/blue
tag @e[type=marker,tag=ustc.eligible,sort=random,limit=1] add ustc.selected
execute at @e[tag=ustc.selected,limit=1] run tp @s ~ ~ ~
execute at @e[tag=ustc.selected,limit=1] run spawnpoint @s ~ ~ ~
tag @e[tag=ustc.eligible] remove ustc.eligible
tag @e[tag=ustc.selected] remove ustc.selected
