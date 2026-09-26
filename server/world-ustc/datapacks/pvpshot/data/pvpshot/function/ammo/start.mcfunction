scoreboard players operation @s pvpshot.reload = #ammo.reload pvpshot.cfg
scoreboard players set @s pvpshot.reloading 1
title @s actionbar {text:"火焰弹换弹中…",color:"yellow"}
playsound minecraft:item.armor.equip_iron player @s ~ ~ ~ 0.4 1.3
