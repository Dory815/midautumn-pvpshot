# 与火焰弹同理，但用小火球（更轻量，适合做数量对比）
summon minecraft:small_fireball ~ ~1 ~ {Motion:[0.0,0.05,1.2]}
scoreboard players remove #bench.n bench 1
execute if score #bench.n bench matches 1.. run function bench:small_fireball_spawner
