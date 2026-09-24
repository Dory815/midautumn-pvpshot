scoreboard players set @s pvpshot.respawn 0
function pvpshot:player/spawn_location
function pvpshot:player/kit
execute store result storage pvpshot:tmp inv int 1 run scoreboard players get #spawn.invuln pvpshot.cfg
function pvpshot:player/invuln with storage pvpshot:tmp
