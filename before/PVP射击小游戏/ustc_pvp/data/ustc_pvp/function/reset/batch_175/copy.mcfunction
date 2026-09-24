scoreboard players set #batch.ready ustc.clock 1
execute in minecraft:overworld unless loaded -1584 0 -1216 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1584 0 -1216 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1584 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1584 0 -1200 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1584 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1584 0 -1184 run scoreboard players set #batch.ready ustc.clock 0
execute in minecraft:overworld unless loaded -1584 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute in ustc_pvp:template unless loaded -1584 0 -1168 run scoreboard players set #batch.ready ustc.clock 0
execute if score #batch.ready ustc.clock matches 0 run return run schedule function ustc_pvp:reset/copy_batch 2t replace
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1584 -16 -1216 -1569 55 -1201 to minecraft:overworld -1584 -16 -1216 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1584 56 -1216 -1569 127 -1201 to minecraft:overworld -1584 56 -1216 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1584 -1 -1216 -1569 -1 -1201 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1584,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1584,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1584,y=-16,z=-1216,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1584,y=-16,z=-1216,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1584 -16 -1200 -1569 55 -1185 to minecraft:overworld -1584 -16 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1584 56 -1200 -1569 127 -1185 to minecraft:overworld -1584 56 -1200 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1584 -1 -1200 -1569 -1 -1185 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1584,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1584,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1584,y=-16,z=-1200,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1584,y=-16,z=-1200,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1584 -16 -1184 -1569 55 -1169 to minecraft:overworld -1584 -16 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1584 56 -1184 -1569 127 -1169 to minecraft:overworld -1584 56 -1184 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1584 -1 -1184 -1569 -1 -1169 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1584,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1584,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1584,y=-16,z=-1184,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1584,y=-16,z=-1184,dx=15,dy=272,dz=15]
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1584 -16 -1168 -1569 55 -1153 to minecraft:overworld -1584 -16 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
execute store success score #copied ustc.clock run clone from ustc_pvp:template -1584 56 -1168 -1569 127 -1153 to minecraft:overworld -1584 56 -1168 replace force
execute if score #copied ustc.clock matches 0 run scoreboard players add #reset.errors ustc.clock 1
fill -1584 -1 -1168 -1569 -1 -1153 minecraft:bedrock
kill @e[type=#pvpshot:resettable,x=-1584,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.shot,x=-1584,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.machine,x=-1584,y=-16,z=-1168,dx=15,dy=272,dz=15]
kill @e[tag=pvpshot.field,x=-1584,y=-16,z=-1168,dx=15,dy=272,dz=15]
execute in minecraft:overworld run forceload remove -1584 -1216
execute in ustc_pvp:template run forceload remove -1584 -1216
execute in minecraft:overworld run forceload remove -1584 -1200
execute in ustc_pvp:template run forceload remove -1584 -1200
execute in minecraft:overworld run forceload remove -1584 -1184
execute in ustc_pvp:template run forceload remove -1584 -1184
execute in minecraft:overworld run forceload remove -1584 -1168
execute in ustc_pvp:template run forceload remove -1584 -1168
function ustc_pvp:reset/advance
