$execute as @a[gamemode=!spectator,nbt=!{Health:0.0f},tag=!pvpshot.direct_hit,distance=..$(radius)] at @s run function pvpshot:fragment/target
