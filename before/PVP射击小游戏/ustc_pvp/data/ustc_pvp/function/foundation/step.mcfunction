execute if score #found.i ustc.clock >= #found.n ustc.clock run return run function ustc_pvp:foundation/done
scoreboard players operation #found.cx ustc.clock = #found.i ustc.clock
scoreboard players operation #found.cx ustc.clock %= #found.w ustc.clock
scoreboard players operation #found.cz ustc.clock = #found.i ustc.clock
scoreboard players operation #found.cz ustc.clock /= #found.w ustc.clock
scoreboard players operation #found.x ustc.clock = #found.cx ustc.clock
scoreboard players operation #found.x ustc.clock *= #found.16 ustc.clock
scoreboard players operation #found.x ustc.clock += #found.x0 ustc.clock
scoreboard players operation #found.z ustc.clock = #found.cz ustc.clock
scoreboard players operation #found.z ustc.clock *= #found.16 ustc.clock
scoreboard players operation #found.z ustc.clock += #found.z0 ustc.clock
scoreboard players operation #found.x2 ustc.clock = #found.x ustc.clock
scoreboard players add #found.x2 ustc.clock 15
scoreboard players operation #found.z2 ustc.clock = #found.z ustc.clock
scoreboard players add #found.z2 ustc.clock 15
execute store result storage ustc_pvp:found x int 1 run scoreboard players get #found.x ustc.clock
execute store result storage ustc_pvp:found z int 1 run scoreboard players get #found.z ustc.clock
execute store result storage ustc_pvp:found x2 int 1 run scoreboard players get #found.x2 ustc.clock
execute store result storage ustc_pvp:found z2 int 1 run scoreboard players get #found.z2 ustc.clock
function ustc_pvp:foundation/load with storage ustc_pvp:found
schedule function ustc_pvp:foundation/fill 1t replace
