scoreboard players add #chest.timer pvpshot.chest 1
execute if score #chest.timer pvpshot.chest >= #chest.interval pvpshot.cfg run function pvpshot:chest/refill_all
