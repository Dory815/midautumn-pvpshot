scoreboard players set @s ustc.init 1
function ustc_pvp:lobby
tellraw @s {text:"欢迎来到科大中区。大厅选队；/trigger ustc.join set 1 红队、set 2 蓝队。",color:"aqua"}
