# 雪球数量压测：与火焰弹对比，看不同投射物的开销差别
summon minecraft:snowball ~ ~1 ~ {Motion:[0.0,0.05,1.2]}
scoreboard players remove #bench.n bench 1
execute if score #bench.n bench matches 1.. run function bench:snowball_spawner
