execute if score #hit pvpshot.cal matches 1 run return 0
execute if entity @e[type=snowball,tag=pvpshot.current_projectile] run return run function pvpshot:combat/impact
scoreboard players set #hit pvpshot.cal 1
scoreboard players set #damage.ok pvpshot.cal 0
execute if entity @s[tag=pvpshot.damage_source] store result score #damage.ok pvpshot.cal run function pvpshot:combat/self_damage with storage pvpshot:tmp
execute unless entity @s[tag=pvpshot.damage_source] if entity @a[tag=pvpshot.damage_source,limit=1] store result score #damage.ok pvpshot.cal run function pvpshot:combat/do_damage with storage pvpshot:tmp
execute unless entity @a[tag=pvpshot.damage_source,limit=1] store result score #damage.ok pvpshot.cal run function pvpshot:combat/unowned_damage with storage pvpshot:tmp
tag @s add pvpshot.direct_hit
function pvpshot:combat/impact
tag @s remove pvpshot.direct_hit
