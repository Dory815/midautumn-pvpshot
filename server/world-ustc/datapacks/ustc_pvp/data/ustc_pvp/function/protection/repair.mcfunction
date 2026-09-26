scoreboard players set #protection.edit ustc.clock 1
fill -2147 8 -1805 -2113 8 -1791 minecraft:smooth_stone
fill -2147 9 -1805 -2113 14 -1791 minecraft:air
setblock -2144 9 -1804 minecraft:polished_deepslate
setblock -2144 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:join_red",TrackOutput:0b}
setblock -2144 10 -1803 minecraft:stone_button[face=wall,facing=south]
setblock -2137 9 -1804 minecraft:polished_deepslate
setblock -2137 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:join_blue",TrackOutput:0b}
setblock -2137 10 -1803 minecraft:stone_button[face=wall,facing=south]
setblock -2130 9 -1804 minecraft:polished_deepslate
setblock -2130 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/three",TrackOutput:0b}
setblock -2130 10 -1803 minecraft:stone_button[face=wall,facing=south]
setblock -2123 9 -1804 minecraft:polished_deepslate
setblock -2123 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/five",TrackOutput:0b}
setblock -2123 10 -1803 minecraft:stone_button[face=wall,facing=south]
setblock -2116 9 -1804 minecraft:polished_deepslate
setblock -2116 10 -1804 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/deathmatch",TrackOutput:0b}
setblock -2116 10 -1803 minecraft:stone_button[face=wall,facing=south]
setblock -2144 9 -1793 minecraft:polished_deepslate
setblock -2144 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:reset/request",TrackOutput:0b}
setblock -2144 10 -1792 minecraft:stone_button[face=wall,facing=south]
setblock -2137 9 -1793 minecraft:polished_deepslate
setblock -2137 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:kit",TrackOutput:0b}
setblock -2137 10 -1792 minecraft:stone_button[face=wall,facing=south]
setblock -2130 9 -1793 minecraft:polished_deepslate
setblock -2130 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/mobility_0",TrackOutput:0b}
setblock -2130 10 -1792 minecraft:stone_button[face=wall,facing=south]
setblock -2123 9 -1793 minecraft:polished_deepslate
setblock -2123 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/mobility_1",TrackOutput:0b}
setblock -2123 10 -1792 minecraft:stone_button[face=wall,facing=south]
setblock -2116 9 -1793 minecraft:polished_deepslate
setblock -2116 10 -1793 minecraft:command_block[facing=south]{Command:"execute as @p[distance=..5] at @s run function ustc_pvp:control/refill",TrackOutput:0b}
setblock -2116 10 -1792 minecraft:stone_button[face=wall,facing=south]
fill -2148 9 -1806 -2112 9 -1806 minecraft:stone_brick_wall
fill -2148 9 -1790 -2112 9 -1790 minecraft:stone_brick_wall
fill -2148 9 -1806 -2148 9 -1790 minecraft:stone_brick_wall
fill -2112 9 -1806 -2112 9 -1790 minecraft:stone_brick_wall
fill -2118 1 -1498 -2102 1 -1482 minecraft:red_terracotta
fill -2118 2 -1498 -2102 6 -1482 minecraft:air
fill -2118 2 -1498 -2118 4 -1482 minecraft:stone_bricks
fill -2118 2 -1498 -2113 4 -1498 minecraft:stone_bricks
fill -2107 2 -1498 -2102 4 -1498 minecraft:stone_bricks
fill -2118 2 -1482 -2113 4 -1482 minecraft:stone_bricks
fill -2107 2 -1482 -2102 4 -1482 minecraft:stone_bricks
setblock -2115 2 -1495 minecraft:polished_deepslate
# 2026-09-25 作者要求：红队基地出生点的 base_menu 命令方块删除（含按钮、说明文字与底座）。
# 这里写成"主动清空"而不是"不再放置"：本函数会被复位流程调用，主动清空能顺带把
# 复原模板里残留的同名方块抹掉。蓝队基地（-1585 3 -1530）同理，作者此前已自行删除。
setblock -2115 3 -1495 minecraft:air
setblock -2115 3 -1494 minecraft:air
setblock -2115 2 -1495 minecraft:air
kill @e[type=text_display,tag=ustc.control,x=-2114.5,y=5,z=-1494.5,distance=..2]
fill -1598 1 -1533 -1582 1 -1517 minecraft:blue_terracotta
fill -1598 2 -1533 -1582 6 -1517 minecraft:air
fill -1582 2 -1533 -1582 4 -1517 minecraft:stone_bricks
fill -1598 2 -1533 -1593 4 -1533 minecraft:stone_bricks
fill -1587 2 -1533 -1582 4 -1533 minecraft:stone_bricks
fill -1598 2 -1517 -1593 4 -1517 minecraft:stone_bricks
fill -1587 2 -1517 -1582 4 -1517 minecraft:stone_bricks
setblock -1585 2 -1530 minecraft:polished_deepslate
setblock -1585 3 -1530 minecraft:air
setblock -1585 3 -1529 minecraft:air
setblock -1585 2 -1530 minecraft:air
kill @e[type=text_display,tag=ustc.control,x=-1584.5,y=5,z=-1529.5,distance=..2]
fill -1931 1 -1311 -1929 1 -1309 minecraft:smooth_stone
execute positioned -1930 2 -1310 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1866 1 -1301 -1864 1 -1299 minecraft:smooth_stone
execute positioned -1865 2 -1300 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1791 1 -1301 -1789 1 -1299 minecraft:smooth_stone
execute positioned -1790 2 -1300 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1761 1 -1261 -1759 1 -1259 minecraft:smooth_stone
execute positioned -1760 2 -1260 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1761 1 -1191 -1759 1 -1189 minecraft:smooth_stone
execute positioned -1760 2 -1190 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1836 1 -1181 -1834 1 -1179 minecraft:smooth_stone
execute positioned -1835 2 -1180 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1911 1 -1191 -1909 1 -1189 minecraft:smooth_stone
execute positioned -1910 2 -1190 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1956 1 -1261 -1954 1 -1259 minecraft:smooth_stone
execute positioned -1955 2 -1260 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2016 1 -1511 -2014 1 -1509 minecraft:smooth_stone
execute positioned -2015 2 -1510 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1836 1 -1516 -1834 1 -1514 minecraft:smooth_stone
execute positioned -1835 2 -1515 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1656 1 -1511 -1654 1 -1509 minecraft:smooth_stone
execute positioned -1655 2 -1510 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1661 1 -1681 -1659 1 -1679 minecraft:smooth_stone
execute positioned -1660 2 -1680 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2061 1 -1381 -2059 1 -1379 minecraft:smooth_stone
execute positioned -2060 2 -1380 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1785 1 -1678 -1783 1 -1676 minecraft:smooth_stone
execute positioned -1784 2 -1677 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1827 1 -1650 -1825 1 -1648 minecraft:smooth_stone
execute positioned -1826 2 -1649 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1603 1 -1650 -1601 1 -1648 minecraft:smooth_stone
execute positioned -1602 2 -1649 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1785 1 -1622 -1783 1 -1620 minecraft:smooth_stone
execute positioned -1784 2 -1621 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1939 1 -1594 -1937 1 -1592 minecraft:smooth_stone
execute positioned -1938 2 -1593 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1603 1 -1594 -1601 1 -1592 minecraft:smooth_stone
execute positioned -1602 2 -1593 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1869 1 -1566 -1867 1 -1564 minecraft:smooth_stone
execute positioned -1868 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1729 1 -1566 -1727 1 -1564 minecraft:smooth_stone
execute positioned -1728 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1645 1 -1566 -1643 1 -1564 minecraft:smooth_stone
execute positioned -1644 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1939 1 -1538 -1937 1 -1536 minecraft:smooth_stone
execute positioned -1938 2 -1537 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1659 1 -1538 -1657 1 -1536 minecraft:smooth_stone
execute positioned -1658 2 -1537 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1869 1 -1510 -1867 1 -1508 minecraft:smooth_stone
execute positioned -1868 2 -1509 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1771 1 -1482 -1769 1 -1480 minecraft:smooth_stone
execute positioned -1770 2 -1481 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2079 1 -1426 -2077 1 -1424 minecraft:smooth_stone
execute positioned -2078 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1995 1 -1426 -1993 1 -1424 minecraft:smooth_stone
execute positioned -1994 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1911 1 -1426 -1909 1 -1424 minecraft:smooth_stone
execute positioned -1910 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1827 1 -1426 -1825 1 -1424 minecraft:smooth_stone
execute positioned -1826 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1743 1 -1426 -1741 1 -1424 minecraft:smooth_stone
execute positioned -1742 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1659 1 -1426 -1657 1 -1424 minecraft:smooth_stone
execute positioned -1658 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2116 1 -1403 -2114 1 -1401 minecraft:smooth_stone
execute positioned -2115 2 -1402 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2037 1 -1398 -2035 1 -1396 minecraft:smooth_stone
execute positioned -2036 2 -1397 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1953 1 -1398 -1951 1 -1396 minecraft:smooth_stone
execute positioned -1952 2 -1397 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1869 1 -1398 -1867 1 -1396 minecraft:smooth_stone
execute positioned -1868 2 -1397 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1785 1 -1398 -1783 1 -1396 minecraft:smooth_stone
execute positioned -1784 2 -1397 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1696 1 -1403 -1694 1 -1401 minecraft:smooth_stone
execute positioned -1695 2 -1402 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1612 1 -1403 -1610 1 -1401 minecraft:smooth_stone
execute positioned -1611 2 -1402 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1995 1 -1370 -1993 1 -1368 minecraft:smooth_stone
execute positioned -1994 2 -1369 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2065 1 -1342 -2063 1 -1340 minecraft:smooth_stone
execute positioned -2064 2 -1341 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1953 1 -1342 -1951 1 -1340 minecraft:smooth_stone
execute positioned -1952 2 -1341 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2051 1 -1314 -2049 1 -1312 minecraft:smooth_stone
execute positioned -2050 2 -1313 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2065 1 -1286 -2063 1 -1284 minecraft:smooth_stone
execute positioned -2064 2 -1285 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1934 1 -1263 -1932 1 -1261 minecraft:smooth_stone
execute positioned -1933 2 -1262 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1939 1 -1202 -1937 1 -1200 minecraft:smooth_stone
execute positioned -1938 2 -1201 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1883 1 -1650 -1881 1 -1648 minecraft:smooth_stone
execute positioned -1882 2 -1649 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1855 1 -1650 -1853 1 -1648 minecraft:smooth_stone
execute positioned -1854 2 -1649 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1743 1 -1650 -1741 1 -1648 minecraft:smooth_stone
execute positioned -1742 2 -1649 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1659 1 -1650 -1657 1 -1648 minecraft:smooth_stone
execute positioned -1658 2 -1649 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1925 1 -1622 -1923 1 -1620 minecraft:smooth_stone
execute positioned -1924 2 -1621 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1808 1 -1627 -1806 1 -1625 minecraft:smooth_stone
execute positioned -1807 2 -1626 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1729 1 -1632 -1727 1 -1630 minecraft:smooth_stone
execute positioned -1728 2 -1631 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1967 1 -1594 -1965 1 -1592 minecraft:smooth_stone
execute positioned -1966 2 -1593 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1799 1 -1594 -1797 1 -1592 minecraft:smooth_stone
execute positioned -1798 2 -1593 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1743 1 -1594 -1741 1 -1592 minecraft:smooth_stone
execute positioned -1742 2 -1593 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2009 1 -1566 -2007 1 -1564 minecraft:smooth_stone
execute positioned -2008 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1981 1 -1566 -1979 1 -1564 minecraft:smooth_stone
execute positioned -1980 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1813 1 -1566 -1811 1 -1564 minecraft:smooth_stone
execute positioned -1812 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1785 1 -1566 -1783 1 -1564 minecraft:smooth_stone
execute positioned -1784 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1701 1 -1566 -1699 1 -1564 minecraft:smooth_stone
execute positioned -1700 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1673 1 -1566 -1671 1 -1564 minecraft:smooth_stone
execute positioned -1672 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1617 1 -1566 -1615 1 -1564 minecraft:smooth_stone
execute positioned -1616 2 -1565 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1967 1 -1538 -1965 1 -1536 minecraft:smooth_stone
execute positioned -1966 2 -1537 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1771 1 -1538 -1769 1 -1536 minecraft:smooth_stone
execute positioned -1770 2 -1537 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1743 1 -1538 -1741 1 -1536 minecraft:smooth_stone
execute positioned -1742 2 -1537 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1603 1 -1538 -1601 1 -1536 minecraft:smooth_stone
execute positioned -1602 2 -1537 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2093 1 -1510 -2091 1 -1508 minecraft:smooth_stone
execute positioned -2092 2 -1509 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1813 1 -1510 -1811 1 -1508 minecraft:smooth_stone
execute positioned -1812 2 -1509 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1678 1 -1515 -1676 1 -1513 minecraft:smooth_stone
execute positioned -1677 2 -1514 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1612 1 -1515 -1610 1 -1513 minecraft:smooth_stone
execute positioned -1611 2 -1514 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1939 1 -1482 -1937 1 -1480 minecraft:smooth_stone
execute positioned -1938 2 -1481 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1603 1 -1482 -1601 1 -1480 minecraft:smooth_stone
execute positioned -1602 2 -1481 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2093 1 -1454 -2091 1 -1452 minecraft:smooth_stone
execute positioned -2092 2 -1453 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2051 1 -1426 -2049 1 -1424 minecraft:smooth_stone
execute positioned -2050 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -2023 1 -1426 -2021 1 -1424 minecraft:smooth_stone
execute positioned -2022 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1967 1 -1426 -1965 1 -1424 minecraft:smooth_stone
execute positioned -1966 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1939 1 -1426 -1937 1 -1424 minecraft:smooth_stone
execute positioned -1938 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1883 1 -1426 -1881 1 -1424 minecraft:smooth_stone
execute positioned -1882 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1855 1 -1426 -1853 1 -1424 minecraft:smooth_stone
execute positioned -1854 2 -1425 unless block ~ ~ ~ minecraft:trapped_chest run function ustc_pvp:protection/cache
fill -1991 28 -1536 -1989 29 -1534 minecraft:air
fill -1991 26 -1536 -1989 26 -1534 minecraft:iron_block
setblock -1990 27 -1535 minecraft:beacon
setblock -1990 28 -1535 minecraft:white_stained_glass
setblock -1981 27 -1535 minecraft:cut_copper
setblock -1982 27 -1532 minecraft:cut_copper
setblock -1984 27 -1529 minecraft:cut_copper
setblock -1987 27 -1527 minecraft:cut_copper
setblock -1990 27 -1526 minecraft:cut_copper
setblock -1993 27 -1527 minecraft:cut_copper
setblock -1996 27 -1529 minecraft:cut_copper
setblock -1998 27 -1532 minecraft:cut_copper
setblock -1999 27 -1535 minecraft:cut_copper
setblock -1998 27 -1538 minecraft:cut_copper
setblock -1996 27 -1541 minecraft:cut_copper
setblock -1993 27 -1543 minecraft:cut_copper
setblock -1990 27 -1544 minecraft:cut_copper
setblock -1987 27 -1543 minecraft:cut_copper
setblock -1984 27 -1541 minecraft:cut_copper
setblock -1982 27 -1538 minecraft:cut_copper
fill -1986 28 -1531 -1986 32 -1531 minecraft:polished_blackstone_wall
fill -1985 31 -1531 -1984 32 -1531 minecraft:white_wool
fill -1858 2 -1542 -1856 3 -1540 minecraft:air
fill -1858 0 -1542 -1856 0 -1540 minecraft:iron_block
setblock -1857 1 -1541 minecraft:beacon
setblock -1857 2 -1541 minecraft:white_stained_glass
setblock -1848 1 -1541 minecraft:cut_copper
setblock -1849 1 -1538 minecraft:cut_copper
setblock -1851 1 -1535 minecraft:cut_copper
setblock -1854 1 -1533 minecraft:cut_copper
setblock -1857 1 -1532 minecraft:cut_copper
setblock -1860 1 -1533 minecraft:cut_copper
setblock -1863 1 -1535 minecraft:cut_copper
setblock -1865 1 -1538 minecraft:cut_copper
setblock -1866 1 -1541 minecraft:cut_copper
setblock -1865 1 -1544 minecraft:cut_copper
setblock -1863 1 -1547 minecraft:cut_copper
setblock -1860 1 -1549 minecraft:cut_copper
setblock -1857 1 -1550 minecraft:cut_copper
setblock -1854 1 -1549 minecraft:cut_copper
setblock -1851 1 -1547 minecraft:cut_copper
setblock -1849 1 -1544 minecraft:cut_copper
fill -1853 2 -1537 -1853 6 -1537 minecraft:polished_blackstone_wall
fill -1852 5 -1537 -1851 6 -1537 minecraft:white_wool
fill -1711 29 -1536 -1709 30 -1534 minecraft:air
fill -1711 27 -1536 -1709 27 -1534 minecraft:iron_block
setblock -1710 28 -1535 minecraft:beacon
setblock -1710 29 -1535 minecraft:white_stained_glass
setblock -1701 28 -1535 minecraft:cut_copper
setblock -1702 28 -1532 minecraft:cut_copper
setblock -1704 28 -1529 minecraft:cut_copper
setblock -1707 28 -1527 minecraft:cut_copper
setblock -1710 28 -1526 minecraft:cut_copper
setblock -1713 28 -1527 minecraft:cut_copper
setblock -1716 28 -1529 minecraft:cut_copper
setblock -1718 28 -1532 minecraft:cut_copper
setblock -1719 28 -1535 minecraft:cut_copper
setblock -1718 28 -1538 minecraft:cut_copper
setblock -1716 28 -1541 minecraft:cut_copper
setblock -1713 28 -1543 minecraft:cut_copper
setblock -1710 28 -1544 minecraft:cut_copper
setblock -1707 28 -1543 minecraft:cut_copper
setblock -1704 28 -1541 minecraft:cut_copper
setblock -1702 28 -1538 minecraft:cut_copper
fill -1706 29 -1531 -1706 33 -1531 minecraft:polished_blackstone_wall
fill -1705 32 -1531 -1704 33 -1531 minecraft:white_wool
fill -1677 2 -1661 -1675 3 -1659 minecraft:air
fill -1677 0 -1661 -1675 0 -1659 minecraft:iron_block
setblock -1676 1 -1660 minecraft:beacon
setblock -1676 2 -1660 minecraft:white_stained_glass
setblock -1667 1 -1660 minecraft:cut_copper
setblock -1668 1 -1657 minecraft:cut_copper
setblock -1670 1 -1654 minecraft:cut_copper
setblock -1673 1 -1652 minecraft:cut_copper
setblock -1676 1 -1651 minecraft:cut_copper
setblock -1679 1 -1652 minecraft:cut_copper
setblock -1682 1 -1654 minecraft:cut_copper
setblock -1684 1 -1657 minecraft:cut_copper
setblock -1685 1 -1660 minecraft:cut_copper
setblock -1684 1 -1663 minecraft:cut_copper
setblock -1682 1 -1666 minecraft:cut_copper
setblock -1679 1 -1668 minecraft:cut_copper
setblock -1676 1 -1669 minecraft:cut_copper
setblock -1673 1 -1668 minecraft:cut_copper
setblock -1670 1 -1666 minecraft:cut_copper
setblock -1668 1 -1663 minecraft:cut_copper
fill -1672 2 -1656 -1672 6 -1656 minecraft:polished_blackstone_wall
fill -1671 5 -1656 -1670 6 -1656 minecraft:white_wool
fill -2081 2 -1379 -2079 3 -1377 minecraft:air
fill -2081 0 -1379 -2079 0 -1377 minecraft:iron_block
setblock -2080 1 -1378 minecraft:beacon
setblock -2080 2 -1378 minecraft:white_stained_glass
setblock -2071 1 -1378 minecraft:cut_copper
setblock -2072 1 -1375 minecraft:cut_copper
setblock -2074 1 -1372 minecraft:cut_copper
setblock -2077 1 -1370 minecraft:cut_copper
setblock -2080 1 -1369 minecraft:cut_copper
setblock -2083 1 -1370 minecraft:cut_copper
setblock -2086 1 -1372 minecraft:cut_copper
setblock -2088 1 -1375 minecraft:cut_copper
setblock -2089 1 -1378 minecraft:cut_copper
setblock -2088 1 -1381 minecraft:cut_copper
setblock -2086 1 -1384 minecraft:cut_copper
setblock -2083 1 -1386 minecraft:cut_copper
setblock -2080 1 -1387 minecraft:cut_copper
setblock -2077 1 -1386 minecraft:cut_copper
setblock -2074 1 -1384 minecraft:cut_copper
setblock -2072 1 -1381 minecraft:cut_copper
fill -2076 2 -1374 -2076 6 -1374 minecraft:polished_blackstone_wall
fill -2075 5 -1374 -2074 6 -1374 minecraft:white_wool
scoreboard players set #protection.active ustc.clock 1
scoreboard players set #protection.edit ustc.clock 0
