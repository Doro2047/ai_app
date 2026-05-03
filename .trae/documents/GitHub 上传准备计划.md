# AI App GitHub 上传准备计划

## 项目概述

这是一个 Flutter 跨平台工具集应用 (v3.0.0)，包含文件管理、书签管理、APK 安装、系统控制等功能模块。

---

## 一、敏感信息与本地配置清理

### 1.1 排除本地路径配置
- **文件**: `android/local.properties`
- **问题**: 包含本地 SDK 路径 `C:\Users\FREE\...`
- **操作**: 添加到 `.gitignore`

### 1.2 检查 `.metadata` 文件
- **文件**: 根目录及各子项目的 `.metadata`
- **问题**: 可能包含本地 Flutter SDK 路径
- **操作**: 添加到 `.gitignore`

---

## 二、删除不必要的文件与目录

### 2.1 删除 Flutter SDK 克隆目录
- **目录**: `flutter/`（完整的 Flutter SDK，包含 engine、dev 等，约数 GB）
- **理由**: 开发者应自行安装 Flutter，不应将 SDK 提交到仓库

### 2.2 删除构建产物
- **目录**: `build/`（根目录及各子项目）
- **目录**: `release/`（包含已编译的 exe、dll、zip 等）
- **理由**: 构建产物不应提交到版本控制，由 CI 生成

### 2.3 删除子项目的 IDE 配置
- **目录**: `apps/*/build/`
- **文件**: `apps/*/*.iml`、`apps/*/.idea/`
- **理由**: IDE 配置和构建产物不应提交

### 2.4 删除子项目的日志文件
- **文件**: `apps/*/flutter_*.log`
- **理由**: 调试日志不应提交

### 2.5 清理 packages 目录
- **文件**: `packages/shared_core/*.iml`
- **文件**: `packages/copy_files.ps1`（临时脚本）
- **理由**: IDE 配置和临时脚本

### 2.6 删除项目级临时构建脚本
- **文件**: `build_all.bat`、`clean_all.bat`、`test_build_package.bat`
- **理由**: 如需保留应移至 `scripts/` 目录并重命名为行业规范格式

---

## 三、完善 .gitignore

在现有基础上新增：
```
# Local configuration
android/local.properties
*.metadata

# IDE
*.iml
apps/*/.idea/
packages/*/.idea/

# Build artifacts (sub-projects)
apps/*/build/
apps/*/flutter_0*.log

# Release binaries
release/

# Flutter SDK (should not be committed)
flutter/

# Scripts (if kept)
scripts/
```

---

## 四、重写 README.md

创建专业的 README，包含：
- 项目名称和一句话简介
- 功能特性列表（11 个工具模块）
- 技术栈说明
- 快速开始指南（环境要求、安装步骤、运行命令）
- 项目结构说明
- 构建说明（Windows/APK）
- CI/CD 状态徽章
- 贡献指南链接
- 许可证信息
- 项目架构图（文字版）

---

## 五、添加项目文档

### 5.1 CONTRIBUTING.md
- 开发环境设置
- 代码规范
- Pull Request 流程
- 提交信息规范

### 5.2 LICENSE
- 确认是否已有许可证
- 如无，建议 MIT License

### 5.3 .github/PULL_REQUEST_TEMPLATE.md
- PR 模板，包含描述、类型、测试清单

---

## 六、更新 pubspec.yaml

### 6.1 修复 homepage/repository URL
- 当前 URL 为 `https://github.com/FREE-AI-APP/ai_app`
- 确认是否为目标仓库地址

### 6.2 添加 topics（Pub 分类标签）
- 建议: `flutter`, `file-tools`, `cross-platform`, `productivity`

---

## 七、创建 scripts 目录

将构建脚本规范化整理：
- `scripts/build-windows.bat` - Windows 构建
- `scripts/build-android.bat` - Android 构建
- `scripts/clean.bat` - 清理项目

---

## 八、分支策略

### 8.1 推荐分支结构
| 分支 | 用途 | 保护规则 |
|------|------|---------|
| `main` | 生产发布 | 禁止直接推送，需 PR |
| `develop` | 开发集成 | 禁止直接推送，需 PR |
| `feature/*` | 功能开发 | 无 |
| `bugfix/*` | 问题修复 | 无 |
| `release/*` | 发布准备 | 无 |

### 8.2 设置方法
- 在 GitHub 仓库设置中配置分支保护规则
- 本地使用 `git checkout -b develop` 创建开发分支

---

## 九、Git 初始化与提交

### 9.1 初始化
```bash
git init
git checkout -b main
```

### 9.2 首次提交结构
| 提交顺序 | 提交信息 | 包含内容 |
|---------|---------|---------|
| 1 | `docs: 初始化项目文档` | README.md, LICENSE, CONTRIBUTING.md |
| 2 | `chore: 配置 .gitignore 和 CI/CD` | .gitignore, .github/workflows/ |
| 3 | `feat: 添加核心模块` | lib/core/, lib/shared/, lib/app/ |
| 4 | `feat: 添加文件管理工具` | lib/features/file_* / |
| 5 | `feat: 添加工具箱和其他功能` | lib/features/bookmark_*, apk_*, system_*, toolbox/, search/, app_center/, image_classifier/ |
| 6 | `feat: 添加测试和国际化` | test/, lib/l10n/ |
| 7 | `feat: 添加平台配置` | android/, ios/, windows/, web/ |
| 8 | `feat: 添加 packages/shared_core` | packages/ |

### 9.3 创建 develop 分支
```bash
git checkout -b develop
```

---

## 十、上传前检查清单

- [ ] .gitignore 完整覆盖不需要提交的文件
- [ ] README.md 内容准确、格式规范
- [ ] LICENSE 已添加
- [ ] 无敏感信息（API Key、密码、本地路径）
- [ ] 无构建产物和二进制文件
- [ ] flutter analyze 无 error（仅 warning/info 可接受）
- [ ] CONTRIBUTING.md 已创建
- [ ] pubspec.yaml 中的 URL 正确
- [ ] Git 历史清晰、分模块提交

---

## 执行顺序总结

1. 完善 .gitignore（新增规则）
2. 删除不需要的文件和目录（flutter SDK、build、release、日志等）
3. 重写 README.md
4. 创建 CONTRIBUTING.md 和 LICENSE
5. 创建 .github/PULL_REQUEST_TEMPLATE.md
6. 规范化 scripts 目录
7. 验证 git status 输出（确认只包含应提交的文件）
8. 初始化 Git 仓库并按计划提交
9. 创建 develop 分支
