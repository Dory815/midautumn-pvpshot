$execute if entity @s[tag=pvpshot.damage_source] at @e[tag=pvpshot.fragment_origin,limit=1] run return run damage @s $(dmg) pvpshot:explosion at ~ ~ ~
$execute if entity @a[tag=pvpshot.damage_source,limit=1] run return run damage @s $(dmg) pvpshot:explosion by @e[tag=pvpshot.current_projectile,limit=1] from @a[tag=pvpshot.damage_source,limit=1]
$damage @s $(dmg) pvpshot:explosion by @e[tag=pvpshot.current_projectile,limit=1]
