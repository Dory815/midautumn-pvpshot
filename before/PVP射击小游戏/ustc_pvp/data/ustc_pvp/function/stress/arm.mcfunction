execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
$scoreboard players set #stress.n ustc.clock $(shots)
function ustc_pvp:stress/volley
execute as @e[type=item_display,tag=pvp.stress] run scoreboard players set @s pvpshot.velocity 0
scoreboard players set #stress.t ustc.clock 0
function ustc_pvp:stress/wave
