execute if score #reset.active ustc.clock matches 1 run return 0
scoreboard players set #reset.active ustc.clock 1
scoreboard players set #reset.index ustc.clock 0
scoreboard players set #reset.errors ustc.clock 0
scoreboard players set #match.state pvpshot.cal 0
execute as @a run function ustc_pvp:lobby
kill @e[tag=pvpshot.machine]
kill @e[tag=pvpshot.shot]
function pvpshot:field/clear
kill @e[type=minecraft:tnt,x=-2144,y=-16,z=-1776,dx=575,dy=272,dz=623]
kill @e[type=minecraft:arrow,x=-2144,y=-16,z=-1776,dx=575,dy=272,dz=623]
kill @e[type=minecraft:snowball,x=-2144,y=-16,z=-1776,dx=575,dy=272,dz=623]
kill @e[type=minecraft:egg,x=-2144,y=-16,z=-1776,dx=575,dy=272,dz=623]
kill @e[type=minecraft:fireball,x=-2144,y=-16,z=-1776,dx=575,dy=272,dz=623]
kill @e[type=minecraft:small_fireball,x=-2144,y=-16,z=-1776,dx=575,dy=272,dz=623]
kill @e[type=minecraft:item,x=-2144,y=-16,z=-1776,dx=575,dy=272,dz=623]
kill @e[type=minecraft:area_effect_cloud,x=-2144,y=-16,z=-1776,dx=575,dy=272,dz=623]
bossbar set ustc_pvp:points visible true
bossbar set ustc_pvp:points max 176
tellraw @a {text:"正在分批恢复中区战场，请在大厅等待。顶部显示恢复进度。",color:"yellow"}
function ustc_pvp:reset/load_batch
