scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1856 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1360 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1344 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1264 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1264 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1856 0 -1248 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1856 0 -1248 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1360 -1841 55 -1345 to minecraft:overworld -1856 -16 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1360 -1841 127 -1345 to minecraft:overworld -1856 56 -1360 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1360 -1841 -1 -1345 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1360,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1360,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1344 -1841 55 -1329 to minecraft:overworld -1856 -16 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1344 -1841 127 -1329 to minecraft:overworld -1856 56 -1344 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1344 -1841 -1 -1329 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1344,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1344,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1328 -1841 55 -1313 to minecraft:overworld -1856 -16 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1328 -1841 127 -1313 to minecraft:overworld -1856 56 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1328 -1841 -1 -1313 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1328,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1312 -1841 55 -1297 to minecraft:overworld -1856 -16 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1312 -1841 127 -1297 to minecraft:overworld -1856 56 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1312 -1841 -1 -1297 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1312,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1296 -1841 55 -1281 to minecraft:overworld -1856 -16 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1296 -1841 127 -1281 to minecraft:overworld -1856 56 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1296 -1841 -1 -1281 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1296,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1280 -1841 55 -1265 to minecraft:overworld -1856 -16 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1280 -1841 127 -1265 to minecraft:overworld -1856 56 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1280 -1841 -1 -1265 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1280,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1264 -1841 55 -1249 to minecraft:overworld -1856 -16 -1264 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1264 -1841 127 -1249 to minecraft:overworld -1856 56 -1264 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1264 -1841 -1 -1249 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1264,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 -16 -1248 -1841 55 -1233 to minecraft:overworld -1856 -16 -1248 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1856 56 -1248 -1841 127 -1233 to minecraft:overworld -1856 56 -1248 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1856 -1 -1248 -1841 -1 -1233 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1856,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1856,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1856,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1856,y=-16,z=-1248,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1856 -1360
execute in ustc_pvp:template run forceload remove -1856 -1360
execute in minecraft:overworld run forceload remove -1856 -1344
execute in ustc_pvp:template run forceload remove -1856 -1344
execute in minecraft:overworld run forceload remove -1856 -1328
execute in ustc_pvp:template run forceload remove -1856 -1328
execute in minecraft:overworld run forceload remove -1856 -1312
execute in ustc_pvp:template run forceload remove -1856 -1312
execute in minecraft:overworld run forceload remove -1856 -1296
execute in ustc_pvp:template run forceload remove -1856 -1296
execute in minecraft:overworld run forceload remove -1856 -1280
execute in ustc_pvp:template run forceload remove -1856 -1280
execute in minecraft:overworld run forceload remove -1856 -1264
execute in ustc_pvp:template run forceload remove -1856 -1264
execute in minecraft:overworld run forceload remove -1856 -1248
execute in ustc_pvp:template run forceload remove -1856 -1248
function ustc_pvp:reset/advance
