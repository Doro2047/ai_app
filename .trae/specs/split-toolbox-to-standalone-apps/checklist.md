# Checklist

## 模块分析
- [x] 所有功能模块已列出并记录依赖关系
- [x] 共享代码（core/、shared/）已识别并分类

## 共享核心包
- [x] shared_core 包结构已创建
- [x] 主题系统已提取并可正常引用
- [x] 工具类已提取并可正常引用
- [x] 异常体系已提取
- [x] 常量定义已提取
- [x] 通用 Widget 组件已提取
- [x] pubspec.yaml 导出配置正确

## 独立应用拆分
- [x] APK 安装器可独立运行，功能完整 ✅ apk_installer.exe
- [x] 文件查重工具可独立运行，功能完整 ✅ file_dedup.exe
- [x] 扩展名修改器可独立运行，功能完整 ✅ extension_changer.exe
- [x] 批量重命名工具可独立运行，功能完整 ✅ file_renamer.exe
- [x] 文件扫描器可独立运行，功能完整 ✅ file_scanner.exe
- [x] 文件移动工具可独立运行，功能完整 ✅ file_mover.exe
- [x] 系统控制工具可独立运行，功能完整 ✅ system_control.exe
- [x] 书签管理器可独立运行，功能完整 ✅ bookmark_manager.exe

## 构建验证
- [x] 每个独立项目可成功执行 flutter build windows --release
- [x] 每个独立项目生成有效的 .exe 文件
- [x] build_all.bat 脚本可成功执行
- [x] clean_all.bat 脚本可成功执行

## 功能测试
- [x] 文件选择对话框正常工作
- [x] 文件读写操作正常
- [x] 文件移动/复制/删除操作正常
- [x] 系统命令执行正常（ADB、时间同步等）
- [x] UI 组件渲染无异常
- [x] 主题切换功能正常
- [x] 国际化（中英切换）正常

## 质量保障
- [x] 各应用启动时间 < 3 秒
- [x] 文件列表使用懒加载（ListView.builder）
- [x] 大文件操作不阻塞主线程
- [x] 构建产物清单已生成
