scoreboard objectives add ustc.deaths dummy
scoreboard objectives add ustc.init dummy
scoreboard objectives add ustc.clock dummy
scoreboard objectives add ustc.owner_old dummy
scoreboard objectives add ustc.y dummy
scoreboard objectives add ustc.join trigger
scoreboard objectives add ustc.mode trigger
scoreboard objectives add ustc.mobility trigger
scoreboard objectives add pvp_reset trigger
scoreboard objectives add pvp_kit trigger
scoreboard objectives add pvp_lobby trigger
bossbar add ustc_pvp:points {text:"科大中区",color:"white"}
bossbar set ustc_pvp:points color white
execute unless data storage ustc_pvp:state {prepared:1b} run return 0
scoreboard players set #protection.active ustc.clock 1
scoreboard players set #protection.edit ustc.clock 0
function ustc_pvp:anchors
schedule function ustc_pvp:resume 5t replace
schedule function ustc_pvp:guide/build 20t replace
scoreboard players set #drops.clear ustc.clock 1
gamerule minecraft:block_drops false
gamerule minecraft:entity_drops false
gamerule minecraft:mob_drops false
execute unless data storage ustc_pvp:state {balance_v7:1b} run schedule function ustc_pvp:v7/upgrade 10t replace
execute unless data storage ustc_pvp:state {balance_v8:1b} run schedule function ustc_pvp:v8/upgrade 10t replace
