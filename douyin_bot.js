home();
sleep(500);

// ==================== 配置 ====================
var WATCH_TIME = 3000;   // 看视频时间 (ms)
var REST_TIME = 10000;   // 低亮度休息时间 (ms)
var DIM_BRIGHTNESS = 0;  // 休息时亮度 (0=最暗)

// 滑动参数
var minX = 100, maxX = 900;
var minDur = 300, maxDur = 800;

// ==================== 停止控制 ====================
events.observeKey();
events.onKeyDown("volume_down", function(event) {
    // 恢复自动亮度 + 最大亮度
    try { shell("settings put system screen_brightness 255", false); } catch (e) {}
    try { shell("settings put system screen_brightness_mode 1", false); } catch (e) {}
    toast("滑动已停止");
    engines.stopAll();
    event.consumed = true;
});

// ==================== 初始化（关自动亮度） ====================
try {
    shell("settings put system screen_brightness_mode 0", false);
    shell("settings put system screen_brightness 255", false);
} catch (e) {
    toast("亮度控制需要shell权限，降亮度可能无效");
}
toast("省电滑动已启动 | 音量-停止");

// ==================== 工具函数 ====================
function rand(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function dimScreen() {
    try {
        shell("settings put system screen_brightness " + DIM_BRIGHTNESS, false);
    } catch (e) {}
}

function restoreScreen() {
    try {
        shell("settings put system screen_brightness 255", false);
    } catch (e) {}
}

// ==================== 主循环 ====================
while (true) {
    restoreScreen();
    sleep(300);

    // 滑动
    var x1 = rand(minX, maxX);
    var x2 = rand(minX, maxX);
    var dur = rand(minDur, maxDur);
    swipe(x1, 1600, x2, 400, dur);

    sleep(WATCH_TIME);    // 看3秒
    dimScreen();          // 降到最低亮度
    sleep(REST_TIME);     // 休息10秒
}