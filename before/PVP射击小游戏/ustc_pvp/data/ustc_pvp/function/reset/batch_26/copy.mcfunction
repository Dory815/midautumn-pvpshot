scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -2064 0 -1568 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1568 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1552 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1552 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1536 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1536 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1520 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1520 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1504 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1504 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1488 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1488 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1472 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1472 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1456 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1568 -2049 55 -1553 to minecraft:overworld -2064 -16 -1568 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1568 -2049 127 -1553 to minecraft:overworld -2064 56 -1568 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1568 -2049 -1 -1553 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1568,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1552 -2049 55 -1537 to minecraft:overworld -2064 -16 -1552 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1552 -2049 127 -1537 to minecraft:overworld -2064 56 -1552 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1552 -2049 -1 -1537 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1552,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1536 -2049 55 -1521 to minecraft:overworld -2064 -16 -1536 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1536 -2049 127 -1521 to minecraft:overworld -2064 56 -1536 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1536 -2049 -1 -1521 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1536,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1520 -2049 55 -1505 to minecraft:overworld -2064 -16 -1520 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1520 -2049 127 -1505 to minecraft:overworld -2064 56 -1520 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1520 -2049 -1 -1505 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1520,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1504 -2049 55 -1489 to minecraft:overworld -2064 -16 -1504 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1504 -2049 127 -1489 to minecraft:overworld -2064 56 -1504 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1504 -2049 -1 -1489 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1504,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1504,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1504,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1504,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1488 -2049 55 -1473 to minecraft:overworld -2064 -16 -1488 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1488 -2049 127 -1473 to minecraft:overworld -2064 56 -1488 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1488 -2049 -1 -1473 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1488,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1488,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1472 -2049 55 -1457 to minecraft:overworld -2064 -16 -1472 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1472 -2049 127 -1457 to minecraft:overworld -2064 56 -1472 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1472 -2049 -1 -1457 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1472,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1472,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1456 -2049 55 -1441 to minecraft:overworld -2064 -16 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1456 -2049 127 -1441 to minecraft:overworld -2064 56 -1456 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1456 -2049 -1 -1441 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1456,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1456,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -2064 -1568
execute in ustc_pvp:template run forceload remove -2064 -1568
execute in minecraft:overworld run forceload remove -2064 -1552
execute in ustc_pvp:template run forceload remove -2064 -1552
execute in minecraft:overworld run forceload remove -2064 -1536
execute in ustc_pvp:template run forceload remove -2064 -1536
execute in minecraft:overworld run forceload remove -2064 -1520
execute in ustc_pvp:template run forceload remove -2064 -1520
execute in minecraft:overworld run forceload remove -2064 -1504
execute in ustc_pvp:template run forceload remove -2064 -1504
execute in minecraft:overworld run forceload remove -2064 -1488
execute in ustc_pvp:template run forceload remove -2064 -1488
execute in minecraft:overworld run forceload remove -2064 -1472
execute in ustc_pvp:template run forceload remove -2064 -1472
execute in minecraft:overworld run forceload remove -2064 -1456
execute in ustc_pvp:template run forceload remove -2064 -1456
function ustc_pvp:reset/advance
