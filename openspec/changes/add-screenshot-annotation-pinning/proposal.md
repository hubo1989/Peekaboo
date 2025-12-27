# Change: 融合传统截图功能与 AI 能力 - 借用 ScreenCut 架构

## Why

Peekaboo 目前是一个强大的 AI 驱动的 macOS 自动化工具，具备屏幕捕获和 UI 元素检测能力。但缺乏传统截图工具的核心功能：快捷键触发、区域选择、图片标注、钉图显示等。通过借用开源项目 ScreenCut 的架构和组件，可以快速将 Peekaboo 改造为一个融合传统截图能力与 AI 分析的综合工具。

## What Changes

### 新增功能

1. **截图快捷键系统**
   - 全局快捷键触发截图（默认 Cmd+Shift+4 风格）
   - 重复上次截图区域快捷键
   - 快捷键可自定义配置

2. **交互式区域选择**
   - 全屏覆盖层 + 鼠标拖拽选择区域
   - 实时显示选择区域尺寸
   - 取色器功能（按 C 复制颜色值）
   - ESC 取消选择

3. **截图标注工具栏**
   - 矩形/椭圆绘制
   - 箭头标注
   - 自由绘制（画笔）
   - 文本添加
   - 马赛克/模糊
   - 颜色选择器
   - 线条粗细调节

4. **钉图功能 (Pin Screenshot)**
   - 截图后可选择"钉"到桌面
   - 浮动窗口始终置顶
   - 支持透明度调节
   - 鼠标穿透切换
   - 多实例支持

5. **AI 增强功能**
   - 截图后可发送给 AI 分析
   - AI 辅助 OCR 文字识别
   - AI 翻译截图中的文字
   - 智能元素标注（结合现有 UI 检测能力）

### 借用 ScreenCut 的组件

- 绘图工具组件（矩形、椭圆、箭头、文本）
- 工具栏 UI 布局
- 区域选择交互逻辑
- 颜色/粗细选择器

## Impact

- **Affected specs**: 新增 4 个 capability（screenshot-capture, annotation-tools, pin-window, screenshot-shortcuts）
- **Affected code**:
  - `Apps/Mac/Peekaboo/` - 主要 Mac 应用改动
  - `Core/PeekabooVisualizer/` - 覆盖层和标注视图
  - `Apps/Mac/Peekaboo/Core/KeyboardShortcutNames.swift` - 快捷键扩展
  - 新增 `Apps/Mac/Peekaboo/Features/Screenshot/` 目录

## Dependencies

- **ScreenCut** (https://github.com/VCBSstudio/ScreenCut) - Apache-2.0 许可证
- 现有 `KeyboardShortcuts` 库
- 现有 `ScreenCaptureService`

## Migration Notes

- 不影响现有 CLI 功能
- 不影响现有 AI 会话功能
- 新功能作为可选模块，可通过设置启用/禁用
