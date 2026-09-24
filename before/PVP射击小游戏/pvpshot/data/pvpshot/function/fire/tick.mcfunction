kill @e[tag=pvpshot.fireball]
execute as @e[type=item_display,tag=pvpshot.shot] at @s rotated as @s run function pvpshot:shot/tick
