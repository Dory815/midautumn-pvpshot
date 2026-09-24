execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
scoreboard players set #debug pvpshot.cfg 0
