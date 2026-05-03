# 🚀 AI App - 跨平台智能工具集
> **你的瑞士军刀！高效、免费、无广告！** ✨

[![Flutter CI](https://github.com/FREE-AI-APP/ai_app/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/FREE-AI-APP/ai_app/actions/workflows/flutter-ci.yml)
[![Flutter Version](https://img.shields.io/badge/flutter-%3E%3D3.41.0-blue?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/dart-%3E%3D3.11.0-blue?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/platform-windows%20%7C%20android%20%7C%20web-orange?logo=windows&logoColor=white)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green?logo=mit&logoColor=white)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/Doro2047/ai_app?style=social)](https://github.com/Doro2047/ai_app)

一套基于 Flutter 的跨平台桌面/移动工具集，提供文件管理、系统控制、书签管理、APK 安装等实用功能。**支持多种主题、暗色模式、跨平台！** 🎨

---

## ✨ 核心亮点

- 🚀 **极速启动** - 优化的加载机制，秒开即用
- 🎨 **精美主题** - 8种预设主题 + 暗色模式，颜值在线
- 🌍 **跨平台** - 支持 Windows、Android、Web 平台
- 🛠️ **一站式** - 10+ 实用工具，满足日常需求
- 🔒 **安全免费** - 无广告、无追踪、开源透明
- 📦 **即用即走** - 单文件可执行，无需安装
- 💡 **持续更新** - 活跃社区，定期添加新工具

---

## 📦 功能特性

### 📁 文件管理工具
| 工具 | 功能描述 | 图标 |
|------|---------|------|
| 文件扫描 | 🔍 递归扫描目录，按类型/大小/日期筛选文件 | 🔍 |
| 文件去重 | 🧹 基于 MD5/SHA 哈希值的重复文件检测与清理 | 🧹 |
| 文件重命名 | ✏️ 支持正则表达式、批量规则替换的文件重命名 | ✏️ |
| 文件移动 | 📂 按规则批量移动文件到目标目录 | 📂 |
| 扩展名修改 | 🔄 批量修改文件扩展名，支持预览确认 | 🔄 |

### ⚙️ 系统工具
| 工具 | 功能描述 | 图标 |
|------|---------|------|
| 系统控制 | ⏱️ Windows 电源管理、网络配置（关机/重启/休眠等） | ⏱️ |
| APK 安装器 | 📱 通过 ADB 安装 Android 应用包 | 📱 |
| 书签管理 | 📑 解析 Chrome/Edge 书签文件，验证链接有效性 | 📑 |

### 🎯 其他功能
| 工具 | 功能描述 | 图标 |
|------|---------|------|
| 图像分类 | 🤖 AI 驱动的图像自动分类与标签管理 | 🤖 |
| 工具箱 | 🎛️ 已安装程序的管理和快捷入口 | 🎛️ |
| 全局搜索 | 🔎 跨工具搜索和快速导航 | 🔎 |

---

## 技术栈

| 类别 | 技术 |
|------|------|
| **框架** | Flutter >= 3.41.0 |
| **语言** | Dart >= 3.11.0 |
| **状态管理** | flutter_bloc (BLoC/Cubit) |
| **路由** | go_router |
| **依赖注入** | get_it |
| **本地存储** | Hive |
| **网络请求** | dio |
| **国际化** | flutter_localizations + ARB |
| **测试** | flutter_test + bloc_test + mocktail |

### 架构模式
- **Feature-First** 目录结构，按功能模块组织代码
- **BLoC Pattern** 用于状态管理，每个功能模块包含独立的 Bloc/Event/State
- **Repository Pattern** 数据访问层与 UI 层解耦
- **依赖注入** 使用 GetIt 进行集中式依赖管理

---

## 项目结构

```
ai_app/
├── lib/
│   ├── app/              # 应用入口 (路由、DI、本地化)
│   ├── core/             # 核心基础设施 (常量、错误处理、存储、主题、工具)
│   ├── features/         # 功能模块 (每个模块包含 bloc/models/repositories/views)
│   │   ├── file_scanner/
│   │   ├── file_dedup/
│   │   ├── file_renamer/
│   │   ├── file_mover/
│   │   ├── extension_changer/
│   │   ├── system_control/
│   │   ├── apk_installer/
│   │   ├── bookmark_manager/
│   │   ├── image_classifier/
│   │   ├── toolbox/
│   │   ├── search/
│   │   └── app_center/
│   ├── l10n/             # 国际化资源 (en, zh)
│   ├── shared/           # 共享组件 (BLoC 基类、通用 Widget)
│   └── main.dart         # 应用入口点
├── test/                 # 单元测试和 Widget 测试
├── integration_test/     # 集成测试
├── packages/             # 本地包 (shared_core)
├── apps/                 # 独立子应用 (可选构建)
├── android/              # Android 平台配置
├── ios/                  # iOS 平台配置
├── windows/              # Windows 平台配置
├── web/                  # Web 平台配置
├── scripts/              # 构建和工具脚本
└── .github/              # CI/CD 工作流
```

---

## 快速开始

### 环境要求
- Flutter >= 3.41.0 ([安装指南](https://docs.flutter.dev/get-started/install))
- Dart >= 3.11.0 (随 Flutter 一起安装)
- Windows 10/11 (桌面端) 或 Android SDK (移动端)

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/FREE-AI-APP/ai_app.git
   cd ai_app
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成代码** (路由和国际化)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter gen-l10n
   ```

4. **运行应用**
   ```bash
   # 运行桌面版 (Windows)
   flutter run -d windows

   # 运行 Android 版
   flutter run -d android

   # 运行 Web 版
   flutter run -d chrome
   ```

---

## 构建发布版本

### Windows
```bash
flutter build windows --release
```
产物位于 `build/windows/x64/runner/Release/` 目录下。

### Android
```bash
flutter build apk --release
# 或构建 App Bundle
flutter build appbundle --release
```
产物位于 `build/app/outputs/flutter-apk/` 目录下。

### 使用构建脚本
```bash
# Windows (在项目根目录)
scripts\build-windows.bat

# Android
scripts\build-android.bat

# 清理构建产物
scripts\clean.bat
```

---

## 测试

```bash
# 运行所有测试
flutter test

# 运行分析检查
flutter analyze

# 运行集成测试
flutter test integration_test/app_test.dart
```

---

## 贡献指南

我们欢迎所有形式的贡献！请阅读 [贡献指南](CONTRIBUTING.md) 了解：
- 开发环境设置
- 代码规范
- Pull Request 流程
- 提交信息格式

### 分支策略
| 分支 | 用途 |
|------|------|
| `main` | 稳定版本，每个 tag 对应一个发布版本 |
| `develop` | 日常开发集成分支 |
| `feature/*` | 新功能开发 |
| `bugfix/*` | 问题修复 |
| `release/*` | 发布准备 |

---

## CI/CD

本项目使用 GitHub Actions 进行持续集成：
- **代码分析**: `flutter analyze` 检查代码质量
- **单元测试**: `flutter test` 运行测试套件
- **Windows 构建**: 自动构建 Windows 桌面版本
- **Android 构建**: 自动构建 Android APK

触发条件: push/PR 到 `main` 或 `develop` 分支。

---

## 许可证

本项目采用 [MIT License](LICENSE) 开源许可。

---

## ⭐ 支持我们

如果你觉得这个项目对你有帮助，请：
- 🌟 给项目点个 Star
- 📢 分享给你的朋友
- 💬 在 Issues 中反馈你的想法

你的支持是我们持续更新的动力！

---

## 相关链接

- [项目仓库](https://github.com/Doro2047/ai_app)
- [Flutter 官方文档](https://docs.flutter.dev)
- [BLoC 文档](https://bloclibrary.dev)
