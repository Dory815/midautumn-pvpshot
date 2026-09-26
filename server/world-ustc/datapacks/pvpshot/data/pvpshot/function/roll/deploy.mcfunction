scoreboard players set #sum pvpshot.cal 0
scoreboard players operation #sum pvpshot.cal += #w.turret pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.cannon pvpshot.cfg
execute if score #sum pvpshot.cal matches ..0 run return fail
execute store result storage pvpshot:tmp max int 1 run scoreboard players get #sum pvpshot.cal
function pvpshot:roll/rng with storage pvpshot:tmp
scoreboard players set #c pvpshot.cal 0
scoreboard players operation #c pvpshot.cal += #w.turret pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll did set value "turret_dye"
data modify storage pvpshot:roll did set value "cannon_dye"
