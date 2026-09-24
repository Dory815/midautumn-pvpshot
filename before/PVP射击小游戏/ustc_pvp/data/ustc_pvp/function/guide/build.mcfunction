team add ustc.glow.white
team modify ustc.glow.white color white
team add ustc.glow.purple
team modify ustc.glow.purple color dark_purple
scoreboard players set #protection.edit ustc.clock 1
kill @e[type=block_display,tag=ustc.guide]
setblock -1990 28 -1535 minecraft:white_stained_glass
setblock -1857 2 -1541 minecraft:white_stained_glass
setblock -1710 29 -1535 minecraft:white_stained_glass
setblock -1676 2 -1660 minecraft:white_stained_glass
setblock -2080 2 -1378 minecraft:white_stained_glass
function ustc_pvp:guide/marker {x:-1989.5,y:32.0,z:-1534.5,team:"ustc.glow.white",block:"minecraft:white_stained_glass",tag:"point"}
function ustc_pvp:guide/marker {x:-1856.5,y:8.0,z:-1540.5,team:"ustc.glow.white",block:"minecraft:white_stained_glass",tag:"point"}
function ustc_pvp:guide/marker {x:-1709.5,y:33.0,z:-1534.5,team:"ustc.glow.white",block:"minecraft:white_stained_glass",tag:"point"}
function ustc_pvp:guide/marker {x:-1675.5,y:8.0,z:-1659.5,team:"ustc.glow.white",block:"minecraft:white_stained_glass",tag:"point"}
function ustc_pvp:guide/marker {x:-2079.5,y:8.0,z:-1377.5,team:"ustc.glow.white",block:"minecraft:white_stained_glass",tag:"point"}
function ustc_pvp:guide/marker {x:-1857.5,y:6.0,z:-1629.5,team:"ustc.glow.purple",block:"minecraft:purple_stained_glass",tag:"chest"}
function ustc_pvp:guide/marker {x:-1842.5,y:6.0,z:-1409.5,team:"ustc.glow.purple",block:"minecraft:purple_stained_glass",tag:"chest"}
scoreboard players set #protection.edit ustc.clock 0
