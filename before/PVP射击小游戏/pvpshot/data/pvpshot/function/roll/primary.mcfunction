scoreboard players set #sum pvpshot.cal 0
scoreboard players operation #sum pvpshot.cal += #w.snowball pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.egg pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.bow pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.crossbow pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.trident pvpshot.cfg
execute if score #sum pvpshot.cal matches ..0 run return fail
execute store result storage pvpshot:tmp max int 1 run scoreboard players get #sum pvpshot.cal
function pvpshot:roll/rng with storage pvpshot:tmp
scoreboard players set #c pvpshot.cal 0
scoreboard players operation #c pvpshot.cal += #w.snowball pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll id set value "snowball"
scoreboard players operation #c pvpshot.cal += #w.egg pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll id set value "egg"
scoreboard players operation #c pvpshot.cal += #w.bow pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll id set value "bow"
scoreboard players operation #c pvpshot.cal += #w.crossbow pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll id set value "crossbow"
data modify storage pvpshot:roll id set value "trident"
