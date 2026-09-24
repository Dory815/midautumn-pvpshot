# @s is the aligned marker; caller supplies its cardinal rotation.
scoreboard players set #place.ok pvpshot.cal 1
execute positioned ^0 ^0 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^0 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^1 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^1 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^2 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^2 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^0 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^0 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^1 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^1 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^2 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^2 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^0 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^0 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^1 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^1 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^2 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^0 ^2 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^0 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^0 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^1 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^1 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^2 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^2 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^0 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^0 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^1 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^1 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^2 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^2 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^0 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^0 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^1 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^1 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^2 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^1 ^2 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^0 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^0 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^1 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^1 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^2 ^0 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^2 ^0 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^0 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^0 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^1 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^1 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^2 ^1 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^2 ^1 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^0 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^0 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^1 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^1 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^2 ^2 if block ~ ~ ~ #pvpshot:indestructible run scoreboard players set #place.ok pvpshot.cal 0
execute positioned ^2 ^2 ^2 run function pvpshot:protection/check
execute if score #protected pvpshot.cal matches 1 run scoreboard players set #place.ok pvpshot.cal 0
