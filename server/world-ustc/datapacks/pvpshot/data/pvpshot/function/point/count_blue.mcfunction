execute store result score #point.feet pvpshot.cal run data get entity @s Pos[1] 100
execute if score #point.feet pvpshot.cal >= #point.ymin pvpshot.cal if score #point.feet pvpshot.cal <= #point.ymax pvpshot.cal run scoreboard players add #blue pvpshot.cal 1
