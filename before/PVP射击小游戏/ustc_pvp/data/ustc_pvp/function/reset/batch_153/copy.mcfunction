scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1648 0 -1536 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1648 0 -1536 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1648 0 -1520 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1648 0 -1520 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1648 0 -1504 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1648 0 -1504 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1648 0 -1488 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1648 0 -1488 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1648 0 -1472 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1648 0 -1472 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1648 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1648 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1648 0 -1440 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1648 0 -1440 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1648 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1648 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 -16 -1536 -1633 55 -1521 to minecraft:overworld -1648 -16 -1536 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 56 -1536 -1633 127 -1521 to minecraft:overworld -1648 56 -1536 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1648 -1 -1536 -1633 -1 -1521 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1648,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1648,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1648,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1648,y=-16,z=-1536,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 -16 -1520 -1633 55 -1505 to minecraft:overworld -1648 -16 -1520 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 56 -1520 -1633 127 -1505 to minecraft:overworld -1648 56 -1520 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1648 -1 -1520 -1633 -1 -1505 minecraft:bedrock
function ustc_pvp:terrain/c_-1648_-1520
kill @e[type=#pvpshot:resettable,x=-1648,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1648,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1648,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1648,y=-16,z=-1520,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 -16 -1504 -1633 55 -1489 to minecraft:overworld -1648 -16 -1504 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 56 -1504 -1633 127 -1489 to minecraft:overworld -1648 56 -1504 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1648 -1 -1504 -1633 -1 -1489 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1648,y=-16,z=-1504,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1648,y=-16,z=-1504,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1648,y=-16,z=-1504,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1648,y=-16,z=-1504,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 -16 -1488 -1633 55 -1473 to minecraft:overworld -1648 -16 -1488 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 56 -1488 -1633 127 -1473 to minecraft:overworld -1648 56 -1488 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1648 -1 -1488 -1633 -1 -1473 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1648,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1648,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1648,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1648,y=-16,z=-1488,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 -16 -1472 -1633 55 -1457 to minecraft:overworld -1648 -16 -1472 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 56 -1472 -1633 127 -1457 to minecraft:overworld -1648 56 -1472 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1648 -1 -1472 -1633 -1 -1457 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1648,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1648,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1648,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1648,y=-16,z=-1472,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 -16 -1456 -1633 55 -1441 to minecraft:overworld -1648 -16 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 56 -1456 -1633 127 -1441 to minecraft:overworld -1648 56 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1648 -1 -1456 -1633 -1 -1441 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1648,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1648,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1648,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1648,y=-16,z=-1456,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 -16 -1440 -1633 55 -1425 to minecraft:overworld -1648 -16 -1440 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 56 -1440 -1633 127 -1425 to minecraft:overworld -1648 56 -1440 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1648 -1 -1440 -1633 -1 -1425 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1648,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1648,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1648,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1648,y=-16,z=-1440,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 -16 -1424 -1633 55 -1409 to minecraft:overworld -1648 -16 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1648 56 -1424 -1633 127 -1409 to minecraft:overworld -1648 56 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1648 -1 -1424 -1633 -1 -1409 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1648,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1648,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1648,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1648,y=-16,z=-1424,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1648 -1536
execute in ustc_pvp:template run forceload remove -1648 -1536
execute in minecraft:overworld run forceload remove -1648 -1520
execute in ustc_pvp:template run forceload remove -1648 -1520
execute in minecraft:overworld run forceload remove -1648 -1504
execute in ustc_pvp:template run forceload remove -1648 -1504
execute in minecraft:overworld run forceload remove -1648 -1488
execute in ustc_pvp:template run forceload remove -1648 -1488
execute in minecraft:overworld run forceload remove -1648 -1472
execute in ustc_pvp:template run forceload remove -1648 -1472
execute in minecraft:overworld run forceload remove -1648 -1456
execute in ustc_pvp:template run forceload remove -1648 -1456
execute in minecraft:overworld run forceload remove -1648 -1440
execute in ustc_pvp:template run forceload remove -1648 -1440
execute in minecraft:overworld run forceload remove -1648 -1424
execute in ustc_pvp:template run forceload remove -1648 -1424
function ustc_pvp:reset/advance
