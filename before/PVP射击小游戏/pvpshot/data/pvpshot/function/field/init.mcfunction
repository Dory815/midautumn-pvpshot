tag @s add pvpshot.field
scoreboard players operation @s pvpshot.shooter = #field.owner pvpshot.shooter
scoreboard players operation @s pvpshot.field_end = #clock pvpshot.field_time
scoreboard players add @s pvpshot.field_end 100
scoreboard players set @s pvpshot.age 0
function pvpshot:field/visual
function pvpshot:field/apply
