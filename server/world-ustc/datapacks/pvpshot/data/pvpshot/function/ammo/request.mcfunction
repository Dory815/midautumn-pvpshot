scoreboard players set @s pvp_reload 0
execute if score @s pvpshot.reloading matches 1 run return 0
function pvpshot:ammo/count
execute if score @s pvpshot.ammo matches 16.. run return run title @s actionbar {text:"火焰弹弹匣已满",color:"aqua"}
clear @s minecraft:blaze_powder[minecraft:custom_data~{pvpshot:{weapon:"fire_charge"}}]
function pvpshot:ammo/start
