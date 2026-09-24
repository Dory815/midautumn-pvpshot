scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1696 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1696 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1696 0 -1440 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1696 0 -1440 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1696 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1696 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1696 0 -1408 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1696 0 -1408 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1696 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1696 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1696 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1696 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1696 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1696 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1696 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1696 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 -16 -1456 -1681 55 -1441 to minecraft:overworld -1696 -16 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 56 -1456 -1681 127 -1441 to minecraft:overworld -1696 56 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1696 -1 -1456 -1681 -1 -1441 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1696,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1696,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1696,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1696,y=-16,z=-1456,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 -16 -1440 -1681 55 -1425 to minecraft:overworld -1696 -16 -1440 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 56 -1440 -1681 127 -1425 to minecraft:overworld -1696 56 -1440 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1696 -1 -1440 -1681 -1 -1425 minecraft:bedrock
function ustc_pvp:terrain/c_-1696_-1440
kill @e[type=#pvpshot:resettable,x=-1696,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1696,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1696,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1696,y=-16,z=-1440,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 -16 -1424 -1681 55 -1409 to minecraft:overworld -1696 -16 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 56 -1424 -1681 127 -1409 to minecraft:overworld -1696 56 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1696 -1 -1424 -1681 -1 -1409 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1696,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1696,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1696,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1696,y=-16,z=-1424,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 -16 -1408 -1681 55 -1393 to minecraft:overworld -1696 -16 -1408 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 56 -1408 -1681 127 -1393 to minecraft:overworld -1696 56 -1408 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1696 -1 -1408 -1681 -1 -1393 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1696,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1696,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1696,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1696,y=-16,z=-1408,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 -16 -1392 -1681 55 -1377 to minecraft:overworld -1696 -16 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 56 -1392 -1681 127 -1377 to minecraft:overworld -1696 56 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1696 -1 -1392 -1681 -1 -1377 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1696,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1696,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1696,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1696,y=-16,z=-1392,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 -16 -1376 -1681 55 -1361 to minecraft:overworld -1696 -16 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 56 -1376 -1681 127 -1361 to minecraft:overworld -1696 56 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1696 -1 -1376 -1681 -1 -1361 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1696,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1696,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1696,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1696,y=-16,z=-1376,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 -16 -1360 -1681 55 -1345 to minecraft:overworld -1696 -16 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 56 -1360 -1681 127 -1345 to minecraft:overworld -1696 56 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1696 -1 -1360 -1681 -1 -1345 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1696,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1696,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1696,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1696,y=-16,z=-1360,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 -16 -1344 -1681 55 -1329 to minecraft:overworld -1696 -16 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1696 56 -1344 -1681 127 -1329 to minecraft:overworld -1696 56 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1696 -1 -1344 -1681 -1 -1329 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1696,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1696,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1696,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1696,y=-16,z=-1344,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1696 -1456
execute in ustc_pvp:template run forceload remove -1696 -1456
execute in minecraft:overworld run forceload remove -1696 -1440
execute in ustc_pvp:template run forceload remove -1696 -1440
execute in minecraft:overworld run forceload remove -1696 -1424
execute in ustc_pvp:template run forceload remove -1696 -1424
execute in minecraft:overworld run forceload remove -1696 -1408
execute in ustc_pvp:template run forceload remove -1696 -1408
execute in minecraft:overworld run forceload remove -1696 -1392
execute in ustc_pvp:template run forceload remove -1696 -1392
execute in minecraft:overworld run forceload remove -1696 -1376
execute in ustc_pvp:template run forceload remove -1696 -1376
execute in minecraft:overworld run forceload remove -1696 -1360
execute in ustc_pvp:template run forceload remove -1696 -1360
execute in minecraft:overworld run forceload remove -1696 -1344
execute in ustc_pvp:template run forceload remove -1696 -1344
function ustc_pvp:reset/advance
