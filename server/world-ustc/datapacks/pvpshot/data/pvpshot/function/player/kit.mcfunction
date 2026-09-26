clear @s
function pvpshot:kit/base
function pvpshot:roll/secondary
execute if score #sum pvpshot.cal matches 1.. run function pvpshot:kit/give_primary with storage pvpshot:roll
execute if entity @s[team=pvpshot.red] run function pvpshot:kit/cap_red
execute if entity @s[team=pvpshot.blue] run function pvpshot:kit/cap_blue
execute store result storage pvpshot:tmp hp int 1 run scoreboard players get #hp pvpshot.cfg
function pvpshot:player/set_hp with storage pvpshot:tmp
