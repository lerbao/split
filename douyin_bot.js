home();
sleep(500);

// 音量-键停止
events.observeKey();
events.onKeyDown("volume_down", function(event) {
    toast("滑动已停止");
    engines.stopAll();
    event.consumed = true;
});

toast("滑动已启动 | 音量-键停止");

var minX = 100, maxX = 900;
var minDur = 300, maxDur = 800;
var minSleep = 5000, maxSleep = 10000;

while (true) {
    var x1 = Math.floor(Math.random() * (maxX - minX + 1)) + minX;
    var x2 = Math.floor(Math.random() * (maxX - minX + 1)) + minX;
    var dur = Math.floor(Math.random() * (maxDur - minDur + 1)) + minDur;
    swipe(x1, 1600, x2, 400, dur);
    sleep(Math.floor(Math.random() * (maxSleep - minSleep + 1)) + minSleep);
}