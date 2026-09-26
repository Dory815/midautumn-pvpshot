execute if score #cap.index pvpshot.cal matches 176.. run return 0
execute store result storage pvpshot_capture:state batch int 1 run scoreboard players get #cap.index pvpshot.cal
function pvpshot_capture:step_macro with storage pvpshot_capture:state
scoreboard players add #cap.index pvpshot.cal 1
execute if score #cap.index pvpshot.cal matches ..176 run schedule function pvpshot_capture:step 10t replace
execute if score #cap.index pvpshot.cal matches 176.. run function pvpshot_capture:finish
