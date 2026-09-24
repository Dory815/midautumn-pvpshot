function pvpshot:ammo/count
execute if score @s pvpshot.ammo matches 1.. run return run function pvpshot:ammo/reset
execute unless score @s pvpshot.reloading matches 1 run return run function pvpshot:ammo/start
scoreboard players remove @s pvpshot.reload 1
execute if score @s pvpshot.reload matches ..0 run function pvpshot:ammo/ready
