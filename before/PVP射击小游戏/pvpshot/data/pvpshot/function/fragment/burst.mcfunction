# Visual/area damage only: this NEVER edits terrain or changes egg velocity.
summon minecraft:marker ~ ~ ~ {Tags:["pvpshot.fragment_origin"]}
particle minecraft:explosion ~ ~ ~ 0 0 0 0 1 normal
playsound minecraft:entity.generic.explode player @a[distance=..24] ~ ~ ~ 0.25 1.8
execute store result storage pvpshot:fragment dmg int 1 run scoreboard players get #egg.splash_dmg pvpshot.cfg
execute store result storage pvpshot:fragment radius int 1 run scoreboard players get #egg.splash_radius pvpshot.cfg
function pvpshot:fragment/targets with storage pvpshot:fragment
kill @e[type=minecraft:marker,tag=pvpshot.fragment_origin]
