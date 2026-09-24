scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1856 0 -1488 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1488 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1472 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1472 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1440 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1440 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1408 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1408 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1488 -1841 55 -1473 to minecraft:overworld -1856 -16 -1488 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1488 -1841 127 -1473 to minecraft:overworld -1856 56 -1488 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1488 -1841 -1 -1473 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1488,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1472 -1841 55 -1457 to minecraft:overworld -1856 -16 -1472 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1472 -1841 127 -1457 to minecraft:overworld -1856 56 -1472 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1472 -1841 -1 -1457 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1472,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1456 -1841 55 -1441 to minecraft:overworld -1856 -16 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1456 -1841 127 -1441 to minecraft:overworld -1856 56 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1456 -1841 -1 -1441 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1456,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1440 -1841 55 -1425 to minecraft:overworld -1856 -16 -1440 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1440 -1841 127 -1425 to minecraft:overworld -1856 56 -1440 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1440 -1841 -1 -1425 minecraft:bedrock
function ustc_pvp:terrain/c_-1856_-1440
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1440,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1424 -1841 55 -1409 to minecraft:overworld -1856 -16 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1424 -1841 127 -1409 to minecraft:overworld -1856 56 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1424 -1841 -1 -1409 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1424,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1408 -1841 55 -1393 to minecraft:overworld -1856 -16 -1408 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1408 -1841 127 -1393 to minecraft:overworld -1856 56 -1408 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1408 -1841 -1 -1393 minecraft:bedrock
function ustc_pvp:terrain/c_-1856_-1408
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1408,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1392 -1841 55 -1377 to minecraft:overworld -1856 -16 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1392 -1841 127 -1377 to minecraft:overworld -1856 56 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1392 -1841 -1 -1377 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1392,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1376 -1841 55 -1361 to minecraft:overworld -1856 -16 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1376 -1841 127 -1361 to minecraft:overworld -1856 56 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1376 -1841 -1 -1361 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1376,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1856 -1488
execute in ustc_pvp:template run forceload remove -1856 -1488
execute in minecraft:overworld run forceload remove -1856 -1472
execute in ustc_pvp:template run forceload remove -1856 -1472
execute in minecraft:overworld run forceload remove -1856 -1456
execute in ustc_pvp:template run forceload remove -1856 -1456
execute in minecraft:overworld run forceload remove -1856 -1440
execute in ustc_pvp:template run forceload remove -1856 -1440
execute in minecraft:overworld run forceload remove -1856 -1424
execute in ustc_pvp:template run forceload remove -1856 -1424
execute in minecraft:overworld run forceload remove -1856 -1408
execute in ustc_pvp:template run forceload remove -1856 -1408
execute in minecraft:overworld run forceload remove -1856 -1392
execute in ustc_pvp:template run forceload remove -1856 -1392
execute in minecraft:overworld run forceload remove -1856 -1376
execute in ustc_pvp:template run forceload remove -1856 -1376
function ustc_pvp:reset/advance
