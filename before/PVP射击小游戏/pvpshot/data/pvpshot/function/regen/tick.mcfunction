execute unless score #regen.enabled pvpshot.cfg matches 1 run return run function pvpshot:regen/disable
execute as @a[gamemode=!creative,gamemode=!spectator,scores={pvpshot.live=1..}] at @s run function pvpshot:regen/player
execute as @a[gamemode=creative,scores={pvpshot.healing=1}] run function pvpshot:regen/stop
execute as @a[gamemode=spectator,scores={pvpshot.healing=1}] run function pvpshot:regen/stop
