scoreboard players add @s pvpshot.deaths 0
scoreboard players add @s pvpshot.kills 0
scoreboard players set @s pvpshot.init 1
scoreboard players operation @s pvpshot.deaths_old = @s pvpshot.deaths
scoreboard players operation @s pvpshot.kills_old = @s pvpshot.kills
execute if score #arena.auto pvpshot.cfg matches 1 unless entity @e[type=minecraft:marker,tag=pvpshot.arena] at @s run function pvpshot:setup/default_arena
function pvpshot:player/kit
