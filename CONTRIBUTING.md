# 贡献指南

感谢你对 AI App 项目的关注！本指南将帮助你了解如何参与项目开发。

---

## 开发环境设置

### 1. 克隆项目

```bash
git clone https://github.com/FREE-AI-APP/ai_app.git
cd ai_app
```

### 2. 安装依赖

```bash
flutter pub get
```

### 3. 生成代码

```bash
# 生成路由和国际化代码
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

### 4. 运行测试

```bash
flutter test
flutter analyze
```

---

## 代码规范

### 命名约定

| 类型 | 规则 | 示例 |
|------|------|------|
| 类名 | PascalCase | `FileScannerBloc` |
| 变量/函数 | camelCase | `scanDirectory` |
| 常量 | UPPER_SNAKE_CASE | `MAX_FILE_SIZE` |
| 文件名 | snake_case | `file_scanner_bloc.dart` |
| 私有成员 | 前缀 `_` | `_handleError` |

### 目录结构

每个功能模块应遵循以下结构：

```
features/module_name/
├── bloc/          # 状态管理
│   ├── module_name_bloc.dart
│   ├── module_name_event.dart
│   └── module_name_state.dart
├── models/        # 数据模型
├── repositories/  # 数据访问层
├── views/         # UI 页面/组件
└── module_name.dart  # 模块导出文件
```

### 代码格式化

在提交前运行：

```bash
dart format lib/ test/
```

### Lint 规则

项目使用 Flutter 默认的 lint 规则。请确保代码通过静态分析：

```bash
flutter analyze
```

---

## Git 工作流

### 分支策略

```
main (稳定) ──┐
              ├── v1.0.0 ── release
              ├── v1.1.0
              └── ...
develop (开发) ─┐
                ├── feature/file-scanner
                ├── feature/dark-mode
                ├── bugfix/fix-crash
                └── release/v1.2.0
```

### 分支命名

| 类型 | 格式 | 示例 |
|------|------|------|
| 功能 | `feature/功能名` | `feature/add-image-preview` |
| 修复 | `bugfix/问题描述` | `bugfix/fix-null-safety-error` |
| 发布 | `release/版本号` | `release/v1.2.0` |
| 热修复 | `hotfix/问题描述` | `hotfix/fix-build-failure` |

### 提交信息规范

本项目采用 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

**Type 类型：**

| 类型 | 描述 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(file-scanner): add recursive directory scanning` |
| `fix` | 问题修复 | `fix(file-dedup): correct hash comparison logic` |
| `docs` | 文档更新 | `docs: update README with installation guide` |
| `style` | 代码格式 | `style: fix indentation in app.dart` |
| `refactor` | 重构 | `refactor(shared): extract common widget to shared_widgets` |
| `test` | 测试 | `test(file-scanner): add unit tests for scanner_utils` |
| `chore` | 杂务 | `chore: update dependencies` |

**Scope（可选）：** 模块名，如 `file-scanner`、`system-control`、`core` 等。

---

## Pull Request 流程

1. **Fork 仓库** 并在你的 GitHub 账户上创建功能分支
2. **提交更改** 并确保代码通过测试和分析
3. **Push 到 GitHub** 你的 fork 仓库
4. **创建 Pull Request** 到 `develop` 分支
5. **Code Review** - 维护者会审核你的代码并提供反馈
6. **合并** - 审核通过后合并到 develop 分支

### PR 要求

- [ ] 描述清楚此 PR 的目的
- [ ] 提供相关 issue 的链接（如有）
- [ ] 确保所有测试通过
- [ ] 确保 `flutter analyze` 无错误
- [ ] 如有 UI 变更，附上截图

---

## 报告问题

如果你遇到 bug 或有功能建议，请创建 [Issue](https://github.com/FREE-AI-APP/ai_app/issues)。

### Bug 报告模板

```markdown
**描述问题**
简洁描述你遇到的问题。

**复现步骤**
1. 打开...
2. 点击...
3. 问题出现

**预期行为**
描述你期望发生什么。

**截图**
如有，请附上截图。

**环境信息**
- OS: Windows 11 / Android 14
- Flutter: 3.41.0
- 应用版本: v3.0.0
```

---

## 许可证

参与贡献即表示你同意遵守本项目的 [MIT 许可证](LICENSE)。
