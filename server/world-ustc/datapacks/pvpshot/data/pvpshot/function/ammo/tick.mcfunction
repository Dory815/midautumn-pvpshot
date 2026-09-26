execute unless score #ammo.enabled pvpshot.cfg matches 1 run return 0
execute as @a[gamemode=!creative,gamemode=!spectator,nbt=!{Health:0.0f},scores={pvp_reload=1..}] at @s run function pvpshot:ammo/request
execute as @a[gamemode=!creative,gamemode=!spectator,nbt=!{Health:0.0f}] at @s run function pvpshot:ammo/player
scoreboard players enable @a pvp_reload
