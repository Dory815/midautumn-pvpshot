scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1792 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1792 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1792 0 -1408 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1792 0 -1408 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1792 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1792 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1792 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1792 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1792 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1792 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1792 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1792 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1792 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1792 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1792 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1792 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 -16 -1424 -1777 55 -1409 to minecraft:overworld -1792 -16 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 56 -1424 -1777 127 -1409 to minecraft:overworld -1792 56 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1792 -1 -1424 -1777 -1 -1409 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1792,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1792,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1792,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1792,y=-16,z=-1424,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 -16 -1408 -1777 55 -1393 to minecraft:overworld -1792 -16 -1408 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 56 -1408 -1777 127 -1393 to minecraft:overworld -1792 56 -1408 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1792 -1 -1408 -1777 -1 -1393 minecraft:bedrock
function ustc_pvp:terrain/c_-1792_-1408
kill @e[type=#pvpshot:resettable,x=-1792,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1792,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1792,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1792,y=-16,z=-1408,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 -16 -1392 -1777 55 -1377 to minecraft:overworld -1792 -16 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 56 -1392 -1777 127 -1377 to minecraft:overworld -1792 56 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1792 -1 -1392 -1777 -1 -1377 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1792,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1792,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1792,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1792,y=-16,z=-1392,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 -16 -1376 -1777 55 -1361 to minecraft:overworld -1792 -16 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 56 -1376 -1777 127 -1361 to minecraft:overworld -1792 56 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1792 -1 -1376 -1777 -1 -1361 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1792,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1792,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1792,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1792,y=-16,z=-1376,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 -16 -1360 -1777 55 -1345 to minecraft:overworld -1792 -16 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 56 -1360 -1777 127 -1345 to minecraft:overworld -1792 56 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1792 -1 -1360 -1777 -1 -1345 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1792,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1792,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1792,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1792,y=-16,z=-1360,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 -16 -1344 -1777 55 -1329 to minecraft:overworld -1792 -16 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 56 -1344 -1777 127 -1329 to minecraft:overworld -1792 56 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1792 -1 -1344 -1777 -1 -1329 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1792,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1792,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1792,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1792,y=-16,z=-1344,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 -16 -1328 -1777 55 -1313 to minecraft:overworld -1792 -16 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 56 -1328 -1777 127 -1313 to minecraft:overworld -1792 56 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1792 -1 -1328 -1777 -1 -1313 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1792,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1792,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1792,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1792,y=-16,z=-1328,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 -16 -1312 -1777 55 -1297 to minecraft:overworld -1792 -16 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1792 56 -1312 -1777 127 -1297 to minecraft:overworld -1792 56 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1792 -1 -1312 -1777 -1 -1297 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1792,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1792,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1792,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1792,y=-16,z=-1312,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1792 -1424
execute in ustc_pvp:template run forceload remove -1792 -1424
execute in minecraft:overworld run forceload remove -1792 -1408
execute in ustc_pvp:template run forceload remove -1792 -1408
execute in minecraft:overworld run forceload remove -1792 -1392
execute in ustc_pvp:template run forceload remove -1792 -1392
execute in minecraft:overworld run forceload remove -1792 -1376
execute in ustc_pvp:template run forceload remove -1792 -1376
execute in minecraft:overworld run forceload remove -1792 -1360
execute in ustc_pvp:template run forceload remove -1792 -1360
execute in minecraft:overworld run forceload remove -1792 -1344
execute in ustc_pvp:template run forceload remove -1792 -1344
execute in minecraft:overworld run forceload remove -1792 -1328
execute in ustc_pvp:template run forceload remove -1792 -1328
execute in minecraft:overworld run forceload remove -1792 -1312
execute in ustc_pvp:template run forceload remove -1792 -1312
function ustc_pvp:reset/advance
