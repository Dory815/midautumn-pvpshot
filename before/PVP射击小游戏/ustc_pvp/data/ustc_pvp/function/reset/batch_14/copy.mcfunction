scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -2112 0 -1232 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2112 0 -1232 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2112 0 -1216 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2112 0 -1216 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2112 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2112 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2112 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2112 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2112 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2112 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2096 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2096 0 -1776 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2096 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2096 0 -1760 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -2096 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -2096 0 -1744 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 -16 -1232 -2097 55 -1217 to minecraft:overworld -2112 -16 -1232 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 56 -1232 -2097 127 -1217 to minecraft:overworld -2112 56 -1232 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2112 -1 -1232 -2097 -1 -1217 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2112,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2112,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2112,y=-16,z=-1232,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2112,y=-16,z=-1232,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 -16 -1216 -2097 55 -1201 to minecraft:overworld -2112 -16 -1216 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 56 -1216 -2097 127 -1201 to minecraft:overworld -2112 56 -1216 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2112 -1 -1216 -2097 -1 -1201 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2112,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2112,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2112,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2112,y=-16,z=-1216,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 -16 -1200 -2097 55 -1185 to minecraft:overworld -2112 -16 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 56 -1200 -2097 127 -1185 to minecraft:overworld -2112 56 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2112 -1 -1200 -2097 -1 -1185 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2112,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2112,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2112,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2112,y=-16,z=-1200,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 -16 -1184 -2097 55 -1169 to minecraft:overworld -2112 -16 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 56 -1184 -2097 127 -1169 to minecraft:overworld -2112 56 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2112 -1 -1184 -2097 -1 -1169 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2112,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2112,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2112,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2112,y=-16,z=-1184,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 -16 -1168 -2097 55 -1153 to minecraft:overworld -2112 -16 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2112 56 -1168 -2097 127 -1153 to minecraft:overworld -2112 56 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2112 -1 -1168 -2097 -1 -1153 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2112,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2112,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2112,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2112,y=-16,z=-1168,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2096 -16 -1776 -2081 55 -1761 to minecraft:overworld -2096 -16 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2096 56 -1776 -2081 127 -1761 to minecraft:overworld -2096 56 -1776 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2096 -1 -1776 -2081 -1 -1761 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2096,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2096,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2096,y=-16,z=-1776,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2096,y=-16,z=-1776,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2096 -16 -1760 -2081 55 -1745 to minecraft:overworld -2096 -16 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2096 56 -1760 -2081 127 -1745 to minecraft:overworld -2096 56 -1760 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2096 -1 -1760 -2081 -1 -1745 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2096,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2096,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2096,y=-16,z=-1760,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2096,y=-16,z=-1760,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2096 -16 -1744 -2081 55 -1729 to minecraft:overworld -2096 -16 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -2096 56 -1744 -2081 127 -1729 to minecraft:overworld -2096 56 -1744 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -2096 -1 -1744 -2081 -1 -1729 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-2096,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-2096,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-2096,y=-16,z=-1744,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-2096,y=-16,z=-1744,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -2112 -1232
execute in ustc_pvp:template run forceload remove -2112 -1232
execute in minecraft:overworld run forceload remove -2112 -1216
execute in ustc_pvp:template run forceload remove -2112 -1216
execute in minecraft:overworld run forceload remove -2112 -1200
execute in ustc_pvp:template run forceload remove -2112 -1200
execute in minecraft:overworld run forceload remove -2112 -1184
execute in ustc_pvp:template run forceload remove -2112 -1184
execute in minecraft:overworld run forceload remove -2112 -1168
execute in ustc_pvp:template run forceload remove -2112 -1168
execute in minecraft:overworld run forceload remove -2096 -1776
execute in ustc_pvp:template run forceload remove -2096 -1776
execute in minecraft:overworld run forceload remove -2096 -1760
execute in ustc_pvp:template run forceload remove -2096 -1760
execute in minecraft:overworld run forceload remove -2096 -1744
execute in ustc_pvp:template run forceload remove -2096 -1744
function ustc_pvp:reset/advance
