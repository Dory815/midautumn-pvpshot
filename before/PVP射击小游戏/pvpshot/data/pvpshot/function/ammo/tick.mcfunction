execute unless score #ammo.enabled pvpshot.cfg matches 1 run return 0
execute as @a[gamemode=!creative,gamemode=!spectator,scores={pvpshot.live=1..,pvp_reload=1..}] at @s run function pvpshot:ammo/request
execute as @a[gamemode=!creative,gamemode=!spectator,scores={pvpshot.live=1..,pvpshot.reloading=1}] run function pvpshot:ammo/clock
scoreboard players add #ammo.scan pvpshot.cal 1
execute if score #ammo.scan pvpshot.cal matches 10.. as @a[gamemode=!creative,gamemode=!spectator,scores={pvpshot.live=1..}] run function pvpshot:ammo/scan
execute if score #ammo.scan pvpshot.cal matches 10.. run scoreboard players set #ammo.scan pvpshot.cal 0
scoreboard players enable @a pvp_reload
