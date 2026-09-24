execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
$scoreboard players set #stress.n ustc.clock $(count)
function ustc_pvp:stress/crowd_one
