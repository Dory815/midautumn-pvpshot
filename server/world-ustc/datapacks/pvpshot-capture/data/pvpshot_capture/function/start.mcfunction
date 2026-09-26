# 把主世界竞技场灌进 ustc_pvp:template（每 10 tick 一批，共 176 批）
tellraw @a {"text":"[capture] 开始把当前地图灌进复原模板，请稍候（约 88 秒）。"}
# 区块加载交给校园包自己的 batch_N/load（它按 256 区块以内的粒度分批 forceload）
scoreboard players set #cap.index pvpshot.cal 0
function pvpshot_capture:step
