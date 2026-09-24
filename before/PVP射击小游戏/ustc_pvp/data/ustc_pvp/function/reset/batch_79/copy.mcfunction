scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1888 0 -1648 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1888 0 -1648 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1888 0 -1632 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1888 0 -1632 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1888 0 -1616 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1888 0 -1616 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1888 0 -1600 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1888 0 -1600 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1888 0 -1584 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1888 0 -1584 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1888 0 -1568 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1888 0 -1568 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1888 0 -1552 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1888 0 -1552 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1888 0 -1536 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1888 0 -1536 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 -16 -1648 -1873 55 -1633 to minecraft:overworld -1888 -16 -1648 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 56 -1648 -1873 127 -1633 to minecraft:overworld -1888 56 -1648 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1888 -1 -1648 -1873 -1 -1633 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1888,y=-16,z=-1648,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1888,y=-16,z=-1648,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1888,y=-16,z=-1648,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1888,y=-16,z=-1648,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 -16 -1632 -1873 55 -1617 to minecraft:overworld -1888 -16 -1632 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 56 -1632 -1873 127 -1617 to minecraft:overworld -1888 56 -1632 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1888 -1 -1632 -1873 -1 -1617 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1888,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1888,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1888,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1888,y=-16,z=-1632,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 -16 -1616 -1873 55 -1601 to minecraft:overworld -1888 -16 -1616 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 56 -1616 -1873 127 -1601 to minecraft:overworld -1888 56 -1616 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1888 -1 -1616 -1873 -1 -1601 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1888,y=-16,z=-1616,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1888,y=-16,z=-1616,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1888,y=-16,z=-1616,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1888,y=-16,z=-1616,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 -16 -1600 -1873 55 -1585 to minecraft:overworld -1888 -16 -1600 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 56 -1600 -1873 127 -1585 to minecraft:overworld -1888 56 -1600 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1888 -1 -1600 -1873 -1 -1585 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1888,y=-16,z=-1600,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1888,y=-16,z=-1600,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1888,y=-16,z=-1600,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1888,y=-16,z=-1600,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 -16 -1584 -1873 55 -1569 to minecraft:overworld -1888 -16 -1584 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 56 -1584 -1873 127 -1569 to minecraft:overworld -1888 56 -1584 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1888 -1 -1584 -1873 -1 -1569 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1888,y=-16,z=-1584,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1888,y=-16,z=-1584,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1888,y=-16,z=-1584,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1888,y=-16,z=-1584,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 -16 -1568 -1873 55 -1553 to minecraft:overworld -1888 -16 -1568 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 56 -1568 -1873 127 -1553 to minecraft:overworld -1888 56 -1568 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1888 -1 -1568 -1873 -1 -1553 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1888,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1888,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1888,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1888,y=-16,z=-1568,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 -16 -1552 -1873 55 -1537 to minecraft:overworld -1888 -16 -1552 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 56 -1552 -1873 127 -1537 to minecraft:overworld -1888 56 -1552 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1888 -1 -1552 -1873 -1 -1537 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1888,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1888,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1888,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1888,y=-16,z=-1552,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 -16 -1536 -1873 55 -1521 to minecraft:overworld -1888 -16 -1536 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1888 56 -1536 -1873 127 -1521 to minecraft:overworld -1888 56 -1536 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1888 -1 -1536 -1873 -1 -1521 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1888,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1888,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1888,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1888,y=-16,z=-1536,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1888 -1648
execute in ustc_pvp:template run forceload remove -1888 -1648
execute in minecraft:overworld run forceload remove -1888 -1632
execute in ustc_pvp:template run forceload remove -1888 -1632
execute in minecraft:overworld run forceload remove -1888 -1616
execute in ustc_pvp:template run forceload remove -1888 -1616
execute in minecraft:overworld run forceload remove -1888 -1600
execute in ustc_pvp:template run forceload remove -1888 -1600
execute in minecraft:overworld run forceload remove -1888 -1584
execute in ustc_pvp:template run forceload remove -1888 -1584
execute in minecraft:overworld run forceload remove -1888 -1568
execute in ustc_pvp:template run forceload remove -1888 -1568
execute in minecraft:overworld run forceload remove -1888 -1552
execute in ustc_pvp:template run forceload remove -1888 -1552
execute in minecraft:overworld run forceload remove -1888 -1536
execute in ustc_pvp:template run forceload remove -1888 -1536
function ustc_pvp:reset/advance
