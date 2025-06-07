# Godot 窗口比例锁定工具（Window Aspect Ratio Enforcer）

[🇺🇸 English](README.md) | [🇨🇳 简体中文](README.zh.md)

一个轻量的 GDScript 工具，支持在窗口缩放时自动维持固定或范围限定的宽高比。兼容主流桌面平台，行为自然平滑，适合游戏和工具项目的窗口管理。

## ✨ 功能特点

- 🖼️ **窗口比例锁定**：自动保持设定的宽高比，不会被随意拉伸变形。
- 🖱️ **智能识别缩放方向**：根据用户是拖动边缘还是角落，自动切换缩放策略。
- 🕒 **防抖机制**：使用计时器延迟执行缩放逻辑，避免拖动卡顿。
- ⚙️ **可配置比例范围**：允许设定最小和最大比例范围，灵活适配不同分辨率需求。
- ✅ **即插即用**：只需一键 Autoload，无需修改项目其他设置。

## 📦 安装方式

1. 下载 `WindowAspectRatio.gd` 到你的项目目录，例如放入 `addons/` 文件夹。
2. 打开 **项目设置 → Autoload** 页面。
3. 添加脚本为自动加载
4. 完成！项目启动后将自动启用窗口比例限制功能。

## 🧠 工作原理

本脚本监听窗口的 `size_changed` 信号，并在用户停止拖动后（由计时器控制）处理实际缩放逻辑。

- 如果是**横向拉伸**（宽度变化更明显） → 自动调整高度；
- 如果是**纵向拉伸**（高度变化更明显） → 自动调整宽度；
- 如果是**对角线拉伸**（角落） → 执行等比例缩放。

缩放结果会被限制在 `ratio_range` 指定的最小和最大宽高比之间。

## 🛠️ 使用说明与参数配置

你可以在脚本中修改以下导出变量来控制允许的比例范围：

```gdscript
@export var ratio_range: Vector2 = Vector2(1.0, 16.0 / 9.0)
````

这个范围表示：

* `1.0` 表示最小比例为 1:1（正方形）
* `16.0 / 9.0` 表示最大比例为 16:9（宽屏）

若希望强制使用固定比例（如始终为 16:9），可以将两个值设置为相同：

```gdscript
@export var ratio_range: Vector2 = Vector2(16.0 / 9.0, 16.0 / 9.0)
```

### 缩放方向判断示例（核心逻辑片段）：

```gdscript
var current_size = get_window().size
var delta = current_size - previous_size

if abs(delta.x) > abs(delta.y) * 1.5:
    # 边缘 - 横向拖动
    new_size = constrain_width(current_size)
elif abs(delta.y) > abs(delta.x) * 1.5:
    # 边缘 - 纵向拖动
    new_size = constrain_height(current_size)
else:
    # 角落 - 等比缩放
    new_size = enforce_aspect_ratio(current_size)
```

## 💡 使用建议

* 本工具仅适用于桌面端（`OS.has_feature("desktop")`）
* 推荐与 `Windowed` 或 `Borderless` 模式搭配使用（不建议全屏）
* 可根据需要修改 `resize_timer.wait_time` 来调整防抖延迟

## 📄 License

MIT 开源许可

---

由 ❤️ 制作，基于 Godot Engine 引擎。
