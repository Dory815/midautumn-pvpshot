scoreboard players set @s pvpshot.owner 0
scoreboard players set @s pvpshot.capture 0
# Points must continue scoring after the last player leaves their chunk.
forceload add ~ ~
scoreboard players set @s pvpshot.point_init 1
