execute unless data storage ustc_pvp:state {prepared:1b} run return 0
execute as @a unless score @s ustc.init matches 1 run function ustc_pvp:welcome
execute as @a[scores={ustc.join=1}] run function ustc_pvp:join_red
execute as @a[scores={ustc.join=2..}] run function ustc_pvp:join_blue
execute as @a[scores={pvpshot.live=1..}] unless score @s ustc.deaths = @s pvpshot.deaths run function ustc_pvp:mobility/apply
execute as @a[scores={pvpshot.live=1..}] run scoreboard players operation @s ustc.deaths = @s pvpshot.deaths
execute as @a[scores={pvp_lobby=1..}] run function ustc_pvp:lobby
execute as @a[scores={pvp_kit=1..}] run function ustc_pvp:kit
execute as @a[scores={pvp_reset=1..}] run function ustc_pvp:reset/request
execute as @a[scores={ustc.mode=3}] run function ustc_pvp:control/three
execute as @a[scores={ustc.mode=5}] run function ustc_pvp:control/five
execute as @a[scores={ustc.mode=1}] run function ustc_pvp:control/deathmatch
scoreboard players set @a[scores={ustc.mode=1..}] ustc.mode 0
scoreboard players enable @a ustc.join
scoreboard players enable @a ustc.mode
scoreboard players enable @a pvp_reset
scoreboard players enable @a pvp_kit
scoreboard players enable @a pvp_lobby
scoreboard players add #tick ustc.clock 1
execute if score #tick ustc.clock matches 20.. run function ustc_pvp:second
execute if score #reset.active ustc.clock matches 1 as @a[gamemode=survival] run function ustc_pvp:lobby
