scoreboard players set #v7.ready ustc.clock 1
execute unless loaded -1997 28 -1542 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -1983 28 -1528 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -1864 2 -1548 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -1850 2 -1534 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -1717 29 -1542 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -1703 29 -1528 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -1683 2 -1667 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -1669 2 -1653 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -2087 2 -1385 run scoreboard players set #v7.ready ustc.clock 0
execute unless loaded -2073 2 -1371 run scoreboard players set #v7.ready ustc.clock 0
execute if score #v7.ready ustc.clock matches 0 run return run schedule function ustc_pvp:v7/upgrade 20t replace
effect clear @a minecraft:jump_boost
function ustc_pvp:respawn/build
function ustc_pvp:advanced/build
data modify storage ustc_pvp:state balance_v7 set value 1b
