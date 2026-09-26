execute unless score @s pvpshot.quiet matches 0.. run function pvpshot:regen/in_combat
execute unless score @s pvpshot.quiet >= #regen.delay pvpshot.cfg run scoreboard players add @s pvpshot.quiet 1
execute store result score @s pvpshot.health run data get entity @s Health 100
execute if score @s pvpshot.health >= #regen.max pvpshot.cal run return run function pvpshot:regen/stop
execute if score @s pvpshot.quiet >= #regen.delay pvpshot.cfg unless score @s pvpshot.healing matches 1 run function pvpshot:regen/begin
execute if score @s pvpshot.healing matches 1 run scoreboard players add @s pvpshot.heal_age 1
execute if score @s pvpshot.healing matches 1 if score @s pvpshot.heal_age matches 60.. run function pvpshot:regen/begin
