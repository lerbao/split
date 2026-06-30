# 抖音自动刷视频+随机互动脚本，按 Ctrl+C 停止
# 右侧按钮坐标（1080x2388基准，脚本内会加随机偏移）
$LIKE_X = 930; $LIKE_Y = 1350        # 点赞(心形图标)
$COMMENT_X = 930; $COMMENT_Y = 1580  # 评论图标
$BOOKMARK_X = 930; $BOOKMARK_Y = 1820 # 收藏图标
$CENTER_X = 540; $CENTER_Y = 1200    # 屏幕中央(双击点赞用)
$COMMENT_INPUT_X = 540; $COMMENT_INPUT_Y = 2280  # 评论输入框
$SEND_X = 980; $SEND_Y = 2280        # 发送按钮

# 评论候选语料
$comments = @(
    "哈哈哈哈",
    "太真实了",
    "学到了",
    "笑死我了",
    "一模一样",
    "有道理",
    "绝了",
    "好家伙",
    "牛的",
    "确实",
    "真相了",
    "太有才了",
    "666",
    "我也这样",
    "说的对"
)

# 滑动间隔：10~15s随机
$intervals = @(10, 11, 12, 13, 14, 15)

# 动作概率权重：like=40, collect=15, comment=10, skip=35
$actions = @("like") * 40 + @("collect") * 15 + @("comment") * 10 + @("skip") * 35

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  抖音自动刷视频 Bot 启动" -ForegroundColor Cyan
Write-Host "  动作: 点赞40% | 收藏15% | 评论10% | 跳过35%" -ForegroundColor Cyan
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

function Do-Like {
    # 观看一段随机时间后再点赞
    $watch = Get-Random -Minimum 3 -Maximum 8
    Write-Host "  >> 观看 ${watch}s 后点赞..."
    Start-Sleep -Seconds $watch

    $x = RandomOffset $CENTER_X 100
    $y = RandomOffset $CENTER_Y 150
    Write-Host "  >> 点赞 (双击 $x,$y)"
    adb shell input tap $x $y
    Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 200)
    adb shell input tap $x $y
}

function Do-Collect {
    # 观看一段随机时间后再收藏
    $watch = Get-Random -Minimum 3 -Maximum 8
    Write-Host "  >> 观看 ${watch}s 后收藏..."
    Start-Sleep -Seconds $watch

    $x = RandomOffset $BOOKMARK_X 30
    $y = RandomOffset $BOOKMARK_Y 30
    Write-Host "  >> 收藏 ($x,$y)"
    adb shell input tap $x $y
}

function Do-Comment {
    # 观看一段随机时间后再评论
    $watch = Get-Random -Minimum 4 -Maximum 10
    Write-Host "  >> 观看 ${watch}s 后评论..."
    Start-Sleep -Seconds $watch

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
    $action = Get-Random -InputObject $actions
    $delay = Get-Random -InputObject $intervals

    Write-Host "[$count] $(Get-Date -Format 'HH:mm:ss') 动作=$action | 间隔=${delay}s" -ForegroundColor Yellow

    # 先滑动到下一个视频
    Swipe-Up
    $loadWait = Get-Random -Minimum 1 -Maximum 4
    Write-Host "  >> 等待视频加载 ${loadWait}s..."
    Start-Sleep -Seconds $loadWait

    switch ($action) {
        "like"    { Do-Like }
        "collect" { Do-Collect }
        "comment" { Do-Comment }
        "skip"    { Write-Host "  >> 跳过" }
    }

    Start-Sleep -Seconds $delay
}