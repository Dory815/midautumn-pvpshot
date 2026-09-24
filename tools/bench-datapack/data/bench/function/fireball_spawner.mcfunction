# 内部单元：每次召唤一个火焰弹并递归，直到 #bench.n 归零。
# 由 bench:fireball_* 入口调用；位置与朝向继承调用者（用 /execute at @s run ... 触发）。
summon minecraft:fireball ~ ~1 ~ {Motion:[0.0,0.05,1.2]}
scoreboard players remove #bench.n bench 1
execute if score #bench.n bench matches 1.. run function bench:fireball_spawner
