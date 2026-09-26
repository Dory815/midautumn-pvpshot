# 由 tools/clean-trees-near-points.py 生成（模板维度入口）
# 先 forceload 180 个区块，5 tick 后跑 run_template_fill
execute in ustc_pvp:template run forceload add -2029 -1574 -1949 -1494
execute in ustc_pvp:template run forceload add -1896 -1580 -1816 -1500
execute in ustc_pvp:template run forceload add -1749 -1574 -1669 -1494
execute in ustc_pvp:template run forceload add -1715 -1699 -1635 -1619
execute in ustc_pvp:template run forceload add -2119 -1417 -2039 -1337
schedule function pvpshot_cleanup:run_template_fill 5t replace
tellraw @a {"text":"[清树] 模板维度已常加载 5 个点位区块，5 tick 后开始清理"}
