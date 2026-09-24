tag @s add pvpshot.field_current
scoreboard players operation #field.owner pvpshot.shooter = @s pvpshot.shooter
execute as @a if score @s pvpshot.shooter = #field.owner pvpshot.shooter run tag @s add pvpshot.field_owner
execute as @a[gamemode=!creative,gamemode=!spectator,nbt=!{Health:0.0f},distance=..4] if predicate pvpshot:in_field at @s run function pvpshot:field/target
tag @a[tag=pvpshot.field_owner] remove pvpshot.field_owner
tag @s remove pvpshot.field_current
