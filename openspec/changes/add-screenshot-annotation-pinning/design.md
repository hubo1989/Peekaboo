## Context

Peekaboo 是一个 macOS 自动化工具，核心优势在于 AI 驱动的 UI 自动化。本次改造将其扩展为传统截图工具 + AI 能力的融合产品，对标 Snipaste、Shottr 等工具，同时保持 AI 分析的独特优势。

### 约束

- 必须兼容 macOS 15+ (Sequoia)
- 使用 Swift 6.2 和 SwiftUI
- 不能破坏现有 CLI 和 AI 会话功能
- ScreenCut 组件需适配到现有架构

### 利益相关者

- 终端用户：需要快速截图和标注的开发者/设计师
- AI 用户：希望用 AI 分析屏幕内容的用户
- 开发团队：需要可维护的代码架构

## Goals / Non-Goals

### Goals

1. 提供完整的传统截图体验（快捷键、区域选择、标注、钉图）
2. 将 AI 能力无缝集成到截图工作流
3. 借用 ScreenCut 代码加速开发，减少重复造轮子
4. 保持代码架构清晰，新功能模块化

### Non-Goals

- 不实现视频录制功能（已有独立实现）
- 不实现云存储/分享功能
- 不兼容 macOS 14 及以下版本
- 不重构现有 ScreenCaptureService

## Decisions

### 1. 架构决策：模块化功能组织

**决策**：在 `Apps/Mac/Peekaboo/Features/` 下创建独立的 `Screenshot/` 模块

**结构**：
```
Features/Screenshot/
├── ScreenshotCoordinator.swift     # 协调器，管理截图流程
├── Selection/
│   ├── SelectionOverlayView.swift  # 全屏选择覆盖层
│   ├── SelectionWindow.swift       # 选择窗口
│   └── MagnifierView.swift         # 放大镜/取色器
├── Annotation/
│   ├── AnnotationToolbar.swift     # 工具栏
│   ├── AnnotationCanvas.swift      # 绘图画布
│   ├── Tools/
│   │   ├── RectangleTool.swift
│   │   ├── EllipseTool.swift
│   │   ├── ArrowTool.swift
│   │   ├── PenTool.swift
│   │   ├── TextTool.swift
│   │   └── MosaicTool.swift
│   └── AnnotationManager.swift     # 撤销/重做管理
├── Pin/
│   ├── PinWindow.swift             # 钉图窗口
│   ├── PinWindowManager.swift      # 多实例管理
│   └── PinContextMenu.swift        # 右键菜单
└── AI/
    ├── ScreenshotAIAnalyzer.swift  # AI 分析入口
    └── AIResultOverlay.swift       # AI 结果显示
```

**理由**：
- 与现有 Features 目录结构一致
- 模块化便于测试和维护
- AI 功能作为子模块可复用现有 Tachikoma 能力

### 2. 绘图引擎决策：基于 SwiftUI Canvas + Core Graphics

**决策**：使用 SwiftUI Canvas API + Core Graphics 实现绘图

**理由**：
- SwiftUI Canvas 在 macOS 12+ 性能优秀
- Core Graphics 提供精确的路径控制
- 避免引入额外绘图框架
- ScreenCut 的 Swift 绘图逻辑可直接参考

**备选方案**：
- ~~NSBezierPath~~：与 SwiftUI 集成不如 Canvas 顺畅
- ~~Metal~~：过度工程，截图标注不需要 GPU 加速

### 3. 钉图窗口决策：NSPanel + NSWindow.Level.floating

**决策**：使用 NSPanel 创建钉图窗口

**实现要点**：
```swift
let pinPanel = NSPanel(
    contentRect: imageRect,
    styleMask: [.borderless, .nonactivatingPanel, .utilityWindow],
    backing: .buffered,
    defer: false
)
pinPanel.level = .floating
pinPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
pinPanel.isMovableByWindowBackground = true
```

**理由**：
- NSPanel 适合工具窗口
- nonactivatingPanel 不抢占焦点
- 可配置鼠标穿透 (`ignoresMouseEvents`)

### 4. 快捷键决策：扩展现有 KeyboardShortcuts 系统

**决策**：在现有 `KeyboardShortcutNames.swift` 中添加新快捷键

**新增快捷键**：
```swift
static let captureScreen = Self("captureScreen", default: .init(.s, modifiers: [.command, .shift]))
static let captureArea = Self("captureArea", default: .init(.a, modifiers: [.command, .shift]))
static let captureWindow = Self("captureWindow", default: .init(.w, modifiers: [.command, .shift]))
static let repeatLastCapture = Self("repeatLastCapture", default: .init(.r, modifiers: [.command, .shift]))
```

**理由**：
- 复用现有基础设施
- 统一的快捷键管理体验
- 用户可自定义

### 5. ScreenCut 代码借用策略

**决策**：提取 ScreenCut 的核心绘图逻辑，适配到 SwiftUI 架构

**借用范围**：
1. 形状绘制算法（Arrow、Rectangle、Ellipse 的 path 计算）
2. 工具栏布局参考
3. 颜色选择器组件

**适配工作**：
1. 将 AppKit 组件转换为 SwiftUI
2. 集成到现有设置系统
3. 适配 Peekaboo 的配色和 UI 风格

**不借用**：
1. OCR 功能（使用 Peekaboo 现有 AI 能力）
2. 翻译功能（使用 Peekaboo 现有 AI 能力）
3. 应用架构（保持 Peekaboo 现有架构）

## Risks / Trade-offs

| 风险 | 影响 | 缓解措施 |
|------|------|---------|
| ScreenCut 代码适配复杂度 | 中 | 只提取核心算法，不移植整个模块 |
| 新功能增加应用复杂度 | 中 | 模块化设计，可通过设置禁用 |
| 快捷键冲突 | 低 | 使用可自定义快捷键，默认值避开系统快捷键 |
| 性能影响 | 低 | 使用 Canvas 替代频繁重绘 |

## Migration Plan

1. **Phase 1**：快捷键 + 基础区域选择（1-2 天）
2. **Phase 2**：标注工具栏 + 绘图（3-5 天）
3. **Phase 3**：钉图功能（2-3 天）
4. **Phase 4**：AI 集成 + 优化（2-3 天）

### 回滚策略

- 所有新功能在 `Features/Screenshot/` 独立目录
- 可通过 `PeekabooSettings.screenshotFeaturesEnabled` 开关控制
- 不修改现有 ScreenCaptureService 核心逻辑

## Open Questions

1. 是否需要支持 GIF 录制（可后续迭代）？
2. 标注工具栏位置：底部固定 vs 跟随选择区域？
3. 钉图窗口是否需要支持简单编辑（缩放、旋转）？
