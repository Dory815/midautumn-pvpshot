scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -2016 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2016 0 -1392 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2016 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2016 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2016 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2016 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2016 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2016 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2016 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2016 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2016 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2016 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2016 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2016 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2016 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2016 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 -16 -1392 -2001 55 -1377 to minecraft:overworld -2016 -16 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 56 -1392 -2001 127 -1377 to minecraft:overworld -2016 56 -1392 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2016 -1 -1392 -2001 -1 -1377 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2016,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2016,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2016,y=-16,z=-1392,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2016,y=-16,z=-1392,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 -16 -1376 -2001 55 -1361 to minecraft:overworld -2016 -16 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 56 -1376 -2001 127 -1361 to minecraft:overworld -2016 56 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2016 -1 -1376 -2001 -1 -1361 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2016,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2016,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2016,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2016,y=-16,z=-1376,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 -16 -1360 -2001 55 -1345 to minecraft:overworld -2016 -16 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 56 -1360 -2001 127 -1345 to minecraft:overworld -2016 56 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2016 -1 -1360 -2001 -1 -1345 minecraft:bedrock
function ustc_pvp:terrain/c_-2016_-1360
kill @e[type=#pvpshot:resettable,x=-2016,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2016,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2016,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2016,y=-16,z=-1360,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 -16 -1344 -2001 55 -1329 to minecraft:overworld -2016 -16 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 56 -1344 -2001 127 -1329 to minecraft:overworld -2016 56 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2016 -1 -1344 -2001 -1 -1329 minecraft:bedrock
function ustc_pvp:terrain/c_-2016_-1344
kill @e[type=#pvpshot:resettable,x=-2016,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2016,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2016,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2016,y=-16,z=-1344,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 -16 -1328 -2001 55 -1313 to minecraft:overworld -2016 -16 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 56 -1328 -2001 127 -1313 to minecraft:overworld -2016 56 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2016 -1 -1328 -2001 -1 -1313 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2016,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2016,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2016,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2016,y=-16,z=-1328,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 -16 -1312 -2001 55 -1297 to minecraft:overworld -2016 -16 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 56 -1312 -2001 127 -1297 to minecraft:overworld -2016 56 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2016 -1 -1312 -2001 -1 -1297 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2016,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2016,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2016,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2016,y=-16,z=-1312,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 -16 -1296 -2001 55 -1281 to minecraft:overworld -2016 -16 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 56 -1296 -2001 127 -1281 to minecraft:overworld -2016 56 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2016 -1 -1296 -2001 -1 -1281 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2016,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2016,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2016,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2016,y=-16,z=-1296,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 -16 -1280 -2001 55 -1265 to minecraft:overworld -2016 -16 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2016 56 -1280 -2001 127 -1265 to minecraft:overworld -2016 56 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2016 -1 -1280 -2001 -1 -1265 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2016,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2016,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2016,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2016,y=-16,z=-1280,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -2016 -1392
execute in ustc_pvp:template run forceload remove -2016 -1392
execute in minecraft:overworld run forceload remove -2016 -1376
execute in ustc_pvp:template run forceload remove -2016 -1376
execute in minecraft:overworld run forceload remove -2016 -1360
execute in ustc_pvp:template run forceload remove -2016 -1360
execute in minecraft:overworld run forceload remove -2016 -1344
execute in ustc_pvp:template run forceload remove -2016 -1344
execute in minecraft:overworld run forceload remove -2016 -1328
execute in ustc_pvp:template run forceload remove -2016 -1328
execute in minecraft:overworld run forceload remove -2016 -1312
execute in ustc_pvp:template run forceload remove -2016 -1312
execute in minecraft:overworld run forceload remove -2016 -1296
execute in ustc_pvp:template run forceload remove -2016 -1296
execute in minecraft:overworld run forceload remove -2016 -1280
execute in ustc_pvp:template run forceload remove -2016 -1280
function ustc_pvp:reset/advance
