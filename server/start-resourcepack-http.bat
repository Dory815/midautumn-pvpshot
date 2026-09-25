@echo off
rem 资源包下载服务：把 server/ 目录挂在 8080 端口，供客户端自动下载
rem   pvpshot-waypoints.zip（server.properties 里的 resource-pack 指向它）。
rem 用法：双击本文件即可；关掉窗口 = 停服务。日志写到 logs\resourcepack-http.log。
rem 注意：这是普通 python http.server，没有守护/自动重启，掉了就再双击一次。
title PVP Shot Resourcepack HTTP (port 8080)
cd /d "%~dp0"
if not exist "logs" mkdir "logs"
"D:\Programs\Python3_13\python.exe" -m http.server 8080 --bind 0.0.0.0 >> "logs\resourcepack-http.log" 2>&1
