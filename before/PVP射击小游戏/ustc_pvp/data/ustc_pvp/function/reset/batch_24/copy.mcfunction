scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -2080 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2080 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2080 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1728 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2064 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2064 0 -1712 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1200 -2065 55 -1185 to minecraft:overworld -2080 -16 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1200 -2065 127 -1185 to minecraft:overworld -2080 56 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1200 -2065 -1 -1185 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1200,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1184 -2065 55 -1169 to minecraft:overworld -2080 -16 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1184 -2065 127 -1169 to minecraft:overworld -2080 56 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1184 -2065 -1 -1169 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1184,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 -16 -1168 -2065 55 -1153 to minecraft:overworld -2080 -16 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2080 56 -1168 -2065 127 -1153 to minecraft:overworld -2080 56 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2080 -1 -1168 -2065 -1 -1153 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2080,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2080,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2080,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2080,y=-16,z=-1168,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1776 -2049 55 -1761 to minecraft:overworld -2064 -16 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1776 -2049 127 -1761 to minecraft:overworld -2064 56 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1776 -2049 -1 -1761 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1776,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1760 -2049 55 -1745 to minecraft:overworld -2064 -16 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1760 -2049 127 -1745 to minecraft:overworld -2064 56 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1760 -2049 -1 -1745 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1760,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1744 -2049 55 -1729 to minecraft:overworld -2064 -16 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1744 -2049 127 -1729 to minecraft:overworld -2064 56 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1744 -2049 -1 -1729 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1744,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1728 -2049 55 -1713 to minecraft:overworld -2064 -16 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1728 -2049 127 -1713 to minecraft:overworld -2064 56 -1728 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1728 -2049 -1 -1713 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1728,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1728,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 -16 -1712 -2049 55 -1697 to minecraft:overworld -2064 -16 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2064 56 -1712 -2049 127 -1697 to minecraft:overworld -2064 56 -1712 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2064 -1 -1712 -2049 -1 -1697 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2064,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2064,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2064,y=-16,z=-1712,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2064,y=-16,z=-1712,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -2080 -1200
execute in ustc_pvp:template run forceload remove -2080 -1200
execute in minecraft:overworld run forceload remove -2080 -1184
execute in ustc_pvp:template run forceload remove -2080 -1184
execute in minecraft:overworld run forceload remove -2080 -1168
execute in ustc_pvp:template run forceload remove -2080 -1168
execute in minecraft:overworld run forceload remove -2064 -1776
execute in ustc_pvp:template run forceload remove -2064 -1776
execute in minecraft:overworld run forceload remove -2064 -1760
execute in ustc_pvp:template run forceload remove -2064 -1760
execute in minecraft:overworld run forceload remove -2064 -1744
execute in ustc_pvp:template run forceload remove -2064 -1744
execute in minecraft:overworld run forceload remove -2064 -1728
execute in ustc_pvp:template run forceload remove -2064 -1728
execute in minecraft:overworld run forceload remove -2064 -1712
execute in ustc_pvp:template run forceload remove -2064 -1712
function ustc_pvp:reset/advance
