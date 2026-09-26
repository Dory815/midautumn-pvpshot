scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1632 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1632 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1632 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1632 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1632 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1632 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1632 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1632 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1632 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1632 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1632 0 -1696 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1632 0 -1696 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1632 0 -1680 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1632 0 -1680 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1632 0 -1664 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1632 0 -1664 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 -16 -1776 -1617 55 -1761 to minecraft:overworld -1632 -16 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 56 -1776 -1617 127 -1761 to minecraft:overworld -1632 56 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1632 -1 -1776 -1617 -1 -1761 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1632,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1632,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1632,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1632,y=-16,z=-1776,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 -16 -1760 -1617 55 -1745 to minecraft:overworld -1632 -16 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 56 -1760 -1617 127 -1745 to minecraft:overworld -1632 56 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1632 -1 -1760 -1617 -1 -1745 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1632,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1632,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1632,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1632,y=-16,z=-1760,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 -16 -1744 -1617 55 -1729 to minecraft:overworld -1632 -16 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 56 -1744 -1617 127 -1729 to minecraft:overworld -1632 56 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1632 -1 -1744 -1617 -1 -1729 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1632,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1632,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1632,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1632,y=-16,z=-1744,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 -16 -1728 -1617 55 -1713 to minecraft:overworld -1632 -16 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 56 -1728 -1617 127 -1713 to minecraft:overworld -1632 56 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1632 -1 -1728 -1617 -1 -1713 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1632,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1632,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1632,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1632,y=-16,z=-1728,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 -16 -1712 -1617 55 -1697 to minecraft:overworld -1632 -16 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 56 -1712 -1617 127 -1697 to minecraft:overworld -1632 56 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1632 -1 -1712 -1617 -1 -1697 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1632,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1632,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1632,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1632,y=-16,z=-1712,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 -16 -1696 -1617 55 -1681 to minecraft:overworld -1632 -16 -1696 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 56 -1696 -1617 127 -1681 to minecraft:overworld -1632 56 -1696 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1632 -1 -1696 -1617 -1 -1681 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1632,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1632,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1632,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1632,y=-16,z=-1696,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 -16 -1680 -1617 55 -1665 to minecraft:overworld -1632 -16 -1680 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 56 -1680 -1617 127 -1665 to minecraft:overworld -1632 56 -1680 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1632 -1 -1680 -1617 -1 -1665 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1632,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1632,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1632,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1632,y=-16,z=-1680,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 -16 -1664 -1617 55 -1649 to minecraft:overworld -1632 -16 -1664 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1632 56 -1664 -1617 127 -1649 to minecraft:overworld -1632 56 -1664 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1632 -1 -1664 -1617 -1 -1649 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1632,y=-16,z=-1664,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1632,y=-16,z=-1664,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1632,y=-16,z=-1664,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1632,y=-16,z=-1664,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1632 -1776
execute in ustc_pvp:template run forceload remove -1632 -1776
execute in minecraft:overworld run forceload remove -1632 -1760
execute in ustc_pvp:template run forceload remove -1632 -1760
execute in minecraft:overworld run forceload remove -1632 -1744
execute in ustc_pvp:template run forceload remove -1632 -1744
execute in minecraft:overworld run forceload remove -1632 -1728
execute in ustc_pvp:template run forceload remove -1632 -1728
execute in minecraft:overworld run forceload remove -1632 -1712
execute in ustc_pvp:template run forceload remove -1632 -1712
execute in minecraft:overworld run forceload remove -1632 -1696
execute in ustc_pvp:template run forceload remove -1632 -1696
execute in minecraft:overworld run forceload remove -1632 -1680
execute in ustc_pvp:template run forceload remove -1632 -1680
execute in minecraft:overworld run forceload remove -1632 -1664
execute in ustc_pvp:template run forceload remove -1632 -1664
function ustc_pvp:reset/advance
