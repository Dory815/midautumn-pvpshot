scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1616 0 -1632 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1616 0 -1632 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1616 0 -1616 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1616 0 -1616 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1616 0 -1600 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1616 0 -1600 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1616 0 -1584 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1616 0 -1584 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1616 0 -1568 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1616 0 -1568 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1616 0 -1552 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1616 0 -1552 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1616 0 -1536 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1616 0 -1536 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1616 0 -1520 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1616 0 -1520 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 -16 -1632 -1601 55 -1617 to minecraft:overworld -1616 -16 -1632 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 56 -1632 -1601 127 -1617 to minecraft:overworld -1616 56 -1632 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1616 -1 -1632 -1601 -1 -1617 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1616,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1616,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1616,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1616,y=-16,z=-1632,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 -16 -1616 -1601 55 -1601 to minecraft:overworld -1616 -16 -1616 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 56 -1616 -1601 127 -1601 to minecraft:overworld -1616 56 -1616 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1616 -1 -1616 -1601 -1 -1601 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1616,y=-16,z=-1616,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1616,y=-16,z=-1616,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1616,y=-16,z=-1616,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1616,y=-16,z=-1616,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 -16 -1600 -1601 55 -1585 to minecraft:overworld -1616 -16 -1600 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 56 -1600 -1601 127 -1585 to minecraft:overworld -1616 56 -1600 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1616 -1 -1600 -1601 -1 -1585 minecraft:bedrock
function ustc_pvp:terrain/c_-1616_-1600
kill @e[type=#pvpshot:resettable,x=-1616,y=-16,z=-1600,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1616,y=-16,z=-1600,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1616,y=-16,z=-1600,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1616,y=-16,z=-1600,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 -16 -1584 -1601 55 -1569 to minecraft:overworld -1616 -16 -1584 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 56 -1584 -1601 127 -1569 to minecraft:overworld -1616 56 -1584 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1616 -1 -1584 -1601 -1 -1569 minecraft:bedrock
function ustc_pvp:terrain/c_-1616_-1584
kill @e[type=#pvpshot:resettable,x=-1616,y=-16,z=-1584,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1616,y=-16,z=-1584,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1616,y=-16,z=-1584,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1616,y=-16,z=-1584,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 -16 -1568 -1601 55 -1553 to minecraft:overworld -1616 -16 -1568 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 56 -1568 -1601 127 -1553 to minecraft:overworld -1616 56 -1568 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1616 -1 -1568 -1601 -1 -1553 minecraft:bedrock
function ustc_pvp:terrain/c_-1616_-1568
kill @e[type=#pvpshot:resettable,x=-1616,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1616,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1616,y=-16,z=-1568,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1616,y=-16,z=-1568,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 -16 -1552 -1601 55 -1537 to minecraft:overworld -1616 -16 -1552 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 56 -1552 -1601 127 -1537 to minecraft:overworld -1616 56 -1552 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1616 -1 -1552 -1601 -1 -1537 minecraft:bedrock
function ustc_pvp:terrain/c_-1616_-1552
kill @e[type=#pvpshot:resettable,x=-1616,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1616,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1616,y=-16,z=-1552,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1616,y=-16,z=-1552,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 -16 -1536 -1601 55 -1521 to minecraft:overworld -1616 -16 -1536 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 56 -1536 -1601 127 -1521 to minecraft:overworld -1616 56 -1536 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1616 -1 -1536 -1601 -1 -1521 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1616,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1616,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1616,y=-16,z=-1536,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1616,y=-16,z=-1536,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 -16 -1520 -1601 55 -1505 to minecraft:overworld -1616 -16 -1520 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1616 56 -1520 -1601 127 -1505 to minecraft:overworld -1616 56 -1520 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1616 -1 -1520 -1601 -1 -1505 minecraft:bedrock
function ustc_pvp:terrain/c_-1616_-1520
kill @e[type=#pvpshot:resettable,x=-1616,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1616,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1616,y=-16,z=-1520,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1616,y=-16,z=-1520,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1616 -1632
execute in ustc_pvp:template run forceload remove -1616 -1632
execute in minecraft:overworld run forceload remove -1616 -1616
execute in ustc_pvp:template run forceload remove -1616 -1616
execute in minecraft:overworld run forceload remove -1616 -1600
execute in ustc_pvp:template run forceload remove -1616 -1600
execute in minecraft:overworld run forceload remove -1616 -1584
execute in ustc_pvp:template run forceload remove -1616 -1584
execute in minecraft:overworld run forceload remove -1616 -1568
execute in ustc_pvp:template run forceload remove -1616 -1568
execute in minecraft:overworld run forceload remove -1616 -1552
execute in ustc_pvp:template run forceload remove -1616 -1552
execute in minecraft:overworld run forceload remove -1616 -1536
execute in ustc_pvp:template run forceload remove -1616 -1536
execute in minecraft:overworld run forceload remove -1616 -1520
execute in ustc_pvp:template run forceload remove -1616 -1520
function ustc_pvp:reset/advance
