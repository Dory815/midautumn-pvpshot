# TNT is created by the dispenser. A single launch impulse replaces explosive
# propellant. TNT then explodes natively, including cover, distance and terrain.
tag @s add pvpshot.cannon_shell
data modify entity @s owner set from storage pvpshot:shot owner
data modify entity @s fuse set value 45
execute if data storage pvpshot:shot {rotation:"none"} run data modify entity @s Motion set value [0.0d,0.45d,1.25d]
execute if data storage pvpshot:shot {rotation:"clockwise_90"} run data modify entity @s Motion set value [-1.25d,0.45d,0.0d]
execute if data storage pvpshot:shot {rotation:"180"} run data modify entity @s Motion set value [0.0d,0.45d,-1.25d]
execute if data storage pvpshot:shot {rotation:"counterclockwise_90"} run data modify entity @s Motion set value [1.25d,0.45d,0.0d]
