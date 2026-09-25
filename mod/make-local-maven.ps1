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
    @{ File = 'entity_collision_optimizer-1.0.0-mc26.2-alpha.7.jar'; Group = 'local'; Artifact = 'eco';   Version = '1.0.0' }
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
