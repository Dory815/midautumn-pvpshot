$execute if entity @a[tag=pvpshot.damage_source,limit=1] run return run damage @s $(dmg) pvpshot:rifle by @e[tag=pvpshot.current_projectile,limit=1] from @a[tag=pvpshot.damage_source,limit=1]
$damage @s $(dmg) pvpshot:rifle by @e[tag=pvpshot.current_projectile,limit=1]
