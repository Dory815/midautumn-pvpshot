@echo off
chcp 65001 >nul
cd /d "%~dp0"
set "PVPJAVA=%PVPSHOT_JAVA%"
if not defined PVPJAVA if defined JAVA_HOME set "PVPJAVA=%JAVA_HOME%\bin\java.exe"
if not defined PVPJAVA set "PVPJAVA=java"
"%PVPJAVA%" -version 2>java-check.tmp
findstr /C:"version \"25." java-check.tmp >nul
if errorlevel 1 (
  type java-check.tmp
  del java-check.tmp
  echo 需要 Java 25；可设置 PVPSHOT_JAVA 为 java.exe 的完整路径。
  pause
  exit /b 1
)
del java-check.tmp
findstr /X "eula=true" eula.txt >nul
if errorlevel 1 (
  echo 请阅读 https://aka.ms/MinecraftEULA，同意后自行将 eula.txt 改为 eula=true。
  pause
  exit /b 1
)
if not defined PVPSHOT_MAX_MEMORY set "PVPSHOT_MAX_MEMORY=4G"
if exist protection-required.txt goto protected
if exist protection\pvpshot-protection-26.2.jar goto protected
"%PVPJAVA%" -Xms512M -Xmx%PVPSHOT_MAX_MEMORY% -jar server.jar nogui
goto finished
:protected
for %%F in (pvpshot-protection-26.2.jar pvpshot-protection-runtime-26.2.jar regions.tsv) do (
  if not exist protection\%%F (
    echo 设施保护模块缺少文件：protection\%%F
    pause
    exit /b 1
  )
)
"%PVPJAVA%" -Xms512M -Xmx%PVPSHOT_MAX_MEMORY% "-Dpvpshot.protection.server=server.jar" "-javaagent:protection/pvpshot-protection-26.2.jar=protection/regions.tsv" -jar server.jar nogui
:finished
pause
