scoreboard players set #protection.edit ustc.clock 1
scoreboard players set #found.i ustc.clock 0
scoreboard players set #found.n ustc.clock 4096
scoreboard players set #found.w ustc.clock 64
scoreboard players set #found.16 ustc.clock 16
scoreboard players set #found.x0 ustc.clock -2560
scoreboard players set #found.z0 ustc.clock -2048
tellraw @a {text:"正在铺设战场基岩并清除下层，请稍候。",color:"yellow"}
function ustc_pvp:foundation/step
