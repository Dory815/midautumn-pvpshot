scoreboard players enable @a pvp_cook
scoreboard players enable @a pvp_land
execute as @e[type=tnt,tag=pvpshot.airbomb,nbt={OnGround:1b}] run data modify entity @s fuse set value 0
