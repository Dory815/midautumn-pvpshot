scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -2080 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1440 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1440 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1424 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1408 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1408 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1456 -2065 55 -1441 to minecraft:overworld -2080 -16 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1456 -2065 127 -1441 to minecraft:overworld -2080 56 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1456 -2065 -1 -1441 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1456,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1440 -2065 55 -1425 to minecraft:overworld -2080 -16 -1440 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1440 -2065 127 -1425 to minecraft:overworld -2080 56 -1440 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1440 -2065 -1 -1425 minecraft:bedrock
function ustc_pvp:terrain/c_-2080_-1440
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1440,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1440,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1424 -2065 55 -1409 to minecraft:overworld -2080 -16 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1424 -2065 127 -1409 to minecraft:overworld -2080 56 -1424 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1424 -2065 -1 -1409 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1424,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1424,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1408 -2065 55 -1393 to minecraft:overworld -2080 -16 -1408 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1408 -2065 127 -1393 to minecraft:overworld -2080 56 -1408 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1408 -2065 -1 -1393 minecraft:bedrock
function ustc_pvp:terrain/c_-2080_-1408
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1408,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1408,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1392 -2065 55 -1377 to minecraft:overworld -2080 -16 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1392 -2065 127 -1377 to minecraft:overworld -2080 56 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1392 -2065 -1 -1377 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1392,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1376 -2065 55 -1361 to minecraft:overworld -2080 -16 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1376 -2065 127 -1361 to minecraft:overworld -2080 56 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1376 -2065 -1 -1361 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1376,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1360 -2065 55 -1345 to minecraft:overworld -2080 -16 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1360 -2065 127 -1345 to minecraft:overworld -2080 56 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1360 -2065 -1 -1345 minecraft:bedrock
function ustc_pvp:terrain/c_-2080_-1360
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1360,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1344 -2065 55 -1329 to minecraft:overworld -2080 -16 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1344 -2065 127 -1329 to minecraft:overworld -2080 56 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1344 -2065 -1 -1329 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1344,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -2080 -1456
execute in ustc_pvp:template run forceload remove -2080 -1456
execute in minecraft:overworld run forceload remove -2080 -1440
execute in ustc_pvp:template run forceload remove -2080 -1440
execute in minecraft:overworld run forceload remove -2080 -1424
execute in ustc_pvp:template run forceload remove -2080 -1424
execute in minecraft:overworld run forceload remove -2080 -1408
execute in ustc_pvp:template run forceload remove -2080 -1408
execute in minecraft:overworld run forceload remove -2080 -1392
execute in ustc_pvp:template run forceload remove -2080 -1392
execute in minecraft:overworld run forceload remove -2080 -1376
execute in ustc_pvp:template run forceload remove -2080 -1376
execute in minecraft:overworld run forceload remove -2080 -1360
execute in ustc_pvp:template run forceload remove -2080 -1360
execute in minecraft:overworld run forceload remove -2080 -1344
execute in ustc_pvp:template run forceload remove -2080 -1344
function ustc_pvp:reset/advance
