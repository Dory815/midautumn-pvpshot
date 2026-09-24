# 清理压测产生的实体（含掉落物），避免影响下一轮
kill @e[type=minecraft:fireball]
kill @e[type=minecraft:small_fireball]
kill @e[type=minecraft:snowball]
kill @e[type=minecraft:tnt]
kill @e[type=minecraft:item]
kill @e[type=minecraft:area_effect_cloud]
scoreboard players set #bench.n bench 0
tellraw @a {"text":"[bench] 已清理压测实体","color":"gray"}
