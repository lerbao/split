# 每隔随机10~15秒向上滑动一次，坐标和持续时间也随机，按 Ctrl+C 停止
$intervals = @(10, 11, 12, 13, 14, 15)

Write-Host "开始循环滑动(全随机参数)，间隔 10~15s，按 Ctrl+C 停止..." -ForegroundColor Green

$count = 0
while ($true) {
    $count++
    $x1 = Get-Random -Minimum 480 -Maximum 600       # 起始X: 480~599
    $y1 = Get-Random -Minimum 1900 -Maximum 2300     # 起始Y: 1900~2299
    $x2 = Get-Random -Minimum 480 -Maximum 600       # 终点X: 480~599
    $y2 = Get-Random -Minimum 100 -Maximum 500        # 终点Y: 100~499
    $dur = Get-Random -Minimum 300 -Maximum 800       # 滑动持续时间: 300~799ms
    $delay = Get-Random -InputObject $intervals

    Write-Host "[$count] $(Get-Date -Format 'HH:mm:ss') swipe ($x1,$y1)->($x2,$y2) ${dur}ms | 间隔 ${delay}s"
    adb shell input swipe $x1 $y1 $x2 $y2 $dur
    Start-Sleep -Seconds $delay
}