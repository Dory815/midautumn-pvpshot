scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -2048 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2048 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2032 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2032 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2032 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2032 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2032 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2032 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2032 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2032 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2032 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2032 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2032 0 -1696 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2032 0 -1696 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2032 0 -1680 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2032 0 -1680 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2048 -16 -1168 -2033 55 -1153 to minecraft:overworld -2048 -16 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2048 56 -1168 -2033 127 -1153 to minecraft:overworld -2048 56 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2048 -1 -1168 -2033 -1 -1153 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2048,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2048,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2048,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2048,y=-16,z=-1168,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 -16 -1776 -2017 55 -1761 to minecraft:overworld -2032 -16 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 56 -1776 -2017 127 -1761 to minecraft:overworld -2032 56 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2032 -1 -1776 -2017 -1 -1761 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2032,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2032,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2032,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2032,y=-16,z=-1776,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 -16 -1760 -2017 55 -1745 to minecraft:overworld -2032 -16 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 56 -1760 -2017 127 -1745 to minecraft:overworld -2032 56 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2032 -1 -1760 -2017 -1 -1745 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2032,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2032,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2032,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2032,y=-16,z=-1760,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 -16 -1744 -2017 55 -1729 to minecraft:overworld -2032 -16 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 56 -1744 -2017 127 -1729 to minecraft:overworld -2032 56 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2032 -1 -1744 -2017 -1 -1729 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2032,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2032,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2032,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2032,y=-16,z=-1744,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 -16 -1728 -2017 55 -1713 to minecraft:overworld -2032 -16 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 56 -1728 -2017 127 -1713 to minecraft:overworld -2032 56 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2032 -1 -1728 -2017 -1 -1713 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2032,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2032,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2032,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2032,y=-16,z=-1728,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 -16 -1712 -2017 55 -1697 to minecraft:overworld -2032 -16 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 56 -1712 -2017 127 -1697 to minecraft:overworld -2032 56 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2032 -1 -1712 -2017 -1 -1697 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2032,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2032,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2032,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2032,y=-16,z=-1712,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 -16 -1696 -2017 55 -1681 to minecraft:overworld -2032 -16 -1696 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 56 -1696 -2017 127 -1681 to minecraft:overworld -2032 56 -1696 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2032 -1 -1696 -2017 -1 -1681 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2032,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2032,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2032,y=-16,z=-1696,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2032,y=-16,z=-1696,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 -16 -1680 -2017 55 -1665 to minecraft:overworld -2032 -16 -1680 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2032 56 -1680 -2017 127 -1665 to minecraft:overworld -2032 56 -1680 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2032 -1 -1680 -2017 -1 -1665 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2032,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2032,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2032,y=-16,z=-1680,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2032,y=-16,z=-1680,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -2048 -1168
execute in ustc_pvp:template run forceload remove -2048 -1168
execute in minecraft:overworld run forceload remove -2032 -1776
execute in ustc_pvp:template run forceload remove -2032 -1776
execute in minecraft:overworld run forceload remove -2032 -1760
execute in ustc_pvp:template run forceload remove -2032 -1760
execute in minecraft:overworld run forceload remove -2032 -1744
execute in ustc_pvp:template run forceload remove -2032 -1744
execute in minecraft:overworld run forceload remove -2032 -1728
execute in ustc_pvp:template run forceload remove -2032 -1728
execute in minecraft:overworld run forceload remove -2032 -1712
execute in ustc_pvp:template run forceload remove -2032 -1712
execute in minecraft:overworld run forceload remove -2032 -1696
execute in ustc_pvp:template run forceload remove -2032 -1696
execute in minecraft:overworld run forceload remove -2032 -1680
execute in ustc_pvp:template run forceload remove -2032 -1680
function ustc_pvp:reset/advance
