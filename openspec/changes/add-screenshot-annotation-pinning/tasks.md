# Implementation Tasks

## Phase 1: 快捷键 + 基础区域选择

### 1.1 快捷键系统扩展
- [ ] 1.1.1 在 `KeyboardShortcutNames.swift` 添加截图快捷键定义
- [ ] 1.1.2 在 `ShortcutSettingsView.swift` 添加截图快捷键配置 UI
- [ ] 1.1.3 在 `AppDelegate.swift` 添加截图快捷键触发逻辑
- [ ] 1.1.4 在 `PeekabooSettings.swift` 添加截图功能开关

### 1.2 截图协调器
- [ ] 1.2.1 创建 `Features/Screenshot/ScreenshotCoordinator.swift`
- [ ] 1.2.2 实现截图流程状态机（idle → selecting → annotating → done）
- [ ] 1.2.3 集成现有 `ScreenCaptureService`

### 1.3 区域选择覆盖层
- [ ] 1.3.1 创建 `Features/Screenshot/Selection/SelectionWindow.swift`
- [ ] 1.3.2 创建 `Features/Screenshot/Selection/SelectionOverlayView.swift`
- [ ] 1.3.3 实现鼠标拖拽选择区域
- [ ] 1.3.4 实现实时尺寸显示
- [ ] 1.3.5 实现 ESC 取消功能

### 1.4 放大镜/取色器
- [ ] 1.4.1 创建 `Features/Screenshot/Selection/MagnifierView.swift`
- [ ] 1.4.2 实现像素放大显示
- [ ] 1.4.3 实现 RGB/Hex 颜色值显示
- [ ] 1.4.4 实现按 C 复制颜色值

## Phase 2: 标注工具栏 + 绘图

### 2.1 工具栏 UI
- [ ] 2.1.1 创建 `Features/Screenshot/Annotation/AnnotationToolbar.swift`
- [ ] 2.1.2 实现工具按钮（矩形、椭圆、箭头、画笔、文本、马赛克）
- [ ] 2.1.3 实现颜色选择器
- [ ] 2.1.4 实现线条粗细选择器
- [ ] 2.1.5 实现工具栏定位（跟随选择区域底部）

### 2.2 绘图画布
- [ ] 2.2.1 创建 `Features/Screenshot/Annotation/AnnotationCanvas.swift`
- [ ] 2.2.2 实现 Canvas 基础绘制逻辑
- [ ] 2.2.3 集成绘图工具系统

### 2.3 绘图工具实现
- [ ] 2.3.1 创建 `Tools/DrawingTool.swift` 协议
- [ ] 2.3.2 实现 `Tools/RectangleTool.swift`
- [ ] 2.3.3 实现 `Tools/EllipseTool.swift`
- [ ] 2.3.4 实现 `Tools/ArrowTool.swift`（参考 ScreenCut 算法）
- [ ] 2.3.5 实现 `Tools/PenTool.swift`
- [ ] 2.3.6 实现 `Tools/TextTool.swift`
- [ ] 2.3.7 实现 `Tools/MosaicTool.swift`

### 2.4 撤销/重做系统
- [ ] 2.4.1 创建 `Features/Screenshot/Annotation/AnnotationManager.swift`
- [ ] 2.4.2 实现 Command 模式的操作历史
- [ ] 2.4.3 实现 Cmd+Z / Cmd+Shift+Z 快捷键

### 2.5 操作按钮
- [ ] 2.5.1 实现"复制到剪贴板"按钮
- [ ] 2.5.2 实现"保存到文件"按钮
- [ ] 2.5.3 实现"发送给 AI"按钮
- [ ] 2.5.4 实现"钉到桌面"按钮

## Phase 3: 钉图功能

### 3.1 钉图窗口
- [ ] 3.1.1 创建 `Features/Screenshot/Pin/PinWindow.swift`
- [ ] 3.1.2 实现 NSPanel 配置（浮动、无边框）
- [ ] 3.1.3 实现窗口拖动
- [ ] 3.1.4 实现鼠标滚轮缩放

### 3.2 窗口管理器
- [ ] 3.2.1 创建 `Features/Screenshot/Pin/PinWindowManager.swift`
- [ ] 3.2.2 实现多实例窗口管理
- [ ] 3.2.3 实现窗口生命周期管理

### 3.3 右键菜单
- [ ] 3.3.1 创建 `Features/Screenshot/Pin/PinContextMenu.swift`
- [ ] 3.3.2 实现"复制"菜单项
- [ ] 3.3.3 实现"保存"菜单项
- [ ] 3.3.4 实现"透明度"子菜单
- [ ] 3.3.5 实现"鼠标穿透"切换
- [ ] 3.3.6 实现"关闭"菜单项
- [ ] 3.3.7 实现"关闭所有"菜单项

## Phase 4: AI 集成 + 优化

### 4.1 AI 分析集成
- [ ] 4.1.1 创建 `Features/Screenshot/AI/ScreenshotAIAnalyzer.swift`
- [ ] 4.1.2 实现截图发送到 AI 会话
- [ ] 4.1.3 实现 AI OCR 文字识别
- [ ] 4.1.4 实现 AI 翻译功能

### 4.2 AI 结果展示
- [ ] 4.2.1 创建 `Features/Screenshot/AI/AIResultOverlay.swift`
- [ ] 4.2.2 实现 OCR 结果可选择复制
- [ ] 4.2.3 实现翻译结果悬浮显示

### 4.3 设置集成
- [ ] 4.3.1 创建 `Features/Settings/ScreenshotSettingsView.swift`
- [ ] 4.3.2 实现截图功能总开关
- [ ] 4.3.3 实现默认保存路径设置
- [ ] 4.3.4 实现图片格式选择（PNG/JPEG）
- [ ] 4.3.5 实现工具栏位置偏好

### 4.4 测试
- [ ] 4.4.1 添加 ScreenshotCoordinator 单元测试
- [ ] 4.4.2 添加绘图工具单元测试
- [ ] 4.4.3 添加 PinWindowManager 单元测试
- [ ] 4.4.4 添加 UI 集成测试

### 4.5 文档
- [ ] 4.5.1 更新 README 添加截图功能说明
- [ ] 4.5.2 添加快捷键文档
- [ ] 4.5.3 添加用户指南
