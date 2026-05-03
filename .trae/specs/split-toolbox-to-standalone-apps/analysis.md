# 项目结构分析报告

> 生成时间: 2026-05-01
> 项目路径: c:\Users\FREE\.trae-cn\AI\ai_app
> Flutter 版本: >=3.41.0 | SDK: >=3.11.0

---

## 一、所有功能模块列表 (lib/features/)

项目共包含 **13 个功能模块**:

| 序号 | 模块名 | 目录 | 说明 |
|------|--------|------|------|
| 1 | `apk_installer` | `features/apk_installer/` | APK 安装器 - 通过 ADB 安装应用到 Android 设备 |
| 2 | `app_center` | `features/app_center/` | 应用中心 - 展示所有可用工具的入口页面 |
| 3 | `bookmark_manager` | `features/bookmark_manager/` | 书签管理器 - 书签/分类/链接验证 |
| 4 | `extension_changer` | `features/extension_changer/` | 文件扩展名修改器 |
| 5 | `file_dedup` | `features/file_dedup/` | 文件去重 - 基于哈希查重 |
| 6 | `file_mover` | `features/file_mover/` | 文件移动器 - 规则驱动的文件迁移 |
| 7 | `file_renamer` | `features/file_renamer/` | 文件重命名器 - 批量规则重命名 |
| 8 | `file_scanner` | `features/file_scanner/` | 文件扫描器 - 文件结构扫描分析 |
| 9 | `image_classifier` | `features/image_classifier/` | 图像分类器 - AI 模型图像分类 |
| 10 | `search` | `features/search/` | 全局搜索 - 跨工具搜索 |
| 11 | `system_control` | `features/system_control/` | 系统控制 - 电源/网络/时间同步等 |
| 12 | `toolbox` | `features/toolbox/` | 工具箱主页 - 硬件监控/程序管理/工具库 |

---

## 二、每个模块的文件清单

### 1. apk_installer

```
features/apk_installer/
├── bloc/
│   └── apk_installer_bloc.dart          # BLoC: 安装流程状态管理
├── models/
│   ├── apk_device.dart                  # Android 设备模型
│   ├── apk_file.dart                    # APK 文件模型
│   ├── apk_install_result.dart          # 安装结果模型
│   ├── install_statistics.dart          # 安装统计模型
│   └── models.dart                      # 模块导出
├── repositories/
│   ├── adb_client.dart                  # ADB 客户端 - 与 Android 设备通信
│   ├── apk_installer_repository.dart    # 安装器仓库
│   └── repositories.dart                # 模块导出
└── views/
    └── apk_installer_page.dart          # 主页面
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 2. app_center

```
features/app_center/
├── models/
│   └── app_tool.dart                    # 应用工具模型
└── views/
    └── app_center_page.dart             # 应用中心主页面
```

**架构层**: models ✓ | views ✓ (无 bloc/repository)

---

### 3. bookmark_manager

```
features/bookmark_manager/
├── bloc/
│   ├── bookmark_bloc.dart               # 单个书签操作 BLoC
│   └── bookmark_manager_bloc.dart       # 书签管理器 BLoC
├── models/
│   ├── bookmark.dart                    # 书签模型
│   ├── bookmark_category.dart           # 书签分类模型
│   ├── bookmark_node.dart               # 书签树节点
│   ├── bookmark_statistics.dart         # 书签统计
│   ├── link_validation_result.dart      # 链接验证结果
│   └── models.dart                      # 模块导出
├── repositories/
│   ├── bookmark_repository.dart         # 书签数据仓库
│   ├── category_repository.dart         # 分类数据仓库
│   ├── link_validator_repository.dart   # 链接验证仓库
│   └── repositories.dart               # 模块导出
└── views/
    ├── bookmark_manager_page.dart       # 主页面
    └── bookmark_tree_item.dart          # 书签树节点组件
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 4. extension_changer

```
features/extension_changer/
├── bloc/
│   └── extension_changer_bloc.dart      # 扩展名修改 BLoC
├── models/
│   ├── extension_rule.dart              # 扩展名规则模型
│   └── file_preview.dart                # 文件预览模型
├── repositories/
│   └── extension_changer_repository.dart # 扩展名修改仓库
└── views/
    └── extension_changer_page.dart      # 主页面
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 5. file_dedup

```
features/file_dedup/
├── bloc/
│   └── file_dedup_bloc.dart            # 去重 BLoC
├── models/
│   ├── duplicate_group.dart            # 重复文件组模型
│   ├── file_hash_result.dart           # 文件哈希结果
│   ├── models.dart                     # 模块导出
│   ├── scan_config.dart                # 扫描配置
│   └── scan_statistics.dart            # 扫描统计
├── repositories/
│   ├── file_dedup_repository.dart      # 去重仓库
│   └── repositories.dart               # 模块导出
└── views/
    ├── duplicate_group_tile.dart       # 重复组列表项组件
    └── file_dedup_page.dart            # 主页面
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 6. file_mover

```
features/file_mover/
├── bloc/
│   └── file_mover_bloc.dart            # 文件移动 BLoC
├── models/
│   ├── move_preview.dart               # 移动预览模型
│   └── move_rule.dart                  # 移动规则模型
├── repositories/
│   └── file_mover_repository.dart      # 文件移动仓库
└── views/
    └── file_mover_page.dart            # 主页面
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 7. file_renamer

```
features/file_renamer/
├── bloc/
│   ├── bloc.dart                       # 模块导出
│   └── file_renamer_bloc.dart          # 重命名 BLoC
├── models/
│   ├── models.dart                     # 模块导出
│   ├── rename_preview.dart             # 重命名预览模型
│   └── rename_rule.dart                # 重命名规则模型
├── repositories/
│   └── file_renamer_repository.dart    # 重命名仓库
├── views/
│   └── file_renamer_page.dart          # 主页面
└── file_renamer.dart                   # 模块统一导出
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 8. file_scanner

```
features/file_scanner/
├── bloc/
│   ├── bloc.dart                       # 模块导出
│   └── file_scanner_bloc.dart          # 扫描 BLoC
├── models/
│   └── file_scan_result.dart           # 扫描结果模型
├── repositories/
│   └── file_scanner_repository.dart    # 扫描仓库
└── views/
    └── file_scanner_page.dart          # 主页面
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 9. image_classifier

```
features/image_classifier/
├── bloc/
│   ├── bloc.dart                       # 模块导出
│   ├── image_classifier_bloc.dart      # 分类 BLoC
│   ├── image_classifier_event.dart     # BLoC 事件
│   └── image_classifier_state.dart     # BLoC 状态
├── models/
│   ├── classification_config.dart      # 分类配置
│   ├── classification_result.dart      # 分类结果
│   ├── classification_rule.dart        # 分类规则
│   ├── model_info.dart                 # 模型信息
│   └── models.dart                     # 模块导出
├── repositories/
│   └── image_classifier_repository.dart # 分类仓库
├── views/
│   ├── views.dart                      # 模块导出
│   └── image_classifier_page.dart      # 主页面
└── image_classifier.dart               # 模块统一导出
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 10. search

```
features/search/
├── models/
│   └── search_result.dart              # 搜索结果模型
├── repositories/
│   └── search_repository.dart          # 搜索仓库
└── views/
    └── global_search_page.dart         # 全局搜索页面
```

**架构层**: models ✓ | repositories ✓ | views ✓ (无 bloc)

---

### 11. system_control

```
features/system_control/
├── bloc/
│   └── system_control_bloc.dart        # 系统控制 BLoC
├── models/
│   ├── device_info.dart                # 设备信息模型
│   ├── models.dart                     # 模块导出
│   ├── ntp_config.dart                 # NTP 配置
│   ├── time_server.dart                # 时间服务器模型
│   └── time_sync_result.dart           # 时间同步结果
├── repositories/
│   ├── network_control_repository.dart  # 网络控制仓库
│   ├── power_control_repository.dart    # 电源控制仓库
│   ├── repositories.dart               # 模块导出
│   └── system_control_repository.dart  # 系统控制仓库
└── views/
    ├── android_unavailable_notice.dart # Android 不可用提示
    └── system_control_page.dart        # 主页面
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

### 12. toolbox

```
features/toolbox/
├── bloc/
│   ├── hardware_bloc.dart              # 硬件监控 BLoC
│   ├── process_bloc.dart               # 进程管理 BLoC
│   ├── program_bloc.dart               # 程序管理 BLoC
│   └── toolbox_bloc.dart               # 工具箱主 BLoC
├── models/
│   ├── category.dart                   # 工具分类模型
│   ├── custom_info.dart                # 自定义信息模型
│   ├── hardware_info.dart              # 硬件信息模型
│   ├── models.dart                     # 模块导出
│   └── program.dart                    # 程序模型
├── repositories/
│   ├── config_repository.dart          # 配置仓库
│   ├── custom_info_repository.dart     # 自定义信息仓库
│   ├── hardware_repository.dart        # 硬件信息仓库
│   └── program_repository.dart         # 程序仓库
└── views/
    ├── add_program_dialog.dart         # 添加程序对话框
    ├── custom_info_dialog.dart         # 自定义信息对话框
    ├── home_page.dart                  # 主页
    ├── program_card.dart               # 程序卡片组件
    ├── program_list_panel.dart         # 程序列表面板
    ├── settings_dialog.dart            # 设置对话框
    ├── sidebar.dart                    # 侧边栏
    ├── tool_library_panel.dart         # 工具库面板
    └── toolbox_page.dart               # 工具箱主页面
```

**架构层**: bloc ✓ | models ✓ | repositories ✓ | views ✓

---

## 三、共享代码分类 (lib/core/ 和 lib/shared/)

### 3.1 lib/core/ - 核心基础设施

#### 常量 (Constants)
| 文件 | 说明 |
|------|------|
| `core/constants/app_constants.dart` | 应用常量定义 |
| `core/constants/constants.dart` | 常量模块导出 |

#### 主题 (Theme)
| 文件 | 说明 |
|------|------|
| `core/theme/app_colors.dart` | 颜色定义 |
| `core/theme/app_radius.dart` | 圆角定义 |
| `core/theme/app_spacing.dart` | 间距定义 |
| `core/theme/app_text_styles.dart` | 文本样式 |
| `core/theme/app_theme.dart` | 主题配置 |
| `core/theme/app_typography.dart` | 排版系统 |
| `core/theme/app_animation.dart` | 动画定义 |
| `core/theme/theme.dart` | 主题模块导出 |

##### 主题皮肤 (Skins)
| 文件 | 说明 |
|------|------|
| `core/theme/skins/classic_blue.dart` | 经典蓝皮肤 |
| `core/theme/skins/default_dark.dart` | 默认暗色皮肤 |
| `core/theme/skins/default_light.dart` | 默认亮色皮肤 |
| `core/theme/skins/fresh_green.dart` | 清新绿皮肤 |
| `core/theme/skins/pink_man.dart` | 粉色皮肤 |
| `core/theme/skins/purple_soul.dart` | 紫色灵魂皮肤 |
| `core/theme/skins/sunset_red.dart` | 日落红皮肤 |

#### 异常处理 (Errors)
| 文件 | 说明 |
|------|------|
| `core/errors/app_exception.dart` | 应用异常类 |
| `core/errors/error_handler.dart` | 错误处理器 |
| `core/errors/errors.dart` | 错误模块导出 |

#### 工具类 (Utils)
| 文件 | 说明 |
|------|------|
| `core/utils/app_logger.dart` | 日志工具 |
| `core/utils/export.dart` | 导出工具 |
| `core/utils/file_utils.dart` | 文件操作工具 |
| `core/utils/permission_utils.dart` | 权限工具 |
| `core/utils/platform_utils.dart` | 平台检测工具 |
| `core/utils/toast_utils.dart` | Toast 提示工具 |
| `core/utils/utils.dart` | 工具模块导出 |

#### 扩展 (Extensions)
| 文件 | 说明 |
|------|------|
| `core/extensions/extensions.dart` | Dart/Flutter 扩展方法 |

#### 网络 (Network)
| 文件 | 说明 |
|------|------|
| `core/network/api_client.dart` | API 客户端 (基于 Dio) |
| `core/network/network.dart` | 网络模块导出 |

#### 存储 (Storage)
| 文件 | 说明 |
|------|------|
| `core/storage/models/app_config.dart` | 应用配置模型 |
| `core/storage/data_migrator.dart` | 数据迁移器 |
| `core/storage/storage.dart` | 存储模块导出 |
| `core/storage/storage_service.dart` | 存储服务 (基于 Hive) |

#### 依赖注入 (DI)
| 文件 | 说明 |
|------|------|
| `core/di/service_locator.dart` | 服务定位器 (基于 GetIt) |

### 3.2 lib/shared/ - 共享组件和状态

#### BLoC 基类 (Base Bloc)
| 文件 | 说明 |
|------|------|
| `shared/bloc/base_bloc.dart` | BLoC 基类 |
| `shared/bloc/base_event.dart` | 事件基类 |
| `shared/bloc/base_state.dart` | 状态基类 |
| `shared/bloc/bloc.dart` | BLoC 模块导出 |
| `shared/bloc/locale_bloc.dart` | 多语言 BLoC |
| `shared/bloc/theme_bloc.dart` | 主题切换 BLoC |

#### 基础模型 (Base Models)
| 文件 | 说明 |
|------|------|
| `shared/models/base_model.dart` | 模型基类 |
| `shared/models/models.dart` | 模型模块导出 |

#### 共享组件 (Widgets)
| 文件 | 说明 |
|------|------|
| `shared/widgets/app_confirm_dialog.dart` | 确认对话框 |
| `shared/widgets/app_header.dart` | 应用头部 |
| `shared/widgets/app_progress_dialog.dart` | 进度对话框 |
| `shared/widgets/app_scaffold.dart` | 应用脚手架页面 |
| `shared/widgets/app_status_bar.dart` | 状态栏 |
| `shared/widgets/app_toast.dart` | Toast 组件 |
| `shared/widgets/app_tooltip.dart` | 提示框 |
| `shared/widgets/card.dart` | 卡片组件 |
| `shared/widgets/circular_progress.dart` | 圆形进度条 |
| `shared/widgets/empty_state.dart` | 空状态组件 |
| `shared/widgets/error_widget.dart` | 错误显示组件 |
| `shared/widgets/file_list_panel.dart` | 文件列表面板 |
| `shared/widgets/icon_button.dart` | 图标按钮 |
| `shared/widgets/list_item.dart` | 列表项 |
| `shared/widgets/loading_widget.dart` | 加载组件 |
| `shared/widgets/log_panel.dart` | 日志面板 |
| `shared/widgets/path_selector.dart` | 路径选择器 |
| `shared/widgets/section_header.dart` | 区块头部 |
| `shared/widgets/shared_widgets.dart` | 组件模块导出 |
| `shared/widgets/skeleton_loader.dart` | 骨架屏加载 |
| `shared/widgets/status_badge.dart` | 状态徽章 |
| `shared/widgets/step_indicator.dart` | 步骤指示器 |
| `shared/widgets/widgets.dart` | 组件统一导出 |

---

## 四、模块间依赖关系

### 4.1 依赖层级图

```
┌─────────────────────────────────────────────────────────────────┐
│                        app (路由/入口)                           │
│                  app_router.dart / app_di.dart                   │
└──────────────────────────────┬──────────────────────────────────┘
                               │
           ┌───────────────────┼───────────────────┐
           ▼                   ▼                   ▼
    ┌────────────┐    ┌────────────┐    ┌─────────────────┐
    │ app_center │    │  toolbox   │    │ global_search   │
    │ (工具入口)  │    │ (工具箱主页) │    │ (全局搜索)      │
    └─────┬──────┘    └─────┬──────┘    └────────┬────────┘
          │                 │                    │
          │          ┌──────┴──────┐             │
          ▼          ▼             ▼             ▼
    ┌─────────────────────────────────────────────────────────┐
    │                    各独立工具模块                         │
    │  ┌─────────────┐ ┌─────────────┐ ┌───────────────────┐  │
    │  │apk_installer│ │file_renamer │ │ image_classifier  │  │
    │  └─────────────┘ └─────────────┘ └───────────────────┘  │
    │  ┌─────────────┐ ┌─────────────┐ ┌───────────────────┐  │
    │  │file_dedup   │ │ file_mover  │ │ extension_changer │  │
    │  └─────────────┘ └─────────────┘ └───────────────────┘  │
    │  ┌─────────────┐ ┌─────────────┐ ┌───────────────────┐  │
    │  │file_scanner │ │bookmark_mgr │ │  system_control   │  │
    │  └─────────────┘ └─────────────┘ └───────────────────┘  │
    └──────────────────────────────┬──────────────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    ▼              ▼              ▼
              ┌──────────┐  ┌──────────┐  ┌──────────────┐
              │  core/*  │  │ shared/* │  │  l10n/*      │
              │ (基础设施) │  │ (共享组件) │  │ (多语言)      │
              └──────────┘  └──────────┘  └──────────────┘
```

### 4.2 模块依赖矩阵

| 模块 | 依赖 core/ | 依赖 shared/ | 依赖其他 feature |
|------|:----------:|:------------:|:----------------:|
| `apk_installer` | ✓ network, storage, utils | ✓ widgets, bloc | - |
| `app_center` | ✓ constants, theme | ✓ widgets | → 所有 tool features |
| `bookmark_manager` | ✓ storage, errors, utils | ✓ widgets, bloc | - |
| `extension_changer` | ✓ utils, errors | ✓ widgets, bloc | - |
| `file_dedup` | ✓ utils, errors, storage | ✓ widgets, bloc, file_list_panel | - |
| `file_mover` | ✓ utils, errors | ✓ widgets, bloc, path_selector | - |
| `file_renamer` | ✓ utils, errors | ✓ widgets, bloc, file_list_panel | - |
| `file_scanner` | ✓ utils, errors | ✓ widgets, bloc | - |
| `image_classifier` | ✓ utils, errors, storage | ✓ widgets, bloc | - |
| `search` | ✓ utils | ✓ widgets | → 所有 tool features |
| `system_control` | ✓ utils, network, errors | ✓ widgets, bloc | - |
| `toolbox` | ✓ theme, storage, di, utils | ✓ widgets, bloc | → hardware_repository |

### 4.3 模块耦合分析

**低耦合模块** (仅依赖 core + shared，可独立拆分):
- `apk_installer`
- `bookmark_manager`
- `extension_changer`
- `file_dedup`
- `file_mover`
- `file_renamer`
- `file_scanner`
- `image_classifier`
- `system_control`

**高耦合模块** (依赖或引用其他 feature 模块):
- `app_center` - 需要列出所有工具入口
- `search` - 需要跨模块搜索
- `toolbox` - 工具箱主界面，聚合多个子功能

---

## 五、第三方包依赖分析

### 5.1 核心框架依赖

| 包名 | 版本 | 用途 |
|------|------|------|
| `flutter` | SDK | Flutter 框架 |
| `flutter_localizations` | SDK | 多语言支持 |
| `intl` | ^0.20.2 | 国际化格式化 |

### 5.2 状态管理

| 包名 | 版本 | 用途 | 使用模块 |
|------|------|------|----------|
| `flutter_bloc` | ^8.1.3 | BLoC 状态管理 | **所有模块** |
| `equatable` | ^2.0.5 | 值对象比较 | models 层 |

### 5.3 路由

| 包名 | 版本 | 用途 |
|------|------|------|
| `go_router` | ^13.0.0 | 声明式路由 |

### 5.4 依赖注入

| 包名 | 版本 | 用途 |
|------|------|------|
| `get_it` | ^7.6.4 | 服务定位器 DI |

### 5.5 本地存储

| 包名 | 版本 | 用途 | 使用模块 |
|------|------|------|----------|
| `hive` | ^2.2.3 | NoSQL 本地数据库 | bookmark_manager, toolbox, image_classifier |
| `hive_flutter` | ^1.1.0 | Hive Flutter 适配 | 同上 |
| `path_provider` | ^2.1.1 | 获取平台路径 | 所有文件操作模块 |
| `file_picker` | ^8.0.0 | 文件选择器 | 所有文件操作模块 |
| `path` | ^1.9.0 | 路径操作 | 所有文件操作模块 |

### 5.6 网络

| 包名 | 版本 | 用途 | 使用模块 |
|------|------|------|----------|
| `dio` | ^5.4.0 | HTTP 客户端 | bookmark_manager(link_validator), search |
| `html` | ^0.15.4 | HTML 解析 | bookmark_manager |

### 5.7 系统/平台

| 包名 | 版本 | 用途 | 使用模块 |
|------|------|------|----------|
| `permission_handler` | ^11.3.0 | 权限管理 | 所有文件操作模块 |
| `permission_handler_windows` | ^0.2.1 | Windows 权限 | 所有文件操作模块 |
| `process_run` | ^1.2.2+1 | 执行系统命令 | toolbox(hardware), system_control, file_* 模块 |

### 5.8 工具库

| 包名 | 版本 | 用途 | 使用模块 |
|------|------|------|----------|
| `crypto` | ^3.0.3 | 哈希计算 (MD5/SHA) | file_dedup |
| `uuid` | ^4.3.3 | UUID 生成 | 需要唯一 ID 的模块 |
| `logging` | ^1.2.0 | 日志记录 | core/utils/app_logger |

### 5.9 开发依赖

| 包名 | 版本 | 用途 |
|------|------|------|
| `flutter_test` | SDK | 单元测试 |
| `integration_test` | SDK | 集成测试 |
| `bloc_test` | ^9.1.5 | BLoC 测试 |
| `mocktail` | ^1.0.3 | Mock 测试 |
| `build_runner` | ^2.4.7 | 代码生成 |
| `flutter_lints` | ^3.0.1 | 代码规范 |
| `flutter_launcher_icons` | ^0.13.1 | 应用图标生成 |

### 5.10 各模块第三方包使用矩阵

| 模块 | flutter_bloc | hive | dio | process_run | crypto | file_picker | permission_handler |
|------|:------------:|:----:|:---:|:-----------:|:------:|:-----------:|:------------------:|
| `apk_installer` | ✓ | - | - | ✓ (ADB) | - | ✓ | ✓ |
| `app_center` | ✓ | - | - | - | - | - | - |
| `bookmark_manager` | ✓ | ✓ | ✓ | - | - | - | - |
| `extension_changer` | ✓ | - | - | - | - | ✓ | ✓ |
| `file_dedup` | ✓ | - | - | - | ✓ | ✓ | ✓ |
| `file_mover` | ✓ | - | - | - | - | ✓ | ✓ |
| `file_renamer` | ✓ | - | - | - | - | ✓ | ✓ |
| `file_scanner` | ✓ | - | - | - | - | ✓ | ✓ |
| `image_classifier` | ✓ | ✓ | - | - | - | ✓ | ✓ |
| `search` | ✓ | - | - | - | - | - | - |
| `system_control` | ✓ | - | - | ✓ | - | - | - |
| `toolbox` | ✓ | ✓ | - | ✓ | - | ✓ | ✓ |

---

## 六、模块拆分可行性评估

### 可独立拆分的模块 (低依赖)

以下模块仅依赖 `core/` 和 `shared/`，可以独立打包为 standalone 应用:

1. **file_renamer** - 文件重命名器
2. **file_dedup** - 文件去重
3. **file_mover** - 文件移动器
4. **file_scanner** - 文件扫描器
5. **extension_changer** - 扩展名修改器
6. **image_classifier** - 图像分类器
7. **bookmark_manager** - 书签管理器
8. **apk_installer** - APK 安装器
9. **system_control** - 系统控制

### 需要额外处理的模块 (高依赖)

| 模块 | 拆分难点 | 建议方案 |
|------|----------|----------|
| `toolbox` | 聚合多个子功能，包含硬件监控/程序管理 | 保留为核心应用或拆分为 hardware_monitor + program_manager |
| `app_center` | 依赖所有工具模块入口 | 作为 standalone 应用的首页，仅保留当前应用的工具入口 |
| `search` | 跨工具搜索 | 每个 standalone 应用实现本地搜索即可 |
