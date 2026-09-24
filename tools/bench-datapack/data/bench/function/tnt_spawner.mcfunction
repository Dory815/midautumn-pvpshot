# TNT 压测：引信 60 tick（3 秒），到点集中爆炸，制造爆炸峰值
summon minecraft:tnt ~ ~2 ~ {fuse:60,Motion:[0.0,0.2,0.0]}
scoreboard players remove #bench.n bench 1
execute if score #bench.n bench matches 1.. run function bench:tnt_spawner
