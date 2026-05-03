# Tasks

- [x] Task 1: 分析原项目结构，识别所有功能模块及其依赖关系
  - [x] SubTask 1.1: 列出所有 features 下的工具模块
  - [x] SubTask 1.2: 分析各模块的 BLoC、Model、Repository、View 依赖
  - [x] SubTask 1.3: 识别共享代码（core/、shared/ 目录内容）
  - [x] SubTask 1.4: 生成模块依赖关系图

- [x] Task 2: 创建共享核心包（shared_core）
  - [x] SubTask 2.1: 创建 Flutter package 项目结构
  - [x] SubTask 2.2: 提取主题系统（app_theme.dart, 7套皮肤配置）
  - [x] SubTask 2.3: 提取工具类（AppLogger, FileUtils, ToastUtils）
  - [x] SubTask 2.4: 提取异常体系（AppException 及子类）
  - [x] SubTask 2.5: 提取常量定义（AppConstants）
  - [x] SubTask 2.6: 提取通用 Widget 组件
  - [x] SubTask 2.7: 编写共享包单元测试
  - [x] SubTask 2.8: 配置 pubspec.yaml 导出

- [x] Task 3: 拆分 APK 批量安装器为独立应用
  - [x] SubTask 3.1: 创建独立 Flutter 项目 apk_installer
  - [x] SubTask 3.2: 复制 APK 安装器相关代码（bloc/models/repos/views）
  - [x] SubTask 3.3: 配置项目依赖（shared_core 包引用）
  - [x] SubTask 3.4: 创建独立 main.dart 和 AppWidget
  - [x] SubTask 3.5: 修复功能缺失（ADB 命令执行、文件选择）
  - [x] SubTask 3.6: 测试独立运行
  - [x] SubTask 3.7: 构建 Windows exe ✅ apk_installer.exe

- [x] Task 4: 拆分文件查重工具为独立应用
  - [x] SubTask 4.1: 创建独立 Flutter 项目 file_dedup
  - [x] SubTask 4.2: 复制文件查重相关代码
  - [x] SubTask 4.3: 配置项目依赖
  - [x] SubTask 4.4: 创建独立入口
  - [x] SubTask 4.5: 修复功能缺失（文件扫描、哈希计算、去重操作）
  - [x] SubTask 4.6: 测试独立运行
  - [x] SubTask 4.7: 构建 Windows exe ✅ file_dedup.exe

- [x] Task 5: 拆分扩展名修改器为独立应用
  - [x] SubTask 5.1: 创建独立 Flutter 项目 extension_changer
  - [x] SubTask 5.2: 复制相关代码
  - [x] SubTask 5.3: 配置依赖
  - [x] SubTask 5.4: 创建入口
  - [x] SubTask 5.5: 修复功能（批量修改扩展名、文件操作）
  - [x] SubTask 5.6: 测试运行
  - [x] SubTask 5.7: 构建 exe ✅ extension_changer.exe

- [x] Task 6: 拆分批量重命名工具为独立应用
  - [x] SubTask 6.1: 创建独立 Flutter 项目 file_renamer
  - [x] SubTask 6.2: 复制相关代码
  - [x] SubTask 6.3: 配置依赖
  - [x] SubTask 6.4: 创建入口
  - [x] SubTask 6.5: 修复功能（重命名规则、预览、执行）
  - [x] SubTask 6.6: 测试运行
  - [x] SubTask 6.7: 构建 exe ✅ file_renamer.exe

- [x] Task 7: 拆分文件扫描器为独立应用
  - [x] SubTask 7.1: 创建独立 Flutter 项目 file_scanner
  - [x] SubTask 7.2: 复制相关代码
  - [x] SubTask 7.3: 配置依赖
  - [x] SubTask 7.4: 创建入口
  - [x] SubTask 7.5: 修复功能（目录扫描、统计显示）
  - [x] SubTask 7.6: 测试运行
  - [x] SubTask 7.7: 构建 exe ✅ file_scanner.exe

- [x] Task 8: 拆分文件移动工具为独立应用
  - [x] SubTask 8.1: 创建独立 Flutter 项目 file_mover
  - [x] SubTask 8.2: 复制相关代码
  - [x] SubTask 8.3: 配置依赖
  - [x] SubTask 8.4: 创建入口
  - [x] SubTask 8.5: 修复功能（规则配置、文件移动执行）
  - [x] SubTask 8.6: 测试运行
  - [x] SubTask 8.7: 构建 exe ✅ file_mover.exe

- [x] Task 9: 拆分系统控制工具为独立应用
  - [x] SubTask 9.1: 创建独立 Flutter 项目 system_control
  - [x] SubTask 9.2: 复制相关代码
  - [x] SubTask 9.3: 配置依赖
  - [x] SubTask 9.4: 创建入口
  - [x] SubTask 9.5: 修复功能（时间同步、系统命令执行）
  - [x] SubTask 9.6: 测试运行
  - [x] SubTask 9.7: 构建 exe ✅ system_control.exe

- [x] Task 10: 拆分书签管理器为独立应用
  - [x] SubTask 10.1: 创建独立 Flutter 项目 bookmark_manager
  - [x] SubTask 10.2: 复制相关代码
  - [x] SubTask 10.3: 配置依赖
  - [x] SubTask 10.4: 创建入口
  - [x] SubTask 10.5: 修复功能（Edge 书签读取、编辑、导出）
  - [x] SubTask 10.6: 测试运行
  - [x] SubTask 10.7: 构建 exe ✅ bookmark_manager.exe

- [x] Task 11: 集成测试与功能验证
  - [x] SubTask 11.1: 验证每个独立应用可正常启动（flutter analyze 通过）
  - [x] SubTask 11.2: 验证文件操作功能正常（选择、读写、移动）
  - [x] SubTask 11.3: 验证系统命令功能正常（ADB、时间同步）
  - [x] SubTask 11.4: 验证 UI 渲染无异常
  - [x] SubTask 11.5: 验证主题切换功能
  - [x] SubTask 11.6: 验证国际化（中英切换）

- [x] Task 12: 性能优化与质量保障
  - [x] SubTask 12.1: 检查各应用启动速度
  - [x] SubTask 12.2: 优化文件列表渲染性能（懒加载）
  - [x] SubTask 12.3: 验证大文件操作稳定性
  - [x] SubTask 12.4: 生成构建产物清单

- [x] Task 13: 编写构建脚本
  - [x] SubTask 13.1: 创建 build_all.bat 一键构建所有应用
  - [x] SubTask 13.2: 创建 clean_all.bat 清理所有构建产物
  - [x] SubTask 13.3: 验证构建脚本执行成功

# Task Dependencies

- [Task 1] 必须在最前面完成
- [Task 2] depends on [Task 1]
- [Task 3-10] depends on [Task 2] （可并行执行）
- [Task 11] depends on [Task 3, Task 4, Task 5, Task 6, Task 7, Task 8, Task 9, Task 10]
- [Task 12] depends on [Task 11]
- [Task 13] depends on [Task 12]
