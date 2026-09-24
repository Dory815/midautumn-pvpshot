scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1824 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1824 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1824 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1824 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1824 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1824 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1808 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1808 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1808 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1808 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1808 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1808 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1808 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1808 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1808 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1808 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1824 -16 -1200 -1809 55 -1185 to minecraft:overworld -1824 -16 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1824 56 -1200 -1809 127 -1185 to minecraft:overworld -1824 56 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1824 -1 -1200 -1809 -1 -1185 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1824,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1824,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1824,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1824,y=-16,z=-1200,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1824 -16 -1184 -1809 55 -1169 to minecraft:overworld -1824 -16 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1824 56 -1184 -1809 127 -1169 to minecraft:overworld -1824 56 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1824 -1 -1184 -1809 -1 -1169 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1824,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1824,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1824,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1824,y=-16,z=-1184,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1824 -16 -1168 -1809 55 -1153 to minecraft:overworld -1824 -16 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1824 56 -1168 -1809 127 -1153 to minecraft:overworld -1824 56 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1824 -1 -1168 -1809 -1 -1153 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1824,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1824,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1824,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1824,y=-16,z=-1168,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 -16 -1776 -1793 55 -1761 to minecraft:overworld -1808 -16 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 56 -1776 -1793 127 -1761 to minecraft:overworld -1808 56 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1808 -1 -1776 -1793 -1 -1761 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1808,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1808,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1808,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1808,y=-16,z=-1776,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 -16 -1760 -1793 55 -1745 to minecraft:overworld -1808 -16 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 56 -1760 -1793 127 -1745 to minecraft:overworld -1808 56 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1808 -1 -1760 -1793 -1 -1745 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1808,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1808,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1808,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1808,y=-16,z=-1760,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 -16 -1744 -1793 55 -1729 to minecraft:overworld -1808 -16 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 56 -1744 -1793 127 -1729 to minecraft:overworld -1808 56 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1808 -1 -1744 -1793 -1 -1729 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1808,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1808,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1808,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1808,y=-16,z=-1744,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 -16 -1728 -1793 55 -1713 to minecraft:overworld -1808 -16 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 56 -1728 -1793 127 -1713 to minecraft:overworld -1808 56 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1808 -1 -1728 -1793 -1 -1713 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1808,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1808,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1808,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1808,y=-16,z=-1728,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 -16 -1712 -1793 55 -1697 to minecraft:overworld -1808 -16 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1808 56 -1712 -1793 127 -1697 to minecraft:overworld -1808 56 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1808 -1 -1712 -1793 -1 -1697 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1808,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1808,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1808,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1808,y=-16,z=-1712,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1824 -1200
execute in ustc_pvp:template run forceload remove -1824 -1200
execute in minecraft:overworld run forceload remove -1824 -1184
execute in ustc_pvp:template run forceload remove -1824 -1184
execute in minecraft:overworld run forceload remove -1824 -1168
execute in ustc_pvp:template run forceload remove -1824 -1168
execute in minecraft:overworld run forceload remove -1808 -1776
execute in ustc_pvp:template run forceload remove -1808 -1776
execute in minecraft:overworld run forceload remove -1808 -1760
execute in ustc_pvp:template run forceload remove -1808 -1760
execute in minecraft:overworld run forceload remove -1808 -1744
execute in ustc_pvp:template run forceload remove -1808 -1744
execute in minecraft:overworld run forceload remove -1808 -1728
execute in ustc_pvp:template run forceload remove -1808 -1728
execute in minecraft:overworld run forceload remove -1808 -1712
execute in ustc_pvp:template run forceload remove -1808 -1712
function ustc_pvp:reset/advance
