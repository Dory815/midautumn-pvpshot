execute if score #clock pvpshot.field_time >= @s pvpshot.field_end run return run kill @s
scoreboard players add @s pvpshot.age 1
execute if score @s pvpshot.age matches 10.. run function pvpshot:field/visual
function pvpshot:field/apply
