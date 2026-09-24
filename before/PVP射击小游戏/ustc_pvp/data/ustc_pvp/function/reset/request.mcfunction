scoreboard players set @s pvp_reset 0
execute unless score #test.controls pvpshot.cfg matches 1 run return run tellraw @s {text:"服务器已关闭玩家重置入口。",color:"red"}
execute if score #reset.active ustc.clock matches 1 run return run tellraw @s {text:"战场正在恢复，请等待顶部进度完成。",color:"yellow"}
execute if score #reset.cooldown ustc.clock matches 1.. run return run tellraw @s [{text:"重置冷却中，剩余 "},{score:{name:"#reset.cooldown",objective:"ustc.clock"}},{text:" 秒。",color:"yellow"}]
function ustc_pvp:reset/start
