# Validate the barrel before powering; never refill ammunition on a pulse.
execute positioned ^1 ^1 ^3 unless block ~ ~ ~ minecraft:dispenser run return 0
execute positioned ^1 ^1 ^2 if block ~ ~ ~ minecraft:air run setblock ~ ~ ~ minecraft:redstone_block
