# pvpshot 模组构建脚本
#
# 用法：
#   .\build.ps1 build        构建（产出 build\libs\pvpshot-<版本>.jar）
#   .\build.ps1 runServer    启动开发用服务端（首次需自行接受 EULA）
#
# 说明：本机 JDK 25 / Gradle 9.7.1 固定安装在下面两个路径，
#       换机器时改这两行即可。
$ErrorActionPreference = 'Stop'

$env:JAVA_HOME = 'C:\Users\Lenovo\AppData\Local\Programs\Microsoft\jdk-25.0.2.10-hotspot'
$gradleBin     = 'D:\MC\MidAutumnMiniGame\.tools\gradle-9.7.1\bin\gradle.bat'
$gradleHome    = 'D:\MC\MidAutumnMiniGame\.gradle-home'

if (-not (Test-Path -LiteralPath $gradleBin)) {
    throw "找不到 Gradle：$gradleBin（应解压在 .tools\gradle-9.7.1）"
}
if (-not (Test-Path -LiteralPath "$env:JAVA_HOME\bin\java.exe")) {
    throw "找不到 JDK 25：$env:JAVA_HOME"
}

$task = if ($args.Count -gt 0) { $args } else { @('build') }
Write-Output "[build.ps1] 任务：$($task -join ' ')"
& $gradleBin -g $gradleHome --console=plain @task
exit $LASTEXITCODE
