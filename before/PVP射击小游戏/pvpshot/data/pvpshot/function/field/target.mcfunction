execute unless score #friendlyfire pvpshot.cfg matches 1 if entity @s[team=pvpshot.red] if entity @a[tag=pvpshot.field_owner,team=pvpshot.red] run return 0
execute unless score #friendlyfire pvpshot.cfg matches 1 if entity @s[team=pvpshot.blue] if entity @a[tag=pvpshot.field_owner,team=pvpshot.blue] run return 0
scoreboard players set #field.ray pvpshot.cal 24
execute if predicate pvpshot:low_pose positioned ~ ~0.3 ~ facing entity @e[tag=pvpshot.field_current,limit=1] feet run return run function pvpshot:field/ray
execute if predicate pvpshot:crouching positioned ~ ~0.75 ~ facing entity @e[tag=pvpshot.field_current,limit=1] feet run return run function pvpshot:field/ray
execute positioned ~ ~0.9 ~ facing entity @e[tag=pvpshot.field_current,limit=1] feet run function pvpshot:field/ray
