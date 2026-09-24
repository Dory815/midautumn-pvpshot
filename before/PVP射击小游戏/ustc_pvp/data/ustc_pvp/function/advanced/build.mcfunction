scoreboard players set #protection.edit ustc.clock 1
kill @e[tag=ustc.advanced]
kill @e[tag=ustc.advanced_label]
fill -1859 1 -1631 -1857 1 -1629 polished_deepslate
fill -1859 2 -1631 -1857 4 -1629 air
setblock -1858 2 -1630 trapped_chest[facing=north]
summon marker -1857.5 2 -1629.5 {"Tags":["ustc.marker","ustc.advanced"]}
summon text_display -1857.5 5 -1629.5 {"Tags":["ustc.decor","ustc.advanced_label"],"text":{"text":"北区 独立高级补给\n5 分钟刷新 · 稀有装备 100%","color":"light_purple"},"billboard":"center","background":1073741824,"line_width":260}
fill -1844 1 -1411 -1842 1 -1409 polished_deepslate
fill -1844 2 -1411 -1842 4 -1409 air
setblock -1843 2 -1410 trapped_chest[facing=north]
summon marker -1842.5 2 -1409.5 {"Tags":["ustc.marker","ustc.advanced"]}
summon text_display -1842.5 5 -1409.5 {"Tags":["ustc.decor","ustc.advanced_label"],"text":{"text":"南区 独立高级补给\n5 分钟刷新 · 稀有装备 100%","color":"light_purple"},"billboard":"center","background":1073741824,"line_width":260}
scoreboard players set #protection.edit ustc.clock 0
scoreboard players set #advanced.timer ustc.clock 0
function ustc_pvp:advanced/refill
function ustc_pvp:guide/build
