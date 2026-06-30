# 抖音自动刷视频：点赞→收藏→评论，直播自动跳过，按 Ctrl+C 停止
# 右侧按钮坐标（1080x2388基准，脚本内会加随机偏移）
$LIKE_X = 930; $LIKE_Y = 1350        # 点赞(心形图标)
$COMMENT_X = 930; $COMMENT_Y = 1580  # 评论图标
$BOOKMARK_X = 930; $BOOKMARK_Y = 1820 # 收藏图标
$CENTER_X = 540; $CENTER_Y = 1200    # 屏幕中央(双击点赞用)
$COMMENT_INPUT_X = 540; $COMMENT_INPUT_Y = 2280  # 评论输入框
$SEND_X = 980; $SEND_Y = 2280        # 发送按钮

# 评论候选语料
$comments = @(
    "不错",
    "666",
    "太棒了",
    "怎么做到的",
    "可以互相关注吗？"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  抖音自动刷视频 Bot 启动" -ForegroundColor Cyan
Write-Host "  流程: 点赞 -> 2~5s -> 收藏 -> 3~7s -> 评论" -ForegroundColor Cyan
Write-Host "  直播自动检测并跳过" -ForegroundColor Cyan
Write-Host "  按 Ctrl+C 停止" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

function RandomOffset($base, $range) {
    return Get-Random -Minimum ($base - $range) -Maximum ($base + $range + 1)
}

function Swipe-Up {
    $x1 = Get-Random -Minimum 480 -Maximum 600
    $y1 = Get-Random -Minimum 1900 -Maximum 2300
    $x2 = Get-Random -Minimum 480 -Maximum 600
    $y2 = Get-Random -Minimum 100 -Maximum 500
    $dur = Get-Random -Minimum 300 -Maximum 800
    Write-Host "  >> 滑动 ($x1,$y1)->($x2,$y2) ${dur}ms"
    adb shell input swipe $x1 $y1 $x2 $y2 $dur
}

function Is-LiveStream {
    # 通过 uiautomator dump 检测是否有“直播”文字
    try {
        $xml = adb exec-out uiautomator dump /dev/tty 2>$null | Out-String
        if ($xml -match '直播') {
            return $true
        }
    } catch {
        # 如果 dump 失败，保守判断为视频
        return $false
    }
    return $false
}

function Do-Like {
    $x = RandomOffset $CENTER_X 100
    $y = RandomOffset $CENTER_Y 150
    Write-Host "  >> 点赞 (双击 $x,$y)"
    adb shell input tap $x $y
    Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 200)
    adb shell input tap $x $y
}

function Do-Collect {
    $x = RandomOffset $BOOKMARK_X 30
    $y = RandomOffset $BOOKMARK_Y 30
    Write-Host "  >> 收藏 ($x,$y)"
    adb shell input tap $x $y
}

function Do-Comment {
    # 1. 点击评论图标
    $cx = RandomOffset $COMMENT_X 30
    $cy = RandomOffset $COMMENT_Y 30
    Write-Host "  >> 评论 - 点击评论图标 ($cx,$cy)"
    adb shell input tap $cx $cy
    $d1 = Get-Random -Minimum 800 -Maximum 1500
    Start-Sleep -Milliseconds $d1

    # 2. 点击输入框
    $ix = RandomOffset $COMMENT_INPUT_X 100
    $iy = RandomOffset $COMMENT_INPUT_Y 30
    Write-Host "  >> 评论 - 点击输入框 ($ix,$iy)"
    adb shell input tap $ix $iy
    $d2 = Get-Random -Minimum 400 -Maximum 800
    Start-Sleep -Milliseconds $d2

    # 3. 输入随机评论（通过 ADBKeyboard 广播支持中文）
    $text = Get-Random -InputObject $comments
    Write-Host "  >> 评论 - 输入: $text"
    adb shell am broadcast -a ADB_INPUT_TEXT --es msg $text
    $d3 = Get-Random -Minimum 500 -Maximum 1200
    Start-Sleep -Milliseconds $d3

    # 4. 点击发送
    $sx = RandomOffset $SEND_X 30
    $sy = RandomOffset $SEND_Y 30
    Write-Host "  >> 评论 - 发送 ($sx,$sy)"
    adb shell input tap $sx $sy
    $d4 = Get-Random -Minimum 800 -Maximum 1500
    Start-Sleep -Milliseconds $d4

    # 5. 返回视频界面
    adb shell input keyevent BACK
    $d5 = Get-Random -Minimum 400 -Maximum 800
    Start-Sleep -Milliseconds $d5
}

$count = 0
while ($true) {
    $count++
    Write-Host "[$count] $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Yellow

    # 1. 滑动到下一个视频
    Swipe-Up
    $loadWait = Get-Random -Minimum 1 -Maximum 4
    Write-Host "  >> 等待视频加载 ${loadWait}s..."
    Start-Sleep -Seconds $loadWait

    # 2. 检测是否直播
    Write-Host "  >> 检测直播..."
    if (Is-LiveStream) {
        Write-Host "  >> 检测到直播，跳过" -ForegroundColor Red
        continue
    }

    # 3. 点赞
    Do-Like

    # 4. 等待 2~5s 后收藏
    $wait1 = Get-Random -Minimum 2 -Maximum 6
    Write-Host "  >> 等待 ${wait1}s 后收藏..."
    Start-Sleep -Seconds $wait1
    Do-Collect

    # 5. 等待 3~7s 后评论
    $wait2 = Get-Random -Minimum 3 -Maximum 8
    Write-Host "  >> 等待 ${wait2}s 后评论..."
    Start-Sleep -Seconds $wait2
    Do-Comment
}