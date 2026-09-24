# The source position preserves shield direction, armor and resistance. Omitting
# an attacker ONLY for the owner avoids the team's friendly-fire/self-hit gate.
$return run execute at @e[tag=pvpshot.current_projectile,limit=1] run damage @s $(dmg) pvpshot:projectile at ~ ~ ~
