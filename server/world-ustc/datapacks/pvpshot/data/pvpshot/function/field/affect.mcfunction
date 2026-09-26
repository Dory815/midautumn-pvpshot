effect give @s minecraft:slowness 1 3 true
execute if score @s pvpshot.field_next > #clock pvpshot.field_time run return 0
scoreboard players operation @s pvpshot.field_next = #clock pvpshot.field_time
scoreboard players add @s pvpshot.field_next 20
execute if entity @a[tag=pvpshot.field_owner,limit=1] run return run damage @s 2 pvpshot:field by @e[tag=pvpshot.field_current,limit=1] from @a[tag=pvpshot.field_owner,limit=1]
damage @s 2 pvpshot:field by @e[tag=pvpshot.field_current,limit=1]
