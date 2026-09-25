# 把 libs/ 里的第三方模组 jar 布置成本地 Maven 仓库，供 build.gradle 用
# `include "local:<artifact>:<version>"` 正经地嵌套进 pvpshot.jar。
#
# 为什么要绕这一圈：Loom 的 include 只接受"有 capabilities 的模块"，
# 直接 include files("libs/x.jar") 会报
#   "Attempted to nest artifact ... which is not a module component and has no capabilities"。
#
# 用法（改过 libs/ 里的 jar 之后跑一次）：
#   powershell -NoProfile -ExecutionPolicy Bypass -File mod\make-local-maven.ps1

$ErrorActionPreference = 'Stop'
$libs = Join-Path $PSScriptRoot 'libs'
$repo = Join-Path $libs 'repo'

# jar 文件名 → (groupId, artifactId, version)
$map = @(
    @{ File = 'fabric-carpet-26.2+v260616.jar';                     Group = 'local'; Artifact = 'carpet'; Version = '26.2' },
    @{ File = 'spark-1.10.187-fabric.jar';                          Group = 'local'; Artifact = 'spark';  Version = '1.10.187' },
    @{ File = 'entity_collision_optimizer-1.0.0-mc26.2-alpha.7.jar'; Group = 'local'; Artifact = 'eco';   Version = '1.0.0' },
    # 下面 5 个是从作者客户端 instances\中秋校园枪战小游戏\mods 里原样复制的同版本模组，
    # 它们都是 env=* （带服务端组件），装到服务端才能让客户端那半边功能完整：
    #   铁氧体磁芯   = 方块状态/模型内存优化（服务端同样受益，实测省内存）
    #   苹果皮       = 饥饿/饱和度 HUD 的服务端数据同步
    #   Xaero 小地图 / 世界地图 = 地图与航点共享的服务端支持
    #   文本占位符 API = Xaero 在服务端侧用到的库
    @{ File = 'ferritecore-9.0.0-fabric.jar';              Group = 'local'; Artifact = 'ferritecore';    Version = '9.0.0' },
    @{ File = 'appleskin-fabric-mc26.2-3.0.10.jar';        Group = 'local'; Artifact = 'appleskin';      Version = '3.0.10' },
    @{ File = 'xaerominimap-fabric-26.2-26.5.1.jar';       Group = 'local'; Artifact = 'xaerominimap';   Version = '26.5.1' },
    @{ File = 'xaeroworldmap-fabric-26.2-1.46.1.jar';      Group = 'local'; Artifact = 'xaeroworldmap';  Version = '1.46.1' },
    @{ File = 'placeholder-api-3.1.0-beta.1+26.2.jar';     Group = 'local'; Artifact = 'placeholderapi'; Version = '3.1.0-beta.1' }
)

foreach ($m in $map) {
    $src = Join-Path $libs $m.File
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "缺少 $src（按 mod/README.md 的地址下载后放到 mod\libs\）"
        continue
    }
    $dir = Join-Path $repo "$($m.Group)\$($m.Artifact)\$($m.Version)"
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    Copy-Item -LiteralPath $src -Destination (Join-Path $dir "$($m.Artifact)-$($m.Version).jar") -Force
    $pom = @"
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
  <modelVersion>4.0.0</modelVersion>
  <groupId>$($m.Group)</groupId>
  <artifactId>$($m.Artifact)</artifactId>
  <version>$($m.Version)</version>
  <packaging>jar</packaging>
</project>
"@
    Set-Content -LiteralPath (Join-Path $dir "$($m.Artifact)-$($m.Version).pom") -Value $pom -Encoding UTF8
    Write-Output "[local-maven] $($m.Group):$($m.Artifact):$($m.Version)  <=  $($m.File)"
}
