scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1952 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1952 0 -1328 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1952 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1952 0 -1312 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1952 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1952 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1952 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1952 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1952 0 -1264 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1952 0 -1264 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1952 0 -1248 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1952 0 -1248 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1952 0 -1232 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1952 0 -1232 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1952 0 -1216 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1952 0 -1216 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 -16 -1328 -1937 55 -1313 to minecraft:overworld -1952 -16 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 56 -1328 -1937 127 -1313 to minecraft:overworld -1952 56 -1328 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1952 -1 -1328 -1937 -1 -1313 minecraft:bedrock
function ustc_pvp:terrain/c_-1952_-1328
kill @e[type=#pvpshot:resettable,x=-1952,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1952,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1952,y=-16,z=-1328,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1952,y=-16,z=-1328,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 -16 -1312 -1937 55 -1297 to minecraft:overworld -1952 -16 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 56 -1312 -1937 127 -1297 to minecraft:overworld -1952 56 -1312 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1952 -1 -1312 -1937 -1 -1297 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1952,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1952,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1952,y=-16,z=-1312,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1952,y=-16,z=-1312,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 -16 -1296 -1937 55 -1281 to minecraft:overworld -1952 -16 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 56 -1296 -1937 127 -1281 to minecraft:overworld -1952 56 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1952 -1 -1296 -1937 -1 -1281 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1952,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1952,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1952,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1952,y=-16,z=-1296,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 -16 -1280 -1937 55 -1265 to minecraft:overworld -1952 -16 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 56 -1280 -1937 127 -1265 to minecraft:overworld -1952 56 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1952 -1 -1280 -1937 -1 -1265 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1952,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1952,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1952,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1952,y=-16,z=-1280,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 -16 -1264 -1937 55 -1249 to minecraft:overworld -1952 -16 -1264 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 56 -1264 -1937 127 -1249 to minecraft:overworld -1952 56 -1264 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1952 -1 -1264 -1937 -1 -1249 minecraft:bedrock
function ustc_pvp:terrain/c_-1952_-1264
kill @e[type=#pvpshot:resettable,x=-1952,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1952,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1952,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1952,y=-16,z=-1264,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 -16 -1248 -1937 55 -1233 to minecraft:overworld -1952 -16 -1248 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 56 -1248 -1937 127 -1233 to minecraft:overworld -1952 56 -1248 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1952 -1 -1248 -1937 -1 -1233 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1952,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1952,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1952,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1952,y=-16,z=-1248,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 -16 -1232 -1937 55 -1217 to minecraft:overworld -1952 -16 -1232 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 56 -1232 -1937 127 -1217 to minecraft:overworld -1952 56 -1232 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1952 -1 -1232 -1937 -1 -1217 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1952,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1952,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1952,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1952,y=-16,z=-1232,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 -16 -1216 -1937 55 -1201 to minecraft:overworld -1952 -16 -1216 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1952 56 -1216 -1937 127 -1201 to minecraft:overworld -1952 56 -1216 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1952 -1 -1216 -1937 -1 -1201 minecraft:bedrock
function ustc_pvp:terrain/c_-1952_-1216
kill @e[type=#pvpshot:resettable,x=-1952,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1952,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1952,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1952,y=-16,z=-1216,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1952 -1328
execute in ustc_pvp:template run forceload remove -1952 -1328
execute in minecraft:overworld run forceload remove -1952 -1312
execute in ustc_pvp:template run forceload remove -1952 -1312
execute in minecraft:overworld run forceload remove -1952 -1296
execute in ustc_pvp:template run forceload remove -1952 -1296
execute in minecraft:overworld run forceload remove -1952 -1280
execute in ustc_pvp:template run forceload remove -1952 -1280
execute in minecraft:overworld run forceload remove -1952 -1264
execute in ustc_pvp:template run forceload remove -1952 -1264
execute in minecraft:overworld run forceload remove -1952 -1248
execute in ustc_pvp:template run forceload remove -1952 -1248
execute in minecraft:overworld run forceload remove -1952 -1232
execute in ustc_pvp:template run forceload remove -1952 -1232
execute in minecraft:overworld run forceload remove -1952 -1216
execute in ustc_pvp:template run forceload remove -1952 -1216
function ustc_pvp:reset/advance
