scoreboard players set #sum pvpshot.cal 0
scoreboard players operation #sum pvpshot.cal += #w.leather pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.gold pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.chain pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.iron pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.diamond pvpshot.cfg
execute if score #sum pvpshot.cal matches ..0 run return fail
execute store result storage pvpshot:tmp max int 1 run scoreboard players get #sum pvpshot.cal
function pvpshot:roll/rng with storage pvpshot:tmp
scoreboard players set #c pvpshot.cal 0
scoreboard players operation #c pvpshot.cal += #w.leather pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run data modify storage pvpshot:roll armor set value "leather"
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run function pvpshot:roll/armor_slot
scoreboard players operation #c pvpshot.cal += #w.gold pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run data modify storage pvpshot:roll armor set value "golden"
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run function pvpshot:roll/armor_slot
scoreboard players operation #c pvpshot.cal += #w.chain pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run data modify storage pvpshot:roll armor set value "chainmail"
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run function pvpshot:roll/armor_slot
scoreboard players operation #c pvpshot.cal += #w.iron pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run data modify storage pvpshot:roll armor set value "iron"
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run function pvpshot:roll/armor_slot
data modify storage pvpshot:roll armor set value "diamond"
function pvpshot:roll/armor_slot
