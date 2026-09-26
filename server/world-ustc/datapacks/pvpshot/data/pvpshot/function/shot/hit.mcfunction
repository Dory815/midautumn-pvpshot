execute if score #hit pvpshot.cal matches 1 run return 0
scoreboard players set #hit pvpshot.cal 1
execute if score #rocket pvpshot.cal matches 1 run return run function pvpshot:rocket/burst
execute if entity @e[tag=pvpshot.current_projectile,tag=pvpshot.smg_shot,limit=1] run return run function pvpshot:shot/damage with storage pvpshot:shot
tag @s add pvpshot.rifle_direct
function pvpshot:shot/damage with storage pvpshot:shot
function pvpshot:rifle/burst
tag @s remove pvpshot.rifle_direct
