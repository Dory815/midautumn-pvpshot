scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -2000 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2000 0 -1376 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2000 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2000 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2000 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2000 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2000 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2000 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2000 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2000 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2000 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2000 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2000 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2000 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2000 0 -1264 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2000 0 -1264 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 -16 -1376 -1985 55 -1361 to minecraft:overworld -2000 -16 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 56 -1376 -1985 127 -1361 to minecraft:overworld -2000 56 -1376 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2000 -1 -1376 -1985 -1 -1361 minecraft:bedrock
function ustc_pvp:terrain/c_-2000_-1376
kill @e[type=#pvpshot:resettable,x=-2000,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2000,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2000,y=-16,z=-1376,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2000,y=-16,z=-1376,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 -16 -1360 -1985 55 -1345 to minecraft:overworld -2000 -16 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 56 -1360 -1985 127 -1345 to minecraft:overworld -2000 56 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2000 -1 -1360 -1985 -1 -1345 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2000,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2000,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2000,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2000,y=-16,z=-1360,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 -16 -1344 -1985 55 -1329 to minecraft:overworld -2000 -16 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 56 -1344 -1985 127 -1329 to minecraft:overworld -2000 56 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2000 -1 -1344 -1985 -1 -1329 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2000,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2000,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2000,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2000,y=-16,z=-1344,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 -16 -1328 -1985 55 -1313 to minecraft:overworld -2000 -16 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 56 -1328 -1985 127 -1313 to minecraft:overworld -2000 56 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2000 -1 -1328 -1985 -1 -1313 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2000,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2000,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2000,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2000,y=-16,z=-1328,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 -16 -1312 -1985 55 -1297 to minecraft:overworld -2000 -16 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 56 -1312 -1985 127 -1297 to minecraft:overworld -2000 56 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2000 -1 -1312 -1985 -1 -1297 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2000,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2000,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2000,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2000,y=-16,z=-1312,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 -16 -1296 -1985 55 -1281 to minecraft:overworld -2000 -16 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 56 -1296 -1985 127 -1281 to minecraft:overworld -2000 56 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2000 -1 -1296 -1985 -1 -1281 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2000,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2000,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2000,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2000,y=-16,z=-1296,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 -16 -1280 -1985 55 -1265 to minecraft:overworld -2000 -16 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 56 -1280 -1985 127 -1265 to minecraft:overworld -2000 56 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2000 -1 -1280 -1985 -1 -1265 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2000,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2000,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2000,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2000,y=-16,z=-1280,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 -16 -1264 -1985 55 -1249 to minecraft:overworld -2000 -16 -1264 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2000 56 -1264 -1985 127 -1249 to minecraft:overworld -2000 56 -1264 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2000 -1 -1264 -1985 -1 -1249 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2000,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2000,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2000,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2000,y=-16,z=-1264,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -2000 -1376
execute in ustc_pvp:template run forceload remove -2000 -1376
execute in minecraft:overworld run forceload remove -2000 -1360
execute in ustc_pvp:template run forceload remove -2000 -1360
execute in minecraft:overworld run forceload remove -2000 -1344
execute in ustc_pvp:template run forceload remove -2000 -1344
execute in minecraft:overworld run forceload remove -2000 -1328
execute in ustc_pvp:template run forceload remove -2000 -1328
execute in minecraft:overworld run forceload remove -2000 -1312
execute in ustc_pvp:template run forceload remove -2000 -1312
execute in minecraft:overworld run forceload remove -2000 -1296
execute in ustc_pvp:template run forceload remove -2000 -1296
execute in minecraft:overworld run forceload remove -2000 -1280
execute in ustc_pvp:template run forceload remove -2000 -1280
execute in minecraft:overworld run forceload remove -2000 -1264
execute in ustc_pvp:template run forceload remove -2000 -1264
function ustc_pvp:reset/advance
