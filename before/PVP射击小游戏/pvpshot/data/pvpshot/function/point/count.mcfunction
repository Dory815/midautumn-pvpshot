scoreboard players set #red pvpshot.cal 0
scoreboard players set #blue pvpshot.cal 0
$execute as @a[team=pvpshot.red,gamemode=!spectator,gamemode=!creative,nbt=!{Health:0.0f},distance=..$(radius)] run function pvpshot:point/count_red
$execute as @a[team=pvpshot.blue,gamemode=!spectator,gamemode=!creative,nbt=!{Health:0.0f},distance=..$(radius)] run function pvpshot:point/count_blue
