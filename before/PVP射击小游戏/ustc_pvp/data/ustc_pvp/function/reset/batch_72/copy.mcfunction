scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1920 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1920 0 -1296 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1920 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1920 0 -1280 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1920 0 -1264 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1920 0 -1264 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1920 0 -1248 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1920 0 -1248 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1920 0 -1232 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1920 0 -1232 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1920 0 -1216 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1920 0 -1216 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1920 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1920 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1920 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1920 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 -16 -1296 -1905 55 -1281 to minecraft:overworld -1920 -16 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 56 -1296 -1905 127 -1281 to minecraft:overworld -1920 56 -1296 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1920 -1 -1296 -1905 -1 -1281 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1920,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1920,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1920,y=-16,z=-1296,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1920,y=-16,z=-1296,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 -16 -1280 -1905 55 -1265 to minecraft:overworld -1920 -16 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 56 -1280 -1905 127 -1265 to minecraft:overworld -1920 56 -1280 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1920 -1 -1280 -1905 -1 -1265 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1920,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1920,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1920,y=-16,z=-1280,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1920,y=-16,z=-1280,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 -16 -1264 -1905 55 -1249 to minecraft:overworld -1920 -16 -1264 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 56 -1264 -1905 127 -1249 to minecraft:overworld -1920 56 -1264 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1920 -1 -1264 -1905 -1 -1249 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1920,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1920,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1920,y=-16,z=-1264,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1920,y=-16,z=-1264,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 -16 -1248 -1905 55 -1233 to minecraft:overworld -1920 -16 -1248 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 56 -1248 -1905 127 -1233 to minecraft:overworld -1920 56 -1248 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1920 -1 -1248 -1905 -1 -1233 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1920,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1920,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1920,y=-16,z=-1248,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1920,y=-16,z=-1248,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 -16 -1232 -1905 55 -1217 to minecraft:overworld -1920 -16 -1232 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 56 -1232 -1905 127 -1217 to minecraft:overworld -1920 56 -1232 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1920 -1 -1232 -1905 -1 -1217 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1920,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1920,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1920,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1920,y=-16,z=-1232,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 -16 -1216 -1905 55 -1201 to minecraft:overworld -1920 -16 -1216 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 56 -1216 -1905 127 -1201 to minecraft:overworld -1920 56 -1216 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1920 -1 -1216 -1905 -1 -1201 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1920,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1920,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1920,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1920,y=-16,z=-1216,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 -16 -1200 -1905 55 -1185 to minecraft:overworld -1920 -16 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 56 -1200 -1905 127 -1185 to minecraft:overworld -1920 56 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1920 -1 -1200 -1905 -1 -1185 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1920,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1920,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1920,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1920,y=-16,z=-1200,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 -16 -1184 -1905 55 -1169 to minecraft:overworld -1920 -16 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1920 56 -1184 -1905 127 -1169 to minecraft:overworld -1920 56 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1920 -1 -1184 -1905 -1 -1169 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1920,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1920,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1920,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1920,y=-16,z=-1184,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1920 -1296
execute in ustc_pvp:template run forceload remove -1920 -1296
execute in minecraft:overworld run forceload remove -1920 -1280
execute in ustc_pvp:template run forceload remove -1920 -1280
execute in minecraft:overworld run forceload remove -1920 -1264
execute in ustc_pvp:template run forceload remove -1920 -1264
execute in minecraft:overworld run forceload remove -1920 -1248
execute in ustc_pvp:template run forceload remove -1920 -1248
execute in minecraft:overworld run forceload remove -1920 -1232
execute in ustc_pvp:template run forceload remove -1920 -1232
execute in minecraft:overworld run forceload remove -1920 -1216
execute in ustc_pvp:template run forceload remove -1920 -1216
execute in minecraft:overworld run forceload remove -1920 -1200
execute in ustc_pvp:template run forceload remove -1920 -1200
execute in minecraft:overworld run forceload remove -1920 -1184
execute in ustc_pvp:template run forceload remove -1920 -1184
function ustc_pvp:reset/advance
