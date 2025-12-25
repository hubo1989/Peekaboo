<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# CLAUDE.md

此文件为 Claude Code (claude.ai/code) 在处理本仓库代码时提供指南。

## 构建与测试命令

- **构建 CLI (调试):** `pnpm run build:cli`
- **构建 CLI (发布):** `pnpm run build:swift:all` (通用架构) 或 `pnpm run build:swift` (仅 arm64)
- **快速重建:** `pnpm run poltergeist:haunt` (编辑时的快速重建)
  - 检查状态: `pnpm run poltergeist:status`
  - 停止: `pnpm run poltergeist:rest`
- **测试 (安全):** `pnpm run test:safe` (单元测试，无自动化/屏幕录制)
- **测试 (自动化):** `pnpm run test:automation` (需要屏幕录制/辅助功能权限)
- **测试单个目标/用例:** `./runner swift test --package-path Apps/CLI --filter <TestName>`
- **代码检查 (Lint):** `pnpm run lint` (SwiftLint)
- **格式化:** `pnpm run format` (SwiftFormat)
- **验证所有:** `pnpm run lint && pnpm run format && pnpm run test:safe`

## 项目结构

- **CLI 应用:** `Apps/CLI` (SwiftPM 包)。命令在 `Sources` 中，测试在 `Tests` 中。
- **Mac 应用:** `Apps/Mac`, `Apps/peekaboo`, `Apps/PeekabooInspector`。工作区: `Apps/Peekaboo.xcworkspace`。
- **核心逻辑:** `Core/PeekabooCore` (共享自动化、智能体运行时、可视化器)。将新的共享工具放在此处。
- **子模块:** `AXorcist/` (AX 自动化), `Commander/` (CLI 解析), `Tachikoma/` (AI/MCP), `TauTUI/`。
  - **重要:** 先在各自的仓库中更新子模块，然后在此处更新指针。
- **脚本:** `scripts/` 包含构建/发布脚本。**始终**使用 `./runner` 执行工具。

## 代码规范

- **语言:** Swift 6.2
- **风格:** 4 空格缩进，120 字符换行。必须显式使用 `self`。
- **代码检查:** 通过 `pnpm run format` 和 `pnpm run lint` 强制执行。
- **架构:**
  - `PeekabooAutomation`: 自动化 API
  - `PeekabooAgentRuntime`: 智能体编排
  - `PeekabooVisualizer`: UI 反馈
- **依赖:** 通过 SwiftPM 和 git 子模块管理。

## 提交指南

- **格式:** Conventional Commits (`type(scope): summary`)。
- **工具:** **必须**使用 `./scripts/committer "message" <paths>` 来暂存和提交。
  - 示例: `./scripts/committer "feat(cli): add capture retry" Apps/CLI/Sources/Capture.swift`
- **不要使用** 原始的 `git add` / `git commit`。

## 开发说明

- **环境:** 推荐 macOS 26.1+ (arm64)。
- **权限:** 自动化测试需要屏幕录制和辅助功能权限。通过 `peekaboo permissions` 管理。
- **密钥:** 存储在 `~/.peekaboo`。**切勿**提交凭据。
