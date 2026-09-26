scoreboard players set #tick ustc.clock 0
execute if score #reset.cooldown ustc.clock matches 1.. run scoreboard players remove #reset.cooldown ustc.clock 1
execute as @a[gamemode=survival,team=!,nbt=!{Health:0.0f}] run function ustc_pvp:mobility/apply
execute if score #chest.timer pvpshot.chest matches 0..19 run function ustc_pvp:refill
function ustc_pvp:hud
function ustc_pvp:advanced/second
