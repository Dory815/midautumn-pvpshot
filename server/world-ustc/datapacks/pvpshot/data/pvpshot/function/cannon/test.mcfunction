# The old fixed-coordinate test overwrote terrain and leaked force-loaded chunks.
execute unless score #debug pvpshot.cfg matches 1 run return fail
loot give @s loot pvpshot:item/cannon_dye
tellraw @s {text:"已发放 TNT 炮：对准平地部署。自动验证见 tests/run_gametests.py。",color:"yellow"}
