# 工具箱拆分为独立应用规范

## Why

当前项目是一个集成工具箱（单个 Flutter 应用包含所有工具），用户希望每个工具都是独立的可执行程序（独立 exe），可以单独分发和使用。此外，当前构建的程序仅显示空框架，内部功能无法使用，需要在拆分过程中修复此问题。

## What Changes

- 将当前单一 Flutter 应用拆分为多个独立的 Flutter 项目
- 每个工具（APK安装器、文件查重、文件重命名等）成为独立项目
- 每个项目可独立构建独立的 Windows exe 文件
- 提取共享组件、工具类、主题系统为可复用的包
- 修复当前功能缺失问题（文件操作、系统控制等核心功能）
- 确保每个独立应用功能完整、界面正常、交互流畅

## Impact

- 受影响模块：所有功能模块（11个工具）
- 受影响代码：整个 lib/ 目录结构
- 新增：共享包（shared_core）、独立应用项目（每个工具一个）
- 保留：原项目作为参考，不删除

## ADDED Requirements

### Requirement: 独立应用拆分
系统 SHALL 将每个工具拆分为独立的 Flutter 项目，每个项目包含：
- 完整的 Flutter 项目结构
- 独立的功能实现
- 可独立构建为 exe

#### Scenario: 成功拆分
- **WHEN** 执行拆分流程
- **THEN** 每个工具成为独立 Flutter 项目，可独立运行

### Requirement: 共享代码提取
系统 SHALL 提取以下共享内容到独立包：
- 主题系统（7套皮肤）
- 工具类（文件操作、日志、Toast）
- 通用组件（对话框、按钮等）
- 异常体系

#### Scenario: 共享包引用
- **WHEN** 独立应用需要主题或工具类
- **THEN** 通过 pubspec.yaml 依赖共享包引用

### Requirement: 功能完整性修复
系统 SHALL 确保每个独立应用的功能完整可用：
- 文件操作类工具可正常读写文件
- 系统控制类工具可正常执行系统命令
- UI 组件正常渲染和交互

#### Scenario: 文件查重功能
- **WHEN** 用户打开文件查重工具
- **THEN** 可选择文件夹、执行查重、显示结果并操作

### Requirement: 构建验证
系统 SHALL 每个独立项目可成功构建为 Windows exe

#### Scenario: 构建成功
- **WHEN** 执行 flutter build windows --release
- **THEN** 生成独立的可执行 exe 文件

## MODIFIED Requirements

### Requirement: 项目结构
原 Feature-First 架构 SHALL 修改为独立项目架构：
- 原：lib/features/ 下所有工具在同一个项目中
- 新：每个工具独立项目，共享代码通过 pub 依赖管理

## REMOVED Requirements

### Requirement: 统一工具箱导航
**Reason**: 拆分为独立应用后不再需要统一导航
**Migration**: 侧边栏、路由系统等仅保留在每个独立应用需要的部分
