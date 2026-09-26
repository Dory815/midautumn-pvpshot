execute unless score #regen.enabled pvpshot.cfg matches 1 run return run function pvpshot:regen/disable
scoreboard players operation #regen.max pvpshot.cal = #hp pvpshot.cfg
scoreboard players operation #regen.max pvpshot.cal *= #hundred pvpshot.cal
execute as @a[gamemode=!creative,gamemode=!spectator,nbt=!{Health:0.0f}] at @s run function pvpshot:regen/player
execute as @a[gamemode=creative,scores={pvpshot.healing=1}] run function pvpshot:regen/stop
execute as @a[gamemode=spectator,scores={pvpshot.healing=1}] run function pvpshot:regen/stop
