execute as @a unless score @s pvpshot.init matches 1 run function pvpshot:player/init
execute as @a unless score @s pvpshot.hp_set = #hp pvpshot.cfg run function pvpshot:player/refresh_hp
execute as @a unless score @s pvpshot.ff_init matches 1 run function pvpshot:player/score_init
execute as @a unless score @s pvpshot.deaths = @s pvpshot.deaths_old run scoreboard players set @s pvpshot.respawn 1
execute as @a run scoreboard players operation @s pvpshot.deaths_old = @s pvpshot.deaths
execute as @a[scores={pvpshot.respawn=1},nbt=!{Health:0.0f}] at @s run function pvpshot:player/respawn
execute as @a unless score @s pvpshot.kills = @s pvpshot.kills_old run function pvpshot:player/on_kill
execute as @a run scoreboard players operation @s pvpshot.kills_old = @s pvpshot.kills
execute as @a run scoreboard players operation @s pvpshot.kr_old = @s pvpshot.kill_red
execute as @a run scoreboard players operation @s pvpshot.kb_old = @s pvpshot.kill_blue
# Restore food and saturation every game tick; natural healing stays disabled.
execute as @a[nbt=!{Health:0.0f}] run function pvpshot:player/feed
