# 生成发行包：docs/发行包-<版本>/ 与 docs/发行包-<版本>.zip
#
# 用法（在仓库任意位置）：
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\package-release.ps1
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\package-release.ps1 -Version 1.0.0-m1
#
# 说明：发行包只做"搬运与汇总"，不参与构建；jar 请先跑 mod\build.ps1 build。

param(
    [string]$Version = '1.0.0-m1'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$name = "发行包-$Version"
$out = Join-Path $root "docs\$name"
$zip = Join-Path $root "docs\$name.zip"

function Copy-One($from, $toFile) {
    if (-not (Test-Path -LiteralPath $from)) {
        throw "缺少文件：$from（先构建模组、生成资源包）"
    }
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $toFile) | Out-Null
    Copy-Item -LiteralPath $from -Destination $toFile -Force
}

Write-Host "[发行包] 版本 $Version → $out"
if (Test-Path -LiteralPath $out) { Remove-Item -LiteralPath $out -Recurse -Force }
New-Item -ItemType Directory -Force -Path $out | Out-Null

# 1. 产物：模组 jar、资源包
Copy-One (Join-Path $root "mod\build\libs\pvpshot-$Version.jar") (Join-Path $out "模组\pvpshot-$Version.jar")
Copy-One (Join-Path $root 'server\pvpshot-waypoints.zip') (Join-Path $out '资源包\pvpshot-waypoints.zip')

# 2. 数据包补丁（含说明）
Copy-One (Join-Path $root 'tools\datapack-patches\README.md') (Join-Path $out '数据包补丁\README.md')
foreach ($f in 'red', 'blue') {
    Copy-One (Join-Path $root "tools\datapack-patches\ustc_pvp\respawn\$f.mcfunction") `
             (Join-Path $out "数据包补丁\ustc_pvp\respawn\$f.mcfunction")
}

# 3. 文档
Copy-One (Join-Path $root 'docs\更新日志.md') (Join-Path $out '文档\更新日志.md')
Copy-One (Join-Path $root 'specs\PRD.md') (Join-Path $out '文档\PRD.md')
Copy-One (Join-Path $root 'specs\SPEC.md') (Join-Path $out '文档\SPEC.md')
Copy-One (Join-Path $root 'docs\反编译说明.md') (Join-Path $out '文档\反编译说明.md')
Copy-One (Join-Path $root 'mod\README.md') (Join-Path $out '文档\模组README.md')
Copy-One (Join-Path $root 'server\README.md') (Join-Path $out '文档\服务端README.md')
Copy-One (Join-Path $root 'tools\release\安装说明.md') (Join-Path $out '安装说明.md')

# 3b. 压测工具（脚本 + 生成的函数）
Copy-One (Join-Path $root 'tools\stress\make_stress_pack.py') (Join-Path $out '压测工具\make_stress_pack.py')
Copy-One (Join-Path $root 'tools\stress\extract-mspt.py') (Join-Path $out '压测工具\extract-mspt.py')
Copy-One (Join-Path $root 'tools\stress\plot-mspt.ps1') (Join-Path $out '压测工具\plot-mspt.ps1')
$stressFn = Join-Path $root 'server\world\datapacks\pvpshot-stress\data\pvpshot_stress\function'
foreach ($f in 'all', 'clear', 'place_kit', 'place_selftest') {
    Copy-One (Join-Path $stressFn "$f.mcfunction") (Join-Path $out "压测工具\pvpshot_stress\$f.mcfunction")
}
Copy-One (Join-Path $root 'server\world\datapacks\pvpshot-stress\pack.mcmeta') `
         (Join-Path $out '压测工具\pvpshot_stress\pack.mcmeta')

# 3c. 已完成的压测报告与曲线（有就带，没有就跳过）
$perfDir = Join-Path $root 'docs\压测'
if (Test-Path -LiteralPath $perfDir) {
    foreach ($f in Get-ChildItem -LiteralPath $perfDir -File) {
        Copy-One $f.FullName (Join-Path $out ('压测报告\' + $f.Name))
    }
}

# 4. 打包成 zip
if (Test-Path -LiteralPath $zip) { Remove-Item -LiteralPath $zip -Force }
Compress-Archive -Path (Join-Path $out '*') -DestinationPath $zip -Force

Write-Host "[发行包] 完成："
Get-ChildItem -Recurse -File $out | ForEach-Object {
    Write-Host ("  {0}  ({1} 字节)" -f $_.FullName.Substring($out.Length + 1), $_.Length)
}
Write-Host ("  zip: {0} ({1} 字节)" -f $zip, (Get-Item -LiteralPath $zip).Length)
