# 生成"服务端本体"部署包（给 Linux 服务器用）
#
# 用法：powershell -NoProfile -ExecutionPolicy Bypass -File tools\server-package\make-server-package.ps1
#
# 产出：
#   dist\服务端部署包-linux\            （可直接 scp 到服务器上跑的目录树）
#   dist\服务端部署包-linux-26.2.zip    （同内容的压缩包，方便传输）
#
# 说明：
#   * 只带"跑服必需"的东西：启动器 + 依赖库 + 官方服务端版本 + 模组 + 配置 + 世界 + 资源包 + Linux 脚本与说明
#   * 不带走：旧地图 world/、玩家客户端缓存 world-ustc/voxy/、日志、crash-reports、.fabric 缓存、
#             单文件模组备份 mods-standalone-backup/
#   * server.properties 会被就地改三处：清空 resource-pack*（换成朋友自己的地址）、
#     关闭 RCON（避免把已知密码带到公网）、保留其余设置

param(
    [string]$Version = '26.2'
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$src  = Join-Path $repo 'server'
$out  = Join-Path $repo "dist\服务端部署包-linux"
$zip  = Join-Path $repo "dist\服务端部署包-linux-$Version.zip"
$tools = $PSScriptRoot

if (-not (Test-Path -LiteralPath $src)) { throw "找不到服务端目录：$src" }

Write-Host "[服务端包] 目标：$out"
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Recurse -Force }
New-Item -ItemType Directory -Force -Path $out | Out-Null

function Copy-Item2($rel) {
    $from = Join-Path $src $rel
    if (-not (Test-Path -LiteralPath $from)) { throw "缺少：$from" }
    $to = Join-Path $out $rel
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $to) | Out-Null
    Copy-Item -LiteralPath $from -Destination $to -Recurse -Force
}

# 1) 开服必需：启动器、依赖库、官方服务端版本、模组、配置、外置登录库、资源包
foreach ($rel in 'fabric-server-launch.jar', 'libraries', 'versions', 'mods', 'config',
                 'authlib-injector-1.2.8.jar', 'pvpshot-waypoints.zip',
                 'eula.txt', 'server.properties', 'ops.json', 'whitelist.json',
                 'banned-ips.json', 'banned-players.json') {
    Copy-Item2 $rel
}

# 2) 世界（含数据包与复原模板维度）：用 robocopy 排除客户端缓存与旧地图
$worldSrc = Join-Path $src 'world-ustc'
$worldDst = Join-Path $out 'world-ustc'
New-Item -ItemType Directory -Force -Path $worldDst | Out-Null
$robo = robocopy $worldSrc $worldDst /E /XD voxy serenitea_pot syncmatica /XF session.lock /NFL /NDL /NJH /NJS /NP
if ($LASTEXITCODE -ge 8) { throw "robocopy 失败，退出码 $LASTEXITCODE" }
Write-Host ("[服务端包] world-ustc 复制完成（robocopy 退出码 {0}）" -f $LASTEXITCODE)

# 3) Linux 脚本与说明
foreach ($f in 'start.sh', 'start-resourcepack-http.sh', 'README-部署.md') {
    Copy-Item -LiteralPath (Join-Path $tools $f) -Destination (Join-Path $out $f) -Force
}

# 4) 就地调整 server.properties：清空资源包地址、关掉 RCON
$propsPath = Join-Path $out 'server.properties'
$text = Get-Content -LiteralPath $propsPath -Raw -Encoding UTF8
$text = [regex]::Replace($text, '(?m)^resource-pack=.*$',           'resource-pack=')
$text = [regex]::Replace($text, '(?m)^resource-pack-sha1=.*$',      'resource-pack-sha1=')
$text = [regex]::Replace($text, '(?m)^resource-pack-prompt=.*$',    'resource-pack-prompt=')
$text = [regex]::Replace($text, '(?m)^resource-pack-id=.*$',        'resource-pack-id=')
$text = [regex]::Replace($text, '(?m)^enable-rcon=.*$',             'enable-rcon=false')
$text = [regex]::Replace($text, '(?m)^rcon.password=.*$',           'rcon.password=')
Set-Content -LiteralPath $propsPath -Value $text -Encoding UTF8 -NoNewline

# 5) 打包
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($out, $zip, [System.IO.Compression.CompressionLevel]::Optimal, $true)

$files = Get-ChildItem -LiteralPath $out -Recurse -File
$bytes = ($files | Measure-Object Length -Sum).Sum
Write-Host ("[服务端包] 完成：{0} 个文件 / {1:N1} MB（未压缩）" -f $files.Count, ($bytes / 1MB))
Write-Host ("[服务端包] zip：{0}（{1:N1} MB）" -f $zip, ((Get-Item -LiteralPath $zip).Length / 1MB))
Get-ChildItem -LiteralPath $out | Select-Object Mode, Name, Length | Format-Table -AutoSize
