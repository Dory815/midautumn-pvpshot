# The old fixed-coordinate test overwrote terrain and leaked force-loaded chunks.
execute if entity @s[type=player,name=!<ssh用户>,tag=!pvp.staff] run return run function pvpshot:debug/deny
execute unless score #debug pvpshot.cfg matches 1 run return fail
loot give @s loot pvpshot:item/cannon_dye
tellraw @s {text:"已发放 TNT 炮：对准平地部署。自动验证见 tests/run_gametests.py。",color:"yellow"}
