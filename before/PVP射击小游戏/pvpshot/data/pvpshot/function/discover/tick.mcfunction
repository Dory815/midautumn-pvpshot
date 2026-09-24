execute unless score #discover.enabled pvpshot.cfg matches 1 run return 0
scoreboard players add #disc pvpshot.cal 1
execute unless score #disc pvpshot.cal matches 20.. run return 0
scoreboard players set #disc pvpshot.cal 0
execute as @a at @s run function pvpshot:discover/around
