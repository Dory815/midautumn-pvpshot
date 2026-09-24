execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
execute unless score #debug pvpshot.cfg matches 1 run return fail
function pvpshot:give/deploy
tellraw @s {text:"已发放两种部署物；右键检查四向部署与发射。",color:"yellow"}
