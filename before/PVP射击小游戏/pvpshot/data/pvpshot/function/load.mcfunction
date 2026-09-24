data modify storage pvpshot:const structure.turret set value "face_turret"
data modify storage pvpshot:const structure.cannon set value "tnt_cannon"
scoreboard objectives add pvpshot.cfg dummy
scoreboard objectives add pvpshot.hp_set dummy
scoreboard objectives add pvpshot.cal dummy
scoreboard objectives add pvpshot.deaths deathCount
scoreboard objectives add pvpshot.deaths_old dummy
scoreboard objectives add pvpshot.kills playerKillCount
scoreboard objectives add pvpshot.kills_old dummy
scoreboard objectives add pvpshot.init dummy
scoreboard objectives add pvpshot.score dummy
scoreboard objectives add pvpshot.owner dummy
scoreboard objectives add pvpshot.capture dummy
scoreboard objectives add pvpshot.point_init dummy
bossbar add pvpshot:red {text:"红队",color:"red"}
bossbar add pvpshot:blue {text:"蓝队",color:"blue"}
bossbar set pvpshot:red color red
bossbar set pvpshot:blue color blue
scoreboard objectives add pvpshot.chest dummy
team add pvpshot.red
team add pvpshot.blue
team modify pvpshot.red color red
team modify pvpshot.blue color blue
scoreboard players set Red pvpshot.score 0
scoreboard players set Blue pvpshot.score 0
scoreboard objectives setdisplay sidebar
scoreboard objectives add pvpshot.ammo dummy
scoreboard objectives add pvpshot.reload dummy
scoreboard objectives add pvpshot.reloading dummy
scoreboard objectives add pvp_reload trigger
scoreboard objectives add pvpshot.quiet dummy
scoreboard objectives add pvpshot.healing dummy
scoreboard objectives add pvpshot.health dummy
scoreboard objectives add pvpshot.live health
scoreboard objectives add pvpshot.heal_age dummy
function pvpshot:cfg/default
function pvpshot:cfg/override
execute if score #friendlyfire pvpshot.cfg matches 1 run team modify pvpshot.red friendlyFire true
execute if score #friendlyfire pvpshot.cfg matches 1 run team modify pvpshot.blue friendlyFire true
execute unless score #friendlyfire pvpshot.cfg matches 1 run team modify pvpshot.red friendlyFire false
execute unless score #friendlyfire pvpshot.cfg matches 1 run team modify pvpshot.blue friendlyFire false
execute store result storage pvpshot:tmp hp int 1 run scoreboard players get #hp pvpshot.cfg
execute as @a run function pvpshot:player/set_hp with storage pvpshot:tmp

scoreboard objectives add pvpshot.age dummy
scoreboard players set #twenty pvpshot.cal 20
scoreboard objectives add pvpshot.respawn dummy

# Native team-colour kill counters keep friendly kills out of match scores.
scoreboard objectives add pvpshot.kill_red teamkill.red
scoreboard objectives add pvpshot.kill_blue teamkill.blue
scoreboard objectives add pvpshot.kr_old dummy
scoreboard objectives add pvpshot.kb_old dummy
scoreboard objectives add pvpshot.ff_init dummy
execute as @a run function pvpshot:player/score_init
scoreboard players set #hundred pvpshot.cal 100
gamerule minecraft:natural_health_regeneration false
execute as @a run function pvpshot:regen/in_combat
function pvpshot:field/load
function pvpshot:match/restart

function pvpshot:shot/load
function pvpshot:v7/load
function pvpshot:v8/load
