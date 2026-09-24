function ustc_pvp:foundation/cell with storage ustc_pvp:found
function ustc_pvp:foundation/unload with storage ustc_pvp:found
scoreboard players add #found.i ustc.clock 1
execute if score #found.i ustc.clock matches 256 run tellraw @a {text:"基岩铺设 256/4096",color:"gray"}
execute if score #found.i ustc.clock matches 1024 run tellraw @a {text:"基岩铺设 1024/4096",color:"gray"}
execute if score #found.i ustc.clock matches 2048 run tellraw @a {text:"基岩铺设 2048/4096",color:"gray"}
execute if score #found.i ustc.clock matches 3072 run tellraw @a {text:"基岩铺设 3072/4096",color:"gray"}
function ustc_pvp:foundation/step
