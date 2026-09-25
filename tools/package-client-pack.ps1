# 打包客户端整合包（作者要求：必须带上多人游戏列表、各模组配置、小地图与 Voxy 数据）
#
# 用法：
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\package-client-pack.ps1
#   powershell ... -File tools\package-client-pack.ps1 -Source "D:\...\versions\另一个实例"
#
# 输出：<仓库>\dist\中秋校园枪战小游戏-客户端整合包.zip

param(
    [string]$Source = 'D:\MC\PCL 正式版 2.10.6\.minecraft\versions\中秋校园枪战小游戏',
    [string]$OutDir = 'D:\MC\MidAutumnMiniGame\dist',
    [string]$Name   = '中秋校园枪战小游戏-客户端整合包',
    [string]$Readme = 'D:\MC\MidAutumnMiniGame\tools\client-pack\README-安装说明.md'
)

$ErrorActionPreference = 'Stop'

# 要打进包的条目（相对实例目录）。
# 说明：为什么带 .voxy / xaero / config / servers.dat / options.txt —— 按作者要求保留
# 多人列表、模组配置、小地图与 Voxy 数据，玩家解压后开箱即用。
$include = @(
    'mods',
    'config',
    'xaero',
    '.voxy',
    'shaderpacks',
    'resourcepacks',
    'options.txt',
    'servers.dat',
    '中秋校园枪战小游戏.json'
)
# 明确不带：客户端主程序 jar（启动器自己下）、natives（启动时解压）、.fabric（重映射缓存）、
# logs / .mixin.out / downloads / data / saves / usercache.json（运行产物）、
# PCL/（启动器私有配置）、servers.dat_old、command_history.txt、authlib-injector.log。

if (-not (Test-Path -LiteralPath $Source)) { throw "找不到客户端实例：$Source" }

$staging = Join-Path $env:TEMP ("client-pack-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $staging | Out-Null

foreach ($item in $include) {
    $src = Join-Path $Source $item
    if (-not (Test-Path -LiteralPath $src)) {
        Write-Warning "实例里没有 $item，跳过"
        continue
    }
    $dst = Join-Path $staging $item
    if ((Get-Item -LiteralPath $src).PSIsContainer) {
        Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
    } else {
        Copy-Item -LiteralPath $src -Destination $dst -Force
    }
    Write-Host "[pack] + $item"
}

if (Test-Path -LiteralPath $Readme) {
    Copy-Item -LiteralPath $Readme -Destination (Join-Path $staging 'README-安装说明.md') -Force
    Write-Host "[pack] + README-安装说明.md"
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$zip = Join-Path $OutDir "$Name.zip"
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }

# 用 .NET 的 ZipFile：Compress-Archive 用通配符时会跳过隐藏项，而 .voxy 是隐藏目录。
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $staging, $zip, [System.IO.Compression.CompressionLevel]::Optimal, $false)

Remove-Item -LiteralPath $staging -Recurse -Force

$size = (Get-Item -LiteralPath $zip).Length / 1MB
Write-Host ("[pack] 完成：{0}（{1:N1} MB）" -f $zip, $size)

# 列一下 zip 顶层条目，便于核对（尤其是 .voxy / servers.dat 有没有进去）
$archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
try {
    $top = $archive.Entries | ForEach-Object { ($_.FullName -split '/')[0] } | Sort-Object -Unique
    Write-Host ('[pack] 顶层条目：' + ($top -join ', '))
} finally {
    $archive.Dispose()
}
