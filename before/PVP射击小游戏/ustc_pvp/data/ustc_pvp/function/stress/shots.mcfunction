execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
summon item_display -1900 252 -1500 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1899 252 -1500 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[90f,0f]}
summon item_display -1898 252 -1500 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[180f,0f]}
summon item_display -1897 252 -1500 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[-90f,0f]}
summon item_display -1896 252 -1500 {Tags:["pvpshot.shot","pvpshot.smg_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1895 252 -1500 {Tags:["pvpshot.shot","pvpshot.smg_shot","pvp.stress"],Rotation:[45f,0f]}
summon item_display -1894 252 -1500 {Tags:["pvpshot.shot","pvpshot.smg_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1893 252 -1500 {Tags:["pvpshot.shot","pvpshot.smg_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1901 253 -1501 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1902 253 -1501 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1903 253 -1502 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1904 253 -1502 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1896 253 -1498 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1895 253 -1498 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1894 254 -1497 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1893 254 -1497 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1900 254 -1496 {Tags:["pvpshot.shot","pvpshot.smg_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1899 254 -1496 {Tags:["pvpshot.shot","pvpshot.smg_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1898 255 -1495 {Tags:["pvpshot.shot","pvpshot.smg_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1897 255 -1495 {Tags:["pvpshot.shot","pvpshot.smg_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1902 255 -1499 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1903 255 -1499 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1901 256 -1503 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
summon item_display -1900 256 -1503 {Tags:["pvpshot.shot","pvpshot.fire_shot","pvp.stress"],Rotation:[0f,0f]}
execute as @e[type=item_display,tag=pvp.stress] run scoreboard players set @s pvpshot.velocity 18000
