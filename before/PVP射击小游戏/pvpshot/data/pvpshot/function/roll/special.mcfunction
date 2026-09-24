scoreboard players set #sum pvpshot.cal 0
scoreboard players operation #sum pvpshot.cal += #w.fire_charge pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.wind pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.pearl pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.harming pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.slow pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.blind pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.heal pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.linger pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.tnt pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.shield pvpshot.cfg
scoreboard players operation #sum pvpshot.cal += #w.creeper pvpshot.cfg
execute if score #sum pvpshot.cal matches ..0 run return fail
execute store result storage pvpshot:tmp max int 1 run scoreboard players get #sum pvpshot.cal
function pvpshot:roll/rng with storage pvpshot:tmp
scoreboard players set #c pvpshot.cal 0
scoreboard players operation #c pvpshot.cal += #w.wind pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "wind"
scoreboard players operation #c pvpshot.cal += #w.pearl pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "pearl"
scoreboard players operation #c pvpshot.cal += #w.harming pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "harming"
scoreboard players operation #c pvpshot.cal += #w.slow pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "slow"
scoreboard players operation #c pvpshot.cal += #w.blind pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "blind"
scoreboard players operation #c pvpshot.cal += #w.heal pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "heal"
scoreboard players operation #c pvpshot.cal += #w.linger pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "linger"
scoreboard players operation #c pvpshot.cal += #w.tnt pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "tnt"
scoreboard players operation #c pvpshot.cal += #w.shield pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "shield"
scoreboard players operation #c pvpshot.cal += #w.creeper pvpshot.cfg
execute if score #r pvpshot.cal <= #c pvpshot.cal run return run data modify storage pvpshot:roll sid set value "charged_creeper"
data modify storage pvpshot:roll sid set value "fire_charge"
