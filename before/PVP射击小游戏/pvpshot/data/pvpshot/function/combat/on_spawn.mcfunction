execute on origin if entity @s[type=minecraft:player] run function pvpshot:regen/in_combat
# Cover the first movement segment before a point-blank native zero-damage hit.
execute at @s run function pvpshot:combat/sweep
