scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1984 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1984 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1984 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1984 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1984 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1984 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1984 0 -1696 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1984 0 -1696 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1984 0 -1680 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1984 0 -1680 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1984 0 -1664 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1984 0 -1664 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1984 0 -1648 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1984 0 -1648 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1984 0 -1632 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1984 0 -1632 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 -16 -1744 -1969 55 -1729 to minecraft:overworld -1984 -16 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 56 -1744 -1969 127 -1729 to minecraft:overworld -1984 56 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1984 -1 -1744 -1969 -1 -1729 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1984,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1984,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1984,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1984,y=-16,z=-1744,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 -16 -1728 -1969 55 -1713 to minecraft:overworld -1984 -16 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 56 -1728 -1969 127 -1713 to minecraft:overworld -1984 56 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1984 -1 -1728 -1969 -1 -1713 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1984,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1984,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1984,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1984,y=-16,z=-1728,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 -16 -1712 -1969 55 -1697 to minecraft:overworld -1984 -16 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 56 -1712 -1969 127 -1697 to minecraft:overworld -1984 56 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1984 -1 -1712 -1969 -1 -1697 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1984,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1984,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1984,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1984,y=-16,z=-1712,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 -16 -1696 -1969 55 -1681 to minecraft:overworld -1984 -16 -1696 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 56 -1696 -1969 127 -1681 to minecraft:overworld -1984 56 -1696 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1984 -1 -1696 -1969 -1 -1681 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1984,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1984,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1984,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1984,y=-16,z=-1696,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 -16 -1680 -1969 55 -1665 to minecraft:overworld -1984 -16 -1680 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 56 -1680 -1969 127 -1665 to minecraft:overworld -1984 56 -1680 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1984 -1 -1680 -1969 -1 -1665 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1984,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1984,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1984,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1984,y=-16,z=-1680,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 -16 -1664 -1969 55 -1649 to minecraft:overworld -1984 -16 -1664 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 56 -1664 -1969 127 -1649 to minecraft:overworld -1984 56 -1664 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1984 -1 -1664 -1969 -1 -1649 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1984,y=-16,z=-1664,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1984,y=-16,z=-1664,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1984,y=-16,z=-1664,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1984,y=-16,z=-1664,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 -16 -1648 -1969 55 -1633 to minecraft:overworld -1984 -16 -1648 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 56 -1648 -1969 127 -1633 to minecraft:overworld -1984 56 -1648 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1984 -1 -1648 -1969 -1 -1633 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1984,y=-16,z=-1648,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1984,y=-16,z=-1648,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1984,y=-16,z=-1648,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1984,y=-16,z=-1648,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 -16 -1632 -1969 55 -1617 to minecraft:overworld -1984 -16 -1632 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1984 56 -1632 -1969 127 -1617 to minecraft:overworld -1984 56 -1632 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1984 -1 -1632 -1969 -1 -1617 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1984,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1984,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1984,y=-16,z=-1632,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1984,y=-16,z=-1632,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1984 -1744
execute in ustc_pvp:template run forceload remove -1984 -1744
execute in minecraft:overworld run forceload remove -1984 -1728
execute in ustc_pvp:template run forceload remove -1984 -1728
execute in minecraft:overworld run forceload remove -1984 -1712
execute in ustc_pvp:template run forceload remove -1984 -1712
execute in minecraft:overworld run forceload remove -1984 -1696
execute in ustc_pvp:template run forceload remove -1984 -1696
execute in minecraft:overworld run forceload remove -1984 -1680
execute in ustc_pvp:template run forceload remove -1984 -1680
execute in minecraft:overworld run forceload remove -1984 -1664
execute in ustc_pvp:template run forceload remove -1984 -1664
execute in minecraft:overworld run forceload remove -1984 -1648
execute in ustc_pvp:template run forceload remove -1984 -1648
execute in minecraft:overworld run forceload remove -1984 -1632
execute in ustc_pvp:template run forceload remove -1984 -1632
function ustc_pvp:reset/advance
