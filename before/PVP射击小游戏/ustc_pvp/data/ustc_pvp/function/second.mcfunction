scoreboard players set #tick ustc.clock 0
execute if score #reset.cooldown ustc.clock matches 1.. run scoreboard players remove #reset.cooldown ustc.clock 1
execute as @a[gamemode=survival,team=!,scores={pvpshot.live=1..}] run function ustc_pvp:mobility/apply
execute if score #chest.timer pvpshot.chest matches 0..19 run function ustc_pvp:refill
function ustc_pvp:hud
function ustc_pvp:advanced/second
scoreboard players add #item.sweep ustc.clock 1
execute if score #item.sweep ustc.clock matches 180.. run kill @e[type=item,x=-2149,y=-2048,z=-1807,dx=580,dy=4096,dz=654]
execute if score #item.sweep ustc.clock matches 180.. run scoreboard players set #item.sweep ustc.clock 0
