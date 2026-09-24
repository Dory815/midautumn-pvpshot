# 把逐 tick 的 MSPT 采样画成曲线图（纯 .NET GDI+，不需要额外装 Python 包）。
#
# 用法：
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools\stress\plot-mspt.ps1 `
#       -Csv docs\压测\xxx.csv -Out docs\压测\xxx.png -Title "投掷物齐射"
#
# CSV 两列：tick 序号, MSPT（毫秒），无表头。

param(
    [Parameter(Mandatory = $true)][string]$Csv,
    [Parameter(Mandatory = $true)][string]$Out,
    [string]$Title = 'MSPT',
    [double]$BudgetMs = 50.0,
    [double]$YMax = 0        # > 0 时把纵轴截断到这个值，便于看清稳态（超出的极值点会被顶到上边并标注真实值）
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$rows = @()
foreach ($line in Get-Content -LiteralPath $Csv -Encoding UTF8) {
    $t = $line.Trim()
    if ($t -eq '' -or $t.StartsWith('#')) { continue }
    $p = $t -split '[,;\s]+'
    $rows += [pscustomobject]@{ Tick = [double]$p[0]; Ms = [double]$p[1] }
}
if ($rows.Count -lt 2) { throw "CSV 里没有足够的数据点：$Csv" }

$values = $rows | ForEach-Object { $_.Ms }
$minV = ($values | Measure-Object -Minimum).Minimum
$maxV = ($values | Measure-Object -Maximum).Maximum
$avgV = ($values | Measure-Object -Average).Average
$sorted = $values | Sort-Object
$p95 = $sorted[[math]::Min($sorted.Count - 1, [int][math]::Floor($sorted.Count * 0.95))]
$maxRow = $rows | Sort-Object Ms -Descending | Select-Object -First 1
$minRow = $rows | Sort-Object Ms | Select-Object -First 1

# 画布与边距
$W = 1400; $H = 720
$left = 90; $right = 40; $top = 70; $bottom = 70
$plotW = $W - $left - $right
$plotH = $H - $top - $bottom

# Y 轴范围：0 .. max(预算线, 数据最大值) 上浮 10%
$yTop = [math]::Max($BudgetMs, $maxV) * 1.10
if ($YMax -gt 0) { $yTop = $YMax }
if ($yTop -le 0) { $yTop = 1 }

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.Clear([System.Drawing.Color]::White)

$fontTitle = New-Object System.Drawing.Font('Microsoft YaHei', 16, [System.Drawing.FontStyle]::Bold)
$fontAxis = New-Object System.Drawing.Font('Microsoft YaHei', 11)
$fontSmall = New-Object System.Drawing.Font('Microsoft YaHei', 10)
$brushText = [System.Drawing.Brushes]::Black
$brushGray = [System.Drawing.Brushes]::DimGray
$penAxis = New-Object System.Drawing.Pen([System.Drawing.Color]::Black, 1.5)
$penGrid = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 230, 230), 1)
$penCurve = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(30, 110, 220), 2.2)
$penBudget = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(220, 60, 60), 1.8)
$penBudget.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$brushMax = [System.Drawing.Brushes]::Crimson
$brushMin = [System.Drawing.Brushes]::SeaGreen

function Map-X([double]$tick) {
    return $left + ($tick - $rows[0].Tick) / ($rows[-1].Tick - $rows[0].Tick) * $plotW
}
function Map-Y([double]$ms) {
    $v = [math]::Min([math]::Max($ms, 0), $yTop)
    return $top + $plotH - ($v / $yTop) * $plotH
}

# 网格与 Y 轴刻度
$ySteps = 10
for ($i = 0; $i -le $ySteps; $i++) {
    $ms = $yTop * $i / $ySteps
    $y = Map-Y $ms
    $g.DrawLine($penGrid, $left, $y, $left + $plotW, $y)
    $label = '{0:0}' -f $ms
    $size = $g.MeasureString($label, $fontSmall)
    $g.DrawString($label, $fontSmall, $brushGray, $left - 8 - $size.Width, $y - $size.Height / 2)
}

# X 轴刻度（每 10 tick 一个刻度，点太多时自动稀疏）
$step = 10
while (($rows[-1].Tick - $rows[0].Tick) / $step -gt 14) { $step *= 2 }
for ($t = [math]::Ceiling($rows[0].Tick / $step) * $step; $t -le $rows[-1].Tick; $t += $step) {
    $x = Map-X $t
    $g.DrawLine($penGrid, $x, $top, $x, $top + $plotH)
    $label = '{0:0}' -f $t
    $size = $g.MeasureString($label, $fontSmall)
    $g.DrawString($label, $fontSmall, $brushGray, $x - $size.Width / 2, $top + $plotH + 6)
}

# 50 ms 预算线（20 TPS 的理论上限）
$budgetY = Map-Y $BudgetMs
$g.DrawLine($penBudget, $left, $budgetY, $left + $plotW, $budgetY)
$g.DrawString(('{0:0} ms 预算线（20 TPS）' -f $BudgetMs), $fontSmall, [System.Drawing.Brushes]::Crimson,
              $left + $plotW - 210, $budgetY - 20)

# 坐标轴
$g.DrawLine($penAxis, $left, $top, $left, $top + $plotH)
$g.DrawLine($penAxis, $left, $top + $plotH, $left + $plotW, $top + $plotH)

# 曲线
$pts = @()
foreach ($r in $rows) { $pts += New-Object System.Drawing.PointF((Map-X $r.Tick), (Map-Y $r.Ms)) }
if ($pts.Count -ge 2) { $g.DrawLines($penCurve, [System.Drawing.PointF[]]$pts) }

# 极值点：最高点（红）与最低点（绿）
foreach ($pt in @(@{ Row = $maxRow; Brush = $brushMax; Tag = '最大值' },
                  @{ Row = $minRow; Brush = $brushMin; Tag = '最小值' })) {
    $x = Map-X $pt.Row.Tick
    $y = Map-Y $pt.Row.Ms
    $g.FillEllipse($pt.Brush, $x - 5, $y - 5, 10, 10)
    $text = ('{0} {1:0.00} ms @ tick {2:0}' -f $pt.Tag, $pt.Row.Ms, $pt.Row.Tick)
    $size = $g.MeasureString($text, $fontSmall)
    $tx = [math]::Min([math]::Max($x + 8, $left), $left + $plotW - $size.Width)
    $ty = [math]::Max($y - 20, $top)
    $g.DrawString($text, $fontSmall, $pt.Brush, $tx, $ty)
}

# 标题与统计
$g.DrawString(('{0} · MSPT 逐 tick 曲线' -f $Title), $fontTitle, $brushText, $left, 18)
$stats = ('样本 {0} tick ｜ 平均 {1:0.00} ms ｜ P95 {2:0.00} ms ｜ 最大 {3:0.00} ms ｜ 最小 {4:0.00} ms' -f `
          $rows.Count, $avgV, $p95, $maxV, $minV)
$g.DrawString($stats, $fontAxis, $brushGray, $left, 45)
$g.DrawString('横轴：tick 序号   纵轴：MSPT（毫秒）', $fontAxis, $brushGray, $left, $top + $plotH + 30)

$dir = Split-Path -Parent $Out
if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
$bmp.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()

Write-Host ("[plot] {0} -> {1}" -f $Csv, $Out)
Write-Host ("[plot] samples={0} avg={1:0.00} p95={2:0.00} max={3:0.00} min={4:0.00}" -f `
            $rows.Count, $avgV, $p95, $maxV, $minV)
