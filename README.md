# ADB 自动滑动脚本

通过 ADB 控制 Android 设备自动向上滑动，所有参数随机化，模拟真实操作。

## 前置条件

1. 安装 [ADB](https://developer.android.com/tools/adb) 并加入 PATH
2. Android 设备开启 USB 调试，通过 `adb devices` 确认已授权

## 使用方式

```powershell
.\swipe_loop.ps1
```

按 `Ctrl+C` 停止。

## 参数说明

| 参数 | 随机范围 | 说明 |
|------|----------|------|
| 起始 X | 480 ~ 599 | 起始点横坐标 |
| 起始 Y | 1900 ~ 2299 | 起始点纵坐标（屏幕底部） |
| 终点 X | 480 ~ 599 | 终点横坐标 |
| 终点 Y | 100 ~ 499 | 终点纵坐标（屏幕顶部） |
| 持续时间 | 300 ~ 799ms | 滑动动作耗时 |
| 间隔 | 10/11/12/13/14/15s | 每次滑动后等待时间 |

## ADB swipe 命令格式

```
adb shell input swipe <x1> <y1> <x2> <y2> [duration(ms)]
```

- `x1, y1` — 起始坐标
- `x2, y2` — 终点坐标
- `duration` — 滑动持续时间，单位毫秒