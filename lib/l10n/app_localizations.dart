import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// 应用标题
  ///
  /// In zh, this message translates to:
  /// **'AI Apps 工具集'**
  String get appTitle;

  /// 首页导航标签
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// 设置页面标题
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// 加载状态提示
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// 错误提示
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error;

  /// 重试操作
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// 取消操作
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// 确认操作
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// 删除操作
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// 保存操作
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// 编辑操作
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// 搜索操作
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// 空数据提示
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// 网络错误提示
  ///
  /// In zh, this message translates to:
  /// **'网络错误'**
  String get networkError;

  /// 404页面提示
  ///
  /// In zh, this message translates to:
  /// **'页面未找到'**
  String get pageNotFound;

  /// 返回首页按钮
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get backToHome;

  /// 确定按钮
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get ok;

  /// 关闭操作
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// 添加操作
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// 刷新操作
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// 全选操作
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get select_all;

  /// 导出操作
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get export;

  /// 导入操作
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get import;

  /// 就绪状态
  ///
  /// In zh, this message translates to:
  /// **'就绪'**
  String get ready;

  /// 警告提示
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warning;

  /// 成功提示
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get success;

  /// 信息提示
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get info;

  /// 肯定回答
  ///
  /// In zh, this message translates to:
  /// **'是'**
  String get yes;

  /// 否定回答
  ///
  /// In zh, this message translates to:
  /// **'否'**
  String get no;

  /// 应用操作
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get apply;

  /// 工具分类
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get tools;

  /// 帮助
  ///
  /// In zh, this message translates to:
  /// **'帮助'**
  String get help;

  /// 关于页面
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// 退出操作
  ///
  /// In zh, this message translates to:
  /// **'退出'**
  String get exit;

  /// 文件
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get file;

  /// 视图
  ///
  /// In zh, this message translates to:
  /// **'视图'**
  String get view;

  /// 语言设置
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// 主题设置
  ///
  /// In zh, this message translates to:
  /// **'主题'**
  String get theme;

  /// 浅色主题模式
  ///
  /// In zh, this message translates to:
  /// **'浅色模式'**
  String get light_mode;

  /// 深色主题模式
  ///
  /// In zh, this message translates to:
  /// **'深色模式'**
  String get dark_mode;

  /// 跟随系统主题
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get follow_system;

  /// 最近使用
  ///
  /// In zh, this message translates to:
  /// **'最近使用'**
  String get recent;

  /// 收藏
  ///
  /// In zh, this message translates to:
  /// **'收藏'**
  String get favorites;

  /// 全部
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// 名称字段
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get name;

  /// 描述字段
  ///
  /// In zh, this message translates to:
  /// **'描述'**
  String get description;

  /// 状态字段
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get status;

  /// 操作字段
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get action;

  /// 时间字段
  ///
  /// In zh, this message translates to:
  /// **'时间'**
  String get time;

  /// 大小字段
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get size;

  /// 类型字段
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get type;

  /// 路径字段
  ///
  /// In zh, this message translates to:
  /// **'路径'**
  String get path;

  /// 进度
  ///
  /// In zh, this message translates to:
  /// **'进度'**
  String get progress;

  /// 完成状态
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get completed;

  /// 失败状态
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get failed;

  /// 版本信息
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get version;

  /// 更新操作
  ///
  /// In zh, this message translates to:
  /// **'更新'**
  String get update;

  /// 下载操作
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get download;

  /// 安装操作
  ///
  /// In zh, this message translates to:
  /// **'安装'**
  String get install;

  /// 检查更新操作
  ///
  /// In zh, this message translates to:
  /// **'检查更新'**
  String get check_update;

  /// 无更新可用
  ///
  /// In zh, this message translates to:
  /// **'暂无更新'**
  String get no_update;

  /// 有新版本
  ///
  /// In zh, this message translates to:
  /// **'新版本可用'**
  String get new_version_available;

  /// 已是最新版本
  ///
  /// In zh, this message translates to:
  /// **'当前已是最新版本'**
  String get already_latest;

  /// 带名字的问候语
  ///
  /// In zh, this message translates to:
  /// **'你好，{name}！'**
  String hello_name(String name);

  /// 项目数量
  ///
  /// In zh, this message translates to:
  /// **'{count} 个项目'**
  String item_count(int count);

  /// 数据迁移标题
  ///
  /// In zh, this message translates to:
  /// **'数据迁移'**
  String get migration_title;

  /// 检测旧版数据中
  ///
  /// In zh, this message translates to:
  /// **'正在检测旧版数据...'**
  String get migration_detecting;

  /// 发现旧版数据提示
  ///
  /// In zh, this message translates to:
  /// **'发现旧版数据，是否迁移？'**
  String get migration_found;

  /// 迁移进行中
  ///
  /// In zh, this message translates to:
  /// **'正在迁移数据...'**
  String get migration_in_progress;

  /// 迁移成功
  ///
  /// In zh, this message translates to:
  /// **'数据迁移完成'**
  String get migration_success;

  /// 迁移失败
  ///
  /// In zh, this message translates to:
  /// **'数据迁移失败'**
  String get migration_failed;

  /// 备份旧版数据中
  ///
  /// In zh, this message translates to:
  /// **'正在备份旧版数据...'**
  String get migration_backup;

  /// 跳过迁移操作
  ///
  /// In zh, this message translates to:
  /// **'跳过迁移'**
  String get migration_skip;

  /// 开始迁移操作
  ///
  /// In zh, this message translates to:
  /// **'开始迁移'**
  String get migration_start;

  /// 迁移配置项
  ///
  /// In zh, this message translates to:
  /// **'迁移配置'**
  String get migration_config;

  /// 迁移程序列表项
  ///
  /// In zh, this message translates to:
  /// **'迁移程序列表'**
  String get migration_programs;

  /// 迁移分类项
  ///
  /// In zh, this message translates to:
  /// **'迁移分类'**
  String get migration_categories;

  /// 迁移主题项
  ///
  /// In zh, this message translates to:
  /// **'迁移主题'**
  String get migration_themes;

  /// 校验迁移数据中
  ///
  /// In zh, this message translates to:
  /// **'校验迁移数据...'**
  String get migration_verify;

  /// 校验通过
  ///
  /// In zh, this message translates to:
  /// **'迁移校验通过'**
  String get migration_verify_pass;

  /// 校验失败
  ///
  /// In zh, this message translates to:
  /// **'迁移校验失败，数据条目不一致'**
  String get migration_verify_fail;

  /// 功能开发中提示
  ///
  /// In zh, this message translates to:
  /// **'功能开发中...'**
  String get featureInProgress;

  /// FREE工具箱名称
  ///
  /// In zh, this message translates to:
  /// **'FREE工具箱'**
  String get tool_freeToolbox;

  /// APK批量安装工具名称
  ///
  /// In zh, this message translates to:
  /// **'APK批量安装工具'**
  String get tool_apkInstaller;

  /// 批量文件查重清理工具名称
  ///
  /// In zh, this message translates to:
  /// **'批量文件查重清理工具'**
  String get tool_fileDedup;

  /// 批量扩展名修改器名称
  ///
  /// In zh, this message translates to:
  /// **'批量扩展名修改器'**
  String get tool_extensionChanger;

  /// 批量重命名工具名称
  ///
  /// In zh, this message translates to:
  /// **'批量重命名工具'**
  String get tool_fileRenamer;

  /// 文件扫描器名称
  ///
  /// In zh, this message translates to:
  /// **'文件扫描器'**
  String get tool_fileScanner;

  /// 文件移动工具名称
  ///
  /// In zh, this message translates to:
  /// **'文件移动工具'**
  String get tool_fileMover;

  /// 系统时间管理与设备控制工具名称
  ///
  /// In zh, this message translates to:
  /// **'系统时间管理与设备控制工具'**
  String get tool_systemControl;

  /// Edge书签管理器名称
  ///
  /// In zh, this message translates to:
  /// **'Edge书签管理器'**
  String get tool_bookmarkManager;

  /// ImageClassifier名称
  ///
  /// In zh, this message translates to:
  /// **'ImageClassifier'**
  String get tool_imageClassifier;

  /// APK批量安装工具描述
  ///
  /// In zh, this message translates to:
  /// **'批量安装 APK 应用文件'**
  String get toolDesc_apkInstaller;

  /// 批量文件查重清理工具描述
  ///
  /// In zh, this message translates to:
  /// **'扫描并删除重复文件，释放磁盘空间'**
  String get toolDesc_fileDedup;

  /// 批量扩展名修改器描述
  ///
  /// In zh, this message translates to:
  /// **'批量修改文件扩展名'**
  String get toolDesc_extensionChanger;

  /// 批量重命名工具描述
  ///
  /// In zh, this message translates to:
  /// **'按照规则批量重命名文件'**
  String get toolDesc_fileRenamer;

  /// 文件扫描器描述
  ///
  /// In zh, this message translates to:
  /// **'扫描目录文件并统计信息'**
  String get toolDesc_fileScanner;

  /// 文件移动工具描述
  ///
  /// In zh, this message translates to:
  /// **'按照规则批量移动文件到目标目录'**
  String get toolDesc_fileMover;

  /// 系统时间管理与设备控制工具描述
  ///
  /// In zh, this message translates to:
  /// **'同步系统时间和控制设备状态'**
  String get toolDesc_systemControl;

  /// Edge书签管理器描述
  ///
  /// In zh, this message translates to:
  /// **'管理浏览器书签'**
  String get toolDesc_bookmarkManager;

  /// ImageClassifier描述
  ///
  /// In zh, this message translates to:
  /// **'使用 AI 对图片进行分类整理'**
  String get toolDesc_imageClassifier;

  /// FREE工具箱描述
  ///
  /// In zh, this message translates to:
  /// **'FREE 综合工具箱'**
  String get toolDesc_toolbox;

  /// 默认工具描述
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get toolDesc_default;

  /// 文件管理分类
  ///
  /// In zh, this message translates to:
  /// **'文件管理'**
  String get category_fileManagement;

  /// 系统工具分类
  ///
  /// In zh, this message translates to:
  /// **'系统工具'**
  String get category_systemTools;

  /// 其他分类
  ///
  /// In zh, this message translates to:
  /// **'其他'**
  String get category_other;

  /// 暂无工具提示
  ///
  /// In zh, this message translates to:
  /// **'暂无工具'**
  String get appCenter_noTools;

  /// 暂无工具描述
  ///
  /// In zh, this message translates to:
  /// **'该分类下没有可用工具'**
  String get appCenter_noToolsDesc;

  /// 全局搜索按钮提示
  ///
  /// In zh, this message translates to:
  /// **'全局搜索'**
  String get appCenter_globalSearch;

  /// 使用次数
  ///
  /// In zh, this message translates to:
  /// **'使用 {count} 次'**
  String appCenter_useCount(int count);

  /// 浏览按钮
  ///
  /// In zh, this message translates to:
  /// **'浏览'**
  String get browse;

  /// 扫描按钮
  ///
  /// In zh, this message translates to:
  /// **'扫描'**
  String get scan;

  /// 预览按钮
  ///
  /// In zh, this message translates to:
  /// **'预览'**
  String get preview;

  /// 执行按钮
  ///
  /// In zh, this message translates to:
  /// **'执行'**
  String get execute;

  /// 确定执行按钮
  ///
  /// In zh, this message translates to:
  /// **'确定执行'**
  String get confirmExecute;

  /// 暂停按钮
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get pause;

  /// 监控按钮
  ///
  /// In zh, this message translates to:
  /// **'监控'**
  String get monitor;

  /// 正在扫描状态
  ///
  /// In zh, this message translates to:
  /// **'正在扫描...'**
  String get scanning;

  /// 正在执行修改状态
  ///
  /// In zh, this message translates to:
  /// **'正在执行修改...'**
  String get executingModification;

  /// 正在同步状态
  ///
  /// In zh, this message translates to:
  /// **'正在同步...'**
  String get syncing;

  /// 正在切换设备状态
  ///
  /// In zh, this message translates to:
  /// **'正在切换设备状态...'**
  String get togglingDevice;

  /// 正在执行电源操作状态
  ///
  /// In zh, this message translates to:
  /// **'正在执行电源操作...'**
  String get executingPowerAction;

  /// 请先选择要扫描的目录
  ///
  /// In zh, this message translates to:
  /// **'请先选择要扫描的目录'**
  String get fileDedup_selectDirectoryFirst;

  /// 请先选择要删除的文件
  ///
  /// In zh, this message translates to:
  /// **'请先选择要删除的文件'**
  String get fileDedup_selectFilesToDelete;

  /// 没有选中的文件
  ///
  /// In zh, this message translates to:
  /// **'没有选中的文件'**
  String get fileDedup_noSelectedFiles;

  /// 扫描失败
  ///
  /// In zh, this message translates to:
  /// **'扫描失败'**
  String get fileDedup_scanFailed;

  /// 删除失败
  ///
  /// In zh, this message translates to:
  /// **'删除失败'**
  String get fileDedup_deleteFailed;

  /// 确认删除对话框标题
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get fileDedup_confirmDelete;

  /// 确认删除对话框内容
  ///
  /// In zh, this message translates to:
  /// **'确定要删除选中的 {count} 个文件吗？\n此操作不可撤销。'**
  String fileDedup_confirmDeleteMessage(int count);

  /// 已选择目录数量
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 个目录'**
  String fileDedup_selectedDirectories(int count);

  /// 扫描配置已更新
  ///
  /// In zh, this message translates to:
  /// **'扫描配置已更新'**
  String get fileDedup_configUpdated;

  /// 开始扫描文件
  ///
  /// In zh, this message translates to:
  /// **'开始扫描文件...'**
  String get fileDedup_startScan;

  /// 扫描已取消
  ///
  /// In zh, this message translates to:
  /// **'扫描已取消'**
  String get fileDedup_scanCancelled;

  /// 扫描完成
  ///
  /// In zh, this message translates to:
  /// **'扫描完成'**
  String get fileDedup_scanComplete;

  /// 开始删除文件
  ///
  /// In zh, this message translates to:
  /// **'开始删除 {count} 个文件...'**
  String fileDedup_startDelete(int count);

  /// 删除完成
  ///
  /// In zh, this message translates to:
  /// **'删除完成'**
  String get fileDedup_deleteComplete;

  /// 尚未选择任何目录
  ///
  /// In zh, this message translates to:
  /// **'尚未选择任何目录'**
  String get fileDedup_noDirectorySelected;

  /// 移除此目录提示
  ///
  /// In zh, this message translates to:
  /// **'移除此目录'**
  String get fileDedup_removeDirectory;

  /// 添加目录按钮
  ///
  /// In zh, this message translates to:
  /// **'添加目录'**
  String get fileDedup_addDirectory;

  /// 清空按钮
  ///
  /// In zh, this message translates to:
  /// **'清空'**
  String get fileDedup_clear;

  /// 目录选择区标题
  ///
  /// In zh, this message translates to:
  /// **'目录选择'**
  String get fileDedup_directorySelection;

  /// 扫描配置区标题
  ///
  /// In zh, this message translates to:
  /// **'扫描配置'**
  String get fileDedup_scanConfig;

  /// 哈希算法标签
  ///
  /// In zh, this message translates to:
  /// **'哈希算法:'**
  String get fileDedup_hashAlgorithm;

  /// 最小文件大小标签
  ///
  /// In zh, this message translates to:
  /// **'最小文件大小:'**
  String get fileDedup_minFileSize;

  /// 最小文件大小输入提示
  ///
  /// In zh, this message translates to:
  /// **'0 (不限制)'**
  String get fileDedup_minFileSizeHint;

  /// 字节单位
  ///
  /// In zh, this message translates to:
  /// **'字节'**
  String get fileDedup_bytes;

  /// 递归扫描子目录开关
  ///
  /// In zh, this message translates to:
  /// **'递归扫描子目录'**
  String get fileDedup_recursiveScan;

  /// 开始扫描按钮
  ///
  /// In zh, this message translates to:
  /// **'开始扫描'**
  String get fileDedup_startScanBtn;

  /// 取消扫描按钮
  ///
  /// In zh, this message translates to:
  /// **'取消扫描'**
  String get fileDedup_cancelScanBtn;

  /// 删除选中按钮
  ///
  /// In zh, this message translates to:
  /// **'删除选中 ({count})'**
  String fileDedup_deleteSelected(int count);

  /// 扫描中状态
  ///
  /// In zh, this message translates to:
  /// **'扫描中'**
  String get fileDedup_scanningStatus;

  /// 正在删除状态
  ///
  /// In zh, this message translates to:
  /// **'正在删除...'**
  String get fileDedup_deletingStatus;

  /// 重复文件组数
  ///
  /// In zh, this message translates to:
  /// **'{count} 组重复文件'**
  String fileDedup_duplicateGroups(int count);

  /// 扫描结果标题
  ///
  /// In zh, this message translates to:
  /// **'扫描结果'**
  String get fileDedup_scanResult;

  /// 扫描文件标签
  ///
  /// In zh, this message translates to:
  /// **'扫描文件'**
  String get fileDedup_scannedFiles;

  /// 重复组数标签
  ///
  /// In zh, this message translates to:
  /// **'重复组数'**
  String get fileDedup_duplicateGroupsCount;

  /// 重复文件标签
  ///
  /// In zh, this message translates to:
  /// **'重复文件'**
  String get fileDedup_duplicateFiles;

  /// 可释放空间标签
  ///
  /// In zh, this message translates to:
  /// **'可释放空间'**
  String get fileDedup_releasableSpace;

  /// 重复文件列表标题
  ///
  /// In zh, this message translates to:
  /// **'重复文件列表'**
  String get fileDedup_duplicateFileList;

  /// 操作日志标题
  ///
  /// In zh, this message translates to:
  /// **'操作日志'**
  String get operationLog;

  /// 暂无日志提示
  ///
  /// In zh, this message translates to:
  /// **'暂无日志'**
  String get noLogs;

  /// 扩展名修改器目录选择标题
  ///
  /// In zh, this message translates to:
  /// **'目录选择'**
  String get extChanger_directorySelection;

  /// 扩展名修改器目录选择提示
  ///
  /// In zh, this message translates to:
  /// **'请选择要修改扩展名的文件目录'**
  String get extChanger_directoryHint;

  /// 扩展名规则标题
  ///
  /// In zh, this message translates to:
  /// **'扩展名规则'**
  String get extChanger_extensionRules;

  /// 暂无规则提示
  ///
  /// In zh, this message translates to:
  /// **'暂无规则，点击 + 添加扩展名修改规则'**
  String get extChanger_noRules;

  /// 添加规则按钮提示
  ///
  /// In zh, this message translates to:
  /// **'添加规则'**
  String get extChanger_addRule;

  /// 编辑规则标题
  ///
  /// In zh, this message translates to:
  /// **'编辑规则'**
  String get extChanger_editRule;

  /// 原扩展名输入标签
  ///
  /// In zh, this message translates to:
  /// **'原扩展名（如 .txt 或留空表示无扩展名）'**
  String get extChanger_originalExt;

  /// 新扩展名输入标签
  ///
  /// In zh, this message translates to:
  /// **'新扩展名（如 .md）'**
  String get extChanger_newExt;

  /// 递归应用到子目录开关
  ///
  /// In zh, this message translates to:
  /// **'递归应用到子目录'**
  String get extChanger_recursiveSubdirs;

  /// 新扩展名不能为空提示
  ///
  /// In zh, this message translates to:
  /// **'新扩展名不能为空'**
  String get extChanger_newExtRequired;

  /// 无扩展名显示
  ///
  /// In zh, this message translates to:
  /// **'(无扩展名)'**
  String get extChanger_noExtension;

  /// 预览结果标题
  ///
  /// In zh, this message translates to:
  /// **'预览结果'**
  String get extChanger_previewResult;

  /// 待处理状态
  ///
  /// In zh, this message translates to:
  /// **'待处理'**
  String get extChanger_pending;

  /// 确认执行对话框标题
  ///
  /// In zh, this message translates to:
  /// **'确认执行'**
  String get extChanger_confirmExecute;

  /// 确认执行对话框内容
  ///
  /// In zh, this message translates to:
  /// **'即将修改 {count} 个文件的扩展名，此操作不可撤销。确定要继续吗？'**
  String extChanger_confirmExecuteMessage(int count);

  /// 暂无预览
  ///
  /// In zh, this message translates to:
  /// **'暂无预览'**
  String get extChanger_noPreview;

  /// 请先扫描目录提示
  ///
  /// In zh, this message translates to:
  /// **'请先扫描目录，然后添加规则并点击预览'**
  String get extChanger_scanThenPreview;

  /// 请添加规则并预览提示
  ///
  /// In zh, this message translates to:
  /// **'请添加规则并点击预览按钮'**
  String get extChanger_addRuleThenPreview;

  /// 正在生成预览
  ///
  /// In zh, this message translates to:
  /// **'正在生成预览...'**
  String get extChanger_generatingPreview;

  /// 已扫描文件数
  ///
  /// In zh, this message translates to:
  /// **'已扫描 {count} 个文件'**
  String extChanger_scannedFiles(int count);

  /// 文件数量
  ///
  /// In zh, this message translates to:
  /// **'{count} 个文件'**
  String extChanger_fileCount(int count);

  /// 时间同步标签页
  ///
  /// In zh, this message translates to:
  /// **'时间同步'**
  String get sysControl_timeSync;

  /// 设备控制标签页
  ///
  /// In zh, this message translates to:
  /// **'设备控制'**
  String get sysControl_deviceControl;

  /// 系统操作标签页
  ///
  /// In zh, this message translates to:
  /// **'系统操作'**
  String get sysControl_systemOperation;

  /// 当前系统时间标题
  ///
  /// In zh, this message translates to:
  /// **'当前系统时间'**
  String get sysControl_currentSystemTime;

  /// 自动同步开关
  ///
  /// In zh, this message translates to:
  /// **'自动同步'**
  String get sysControl_autoSync;

  /// NTP服务器标题
  ///
  /// In zh, this message translates to:
  /// **'NTP 服务器'**
  String get sysControl_ntpServer;

  /// 刷新服务器列表提示
  ///
  /// In zh, this message translates to:
  /// **'刷新服务器列表'**
  String get sysControl_refreshServerList;

  /// 选择此服务器提示
  ///
  /// In zh, this message translates to:
  /// **'选择此服务器'**
  String get sysControl_selectServer;

  /// 同步按钮
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get sysControl_sync;

  /// 手动设置时间标题
  ///
  /// In zh, this message translates to:
  /// **'手动设置时间'**
  String get sysControl_manualSetTime;

  /// 小时输入标签
  ///
  /// In zh, this message translates to:
  /// **'时'**
  String get sysControl_hour;

  /// 分钟输入标签
  ///
  /// In zh, this message translates to:
  /// **'分'**
  String get sysControl_minute;

  /// 设置时间按钮
  ///
  /// In zh, this message translates to:
  /// **'设置时间'**
  String get sysControl_setTime;

  /// 确认设置系统时间对话框标题
  ///
  /// In zh, this message translates to:
  /// **'确认设置系统时间'**
  String get sysControl_confirmSetTime;

  /// 确认设置系统时间对话框内容
  ///
  /// In zh, this message translates to:
  /// **'确定要将系统时间设置为：'**
  String get sysControl_confirmSetTimeMessage;

  /// 时间变更警告
  ///
  /// In zh, this message translates to:
  /// **'这可能会影响系统日志和证书验证。'**
  String get sysControl_timeChangeWarning;

  /// 同步结果标题
  ///
  /// In zh, this message translates to:
  /// **'同步结果'**
  String get sysControl_syncResult;

  /// 服务器标签
  ///
  /// In zh, this message translates to:
  /// **'服务器'**
  String get sysControl_server;

  /// 本地时间标签
  ///
  /// In zh, this message translates to:
  /// **'本地时间'**
  String get sysControl_localTime;

  /// 服务器时间标签
  ///
  /// In zh, this message translates to:
  /// **'服务器时间'**
  String get sysControl_serverTime;

  /// 时间偏移标签
  ///
  /// In zh, this message translates to:
  /// **'时间偏移'**
  String get sysControl_timeOffset;

  /// 清除日志提示
  ///
  /// In zh, this message translates to:
  /// **'清除日志'**
  String get sysControl_clearLog;

  /// 时间同步功能限制标题
  ///
  /// In zh, this message translates to:
  /// **'时间同步功能限制'**
  String get sysControl_timeSyncRestriction;

  /// 时间同步功能限制描述
  ///
  /// In zh, this message translates to:
  /// **'Android 平台不支持设置系统时间，请在系统设置中同步网络时间。'**
  String get sysControl_timeSyncRestrictionDesc;

  /// 设备开关标题
  ///
  /// In zh, this message translates to:
  /// **'设备开关'**
  String get sysControl_deviceSwitches;

  /// WiFi副标题
  ///
  /// In zh, this message translates to:
  /// **'无线网络连接'**
  String get sysControl_wifiSubtitle;

  /// 蓝牙副标题
  ///
  /// In zh, this message translates to:
  /// **'蓝牙设备连接'**
  String get sysControl_bluetoothSubtitle;

  /// 以太网副标题
  ///
  /// In zh, this message translates to:
  /// **'有线网络连接'**
  String get sysControl_ethernetSubtitle;

  /// 设备列表标题
  ///
  /// In zh, this message translates to:
  /// **'设备列表'**
  String get sysControl_deviceList;

  /// 刷新设备列表提示
  ///
  /// In zh, this message translates to:
  /// **'刷新设备列表'**
  String get sysControl_refreshDeviceList;

  /// 未检测到设备提示
  ///
  /// In zh, this message translates to:
  /// **'未检测到设备'**
  String get sysControl_noDeviceDetected;

  /// 确认设备操作对话框标题
  ///
  /// In zh, this message translates to:
  /// **'确认设备操作'**
  String get sysControl_confirmDeviceAction;

  /// 确认切换设备状态
  ///
  /// In zh, this message translates to:
  /// **'确定要{action} {device} 吗？'**
  String sysControl_confirmToggleDevice(String action, String device);

  /// 启用操作
  ///
  /// In zh, this message translates to:
  /// **'启用'**
  String get sysControl_enable;

  /// 禁用操作
  ///
  /// In zh, this message translates to:
  /// **'禁用'**
  String get sysControl_disable;

  /// 设备控制功能限制标题
  ///
  /// In zh, this message translates to:
  /// **'设备控制功能限制'**
  String get sysControl_deviceControlRestriction;

  /// 设备控制功能限制描述
  ///
  /// In zh, this message translates to:
  /// **'Android 平台的设备控制需要 Platform Channel 支持。'**
  String get sysControl_deviceControlRestrictionDesc;

  /// 关机操作
  ///
  /// In zh, this message translates to:
  /// **'关机'**
  String get sysControl_shutdown;

  /// 重启操作
  ///
  /// In zh, this message translates to:
  /// **'重启'**
  String get sysControl_restart;

  /// 睡眠操作
  ///
  /// In zh, this message translates to:
  /// **'睡眠'**
  String get sysControl_sleep;

  /// 休眠操作
  ///
  /// In zh, this message translates to:
  /// **'休眠'**
  String get sysControl_hibernate;

  /// 锁定操作
  ///
  /// In zh, this message translates to:
  /// **'锁定'**
  String get sysControl_lock;

  /// 电源操作警告
  ///
  /// In zh, this message translates to:
  /// **'注意：执行关机或重启操作前，请保存所有未保存的工作。'**
  String get sysControl_powerWarning;

  /// 确认操作对话框标题
  ///
  /// In zh, this message translates to:
  /// **'确认操作'**
  String get sysControl_confirmAction;

  /// 系统操作功能限制标题
  ///
  /// In zh, this message translates to:
  /// **'系统操作功能限制'**
  String get sysControl_systemOperationRestriction;

  /// 系统操作功能限制描述
  ///
  /// In zh, this message translates to:
  /// **'Android 平台不支持关机、重启等系统操作。'**
  String get sysControl_systemOperationRestrictionDesc;

  /// 源目录标题
  ///
  /// In zh, this message translates to:
  /// **'源目录'**
  String get fileMover_sourceDirectory;

  /// 目标目录标题
  ///
  /// In zh, this message translates to:
  /// **'目标目录'**
  String get fileMover_targetDirectory;

  /// 源目录选择提示
  ///
  /// In zh, this message translates to:
  /// **'请选择要移动文件的源目录'**
  String get fileMover_sourceDirHint;

  /// 目标目录选择提示
  ///
  /// In zh, this message translates to:
  /// **'请选择文件移动的目标目录（可选）'**
  String get fileMover_targetDirHint;

  /// 移动规则标题
  ///
  /// In zh, this message translates to:
  /// **'移动规则'**
  String get fileMover_moveRules;

  /// 暂无规则提示
  ///
  /// In zh, this message translates to:
  /// **'暂无规则，点击 + 添加移动规则（或仅使用目标目录）'**
  String get fileMover_noRules;

  /// 正在执行移动状态
  ///
  /// In zh, this message translates to:
  /// **'正在执行移动...'**
  String get fileMover_executingMove;

  /// 确认移动对话框内容
  ///
  /// In zh, this message translates to:
  /// **'即将移动 {count} 个文件，此操作不可撤销。确定要继续吗？'**
  String fileMover_confirmMoveMessage(int count);

  /// 重命名工具目录选择标题
  ///
  /// In zh, this message translates to:
  /// **'目录选择'**
  String get fileRenamer_directorySelection;

  /// 重命名工具目录选择提示
  ///
  /// In zh, this message translates to:
  /// **'请选择要重命名文件的目录'**
  String get fileRenamer_directoryHint;

  /// 规则设置标题
  ///
  /// In zh, this message translates to:
  /// **'规则设置'**
  String get fileRenamer_ruleSettings;

  /// 暂无规则提示
  ///
  /// In zh, this message translates to:
  /// **'暂无规则，点击 + 添加规则或从模板加载'**
  String get fileRenamer_noRules;

  /// 保存当前规则为模板
  ///
  /// In zh, this message translates to:
  /// **'保存当前规则为模板'**
  String get fileRenamer_saveAsTemplate;

  /// 保存模板对话框标题
  ///
  /// In zh, this message translates to:
  /// **'保存模板'**
  String get fileRenamer_saveTemplate;

  /// 模板名称输入标签
  ///
  /// In zh, this message translates to:
  /// **'模板名称'**
  String get fileRenamer_templateName;

  /// 模板描述输入标签
  ///
  /// In zh, this message translates to:
  /// **'模板描述'**
  String get fileRenamer_templateDesc;

  /// 正在执行重命名状态
  ///
  /// In zh, this message translates to:
  /// **'正在执行重命名...'**
  String get fileRenamer_executingRename;

  /// 确认重命名对话框内容
  ///
  /// In zh, this message translates to:
  /// **'即将重命名 {count} 个文件，此操作不可撤销。确定要继续吗？'**
  String fileRenamer_confirmRenameMessage(int count);

  /// 设备列表标题
  ///
  /// In zh, this message translates to:
  /// **'设备列表'**
  String get apkInstaller_deviceList;

  /// 刷新设备列表提示
  ///
  /// In zh, this message translates to:
  /// **'刷新设备列表'**
  String get apkInstaller_refreshDeviceList;

  /// 未发现设备提示
  ///
  /// In zh, this message translates to:
  /// **'未发现已连接的设备\n请使用 USB 连接设备或启动无线调试'**
  String get apkInstaller_noDevice;

  /// APK文件标题
  ///
  /// In zh, this message translates to:
  /// **'APK 文件'**
  String get apkInstaller_apkFiles;

  /// 尚未添加APK文件提示
  ///
  /// In zh, this message translates to:
  /// **'尚未添加 APK 文件\n点击下方按钮选择文件'**
  String get apkInstaller_noApkFiles;

  /// 安装选项标题
  ///
  /// In zh, this message translates to:
  /// **'安装选项'**
  String get apkInstaller_installOptions;

  /// 覆盖安装开关
  ///
  /// In zh, this message translates to:
  /// **'覆盖安装'**
  String get apkInstaller_replaceInstall;

  /// 覆盖安装描述
  ///
  /// In zh, this message translates to:
  /// **'如果应用已存在，将覆盖原有版本（-r 参数）'**
  String get apkInstaller_replaceInstallDesc;

  /// 允许降级安装开关
  ///
  /// In zh, this message translates to:
  /// **'允许降级安装'**
  String get apkInstaller_allowDowngrade;

  /// 允许降级安装描述
  ///
  /// In zh, this message translates to:
  /// **'允许安装比当前版本更低的版本（-d 参数）'**
  String get apkInstaller_allowDowngradeDesc;

  /// 取消安装按钮
  ///
  /// In zh, this message translates to:
  /// **'取消安装'**
  String get apkInstaller_cancelInstall;

  /// 开始安装按钮
  ///
  /// In zh, this message translates to:
  /// **'开始安装 ({count})'**
  String apkInstaller_startInstall(int count);

  /// 安装进度
  ///
  /// In zh, this message translates to:
  /// **'安装进度: {percent}%'**
  String apkInstaller_installProgress(int percent);

  /// 安装结果占位提示
  ///
  /// In zh, this message translates to:
  /// **'安装结果将在此显示'**
  String get apkInstaller_installResult;

  /// 安装统计标题
  ///
  /// In zh, this message translates to:
  /// **'安装统计'**
  String get apkInstaller_installStats;

  /// 总计标签
  ///
  /// In zh, this message translates to:
  /// **'总计'**
  String get apkInstaller_total;

  /// 成功标签
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get apkInstaller_successCount;

  /// 失败标签
  ///
  /// In zh, this message translates to:
  /// **'失败'**
  String get apkInstaller_failedCount;

  /// 总耗时标签
  ///
  /// In zh, this message translates to:
  /// **'总耗时'**
  String get apkInstaller_totalDuration;

  /// 安装成功提示
  ///
  /// In zh, this message translates to:
  /// **'安装成功'**
  String get apkInstaller_installSuccess;

  /// 运行日志标题
  ///
  /// In zh, this message translates to:
  /// **'运行日志'**
  String get apkInstaller_runLog;

  /// 准备中状态
  ///
  /// In zh, this message translates to:
  /// **'准备中...'**
  String get apkInstaller_preparing;

  /// 正在安装状态
  ///
  /// In zh, this message translates to:
  /// **'正在安装: {name}'**
  String apkInstaller_installing(String name);

  /// 搜索框提示
  ///
  /// In zh, this message translates to:
  /// **'搜索工具名称或描述...'**
  String get search_hint;

  /// 输入关键词搜索提示
  ///
  /// In zh, this message translates to:
  /// **'输入关键词搜索工具'**
  String get search_inputKeyword;

  /// 可搜索工具名称或描述
  ///
  /// In zh, this message translates to:
  /// **'可搜索工具名称或描述'**
  String get search_searchNameOrDesc;

  /// 未找到相关工具
  ///
  /// In zh, this message translates to:
  /// **'未找到相关工具'**
  String get search_noResults;

  /// 尝试使用其他关键词
  ///
  /// In zh, this message translates to:
  /// **'尝试使用其他关键词'**
  String get search_tryOtherKeywords;

  /// 打开按钮
  ///
  /// In zh, this message translates to:
  /// **'打开'**
  String get search_open;

  /// 返回按钮提示
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get search_back;

  /// 清除按钮提示
  ///
  /// In zh, this message translates to:
  /// **'清除'**
  String get search_clear;

  /// 工具箱标题
  ///
  /// In zh, this message translates to:
  /// **'FREE工具箱'**
  String get toolbox_freeToolbox;

  /// 折叠侧边栏提示
  ///
  /// In zh, this message translates to:
  /// **'折叠侧边栏'**
  String get toolbox_collapseSidebar;

  /// 展开侧边栏提示
  ///
  /// In zh, this message translates to:
  /// **'展开侧边栏'**
  String get toolbox_expandSidebar;

  /// 工具箱首页按钮
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get toolbox_home;

  /// 工具库按钮
  ///
  /// In zh, this message translates to:
  /// **'工具库'**
  String get toolbox_toolLibrary;

  /// 程序分类标签
  ///
  /// In zh, this message translates to:
  /// **'程序分类'**
  String get toolbox_programCategories;

  /// 添加程序按钮
  ///
  /// In zh, this message translates to:
  /// **'添加程序'**
  String get toolbox_addProgram;

  /// 实时监控标题
  ///
  /// In zh, this message translates to:
  /// **'实时监控'**
  String get hardware_realtimeMonitor;

  /// 系统信息标题
  ///
  /// In zh, this message translates to:
  /// **'系统信息'**
  String get hardware_systemInfo;

  /// 计算机信息标题
  ///
  /// In zh, this message translates to:
  /// **'计算机信息'**
  String get hardware_computerInfo;

  /// CPU信息标题
  ///
  /// In zh, this message translates to:
  /// **'CPU 信息'**
  String get hardware_cpuInfo;

  /// 内存信息标题
  ///
  /// In zh, this message translates to:
  /// **'内存信息'**
  String get hardware_memoryInfo;

  /// 磁盘信息标题
  ///
  /// In zh, this message translates to:
  /// **'磁盘 {drive}'**
  String hardware_diskInfo(String drive);

  /// GPU信息标题
  ///
  /// In zh, this message translates to:
  /// **'GPU'**
  String get hardware_gpuInfo;

  /// 网络信息标题
  ///
  /// In zh, this message translates to:
  /// **'网络 {interface}'**
  String hardware_networkInfo(String interface);

  /// 加载硬件信息失败
  ///
  /// In zh, this message translates to:
  /// **'加载硬件信息失败'**
  String get hardware_loadFailed;

  /// 操作系统标签
  ///
  /// In zh, this message translates to:
  /// **'操作系统'**
  String get hardware_osName;

  /// 版本标签
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get hardware_osVersion;

  /// 构建号标签
  ///
  /// In zh, this message translates to:
  /// **'构建号'**
  String get hardware_osBuild;

  /// 架构标签
  ///
  /// In zh, this message translates to:
  /// **'架构'**
  String get hardware_architecture;

  /// 计算机名标签
  ///
  /// In zh, this message translates to:
  /// **'计算机名'**
  String get hardware_computerName;

  /// 用户名标签
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get hardware_userName;

  /// 制造商标签
  ///
  /// In zh, this message translates to:
  /// **'制造商'**
  String get hardware_manufacturer;

  /// 型号标签
  ///
  /// In zh, this message translates to:
  /// **'型号'**
  String get hardware_model;

  /// 产品名称标签
  ///
  /// In zh, this message translates to:
  /// **'产品名称'**
  String get hardware_productName;

  /// BIOS版本标签
  ///
  /// In zh, this message translates to:
  /// **'BIOS版本'**
  String get hardware_biosVersion;

  /// 主板制造商标签
  ///
  /// In zh, this message translates to:
  /// **'主板制造商'**
  String get hardware_baseboardManufacturer;

  /// 主板产品标签
  ///
  /// In zh, this message translates to:
  /// **'主板产品'**
  String get hardware_baseboardProduct;

  /// 核心/线程
  ///
  /// In zh, this message translates to:
  /// **'{cores}核 / {threads}线程'**
  String hardware_coresThreads(int cores, int threads);

  /// 最大频率标签
  ///
  /// In zh, this message translates to:
  /// **'最大频率'**
  String get hardware_maxFrequency;

  /// L2缓存标签
  ///
  /// In zh, this message translates to:
  /// **'L2缓存'**
  String get hardware_l2Cache;

  /// L3缓存标签
  ///
  /// In zh, this message translates to:
  /// **'L3缓存'**
  String get hardware_l3Cache;

  /// 总容量标签
  ///
  /// In zh, this message translates to:
  /// **'总容量'**
  String get hardware_totalCapacity;

  /// 可用标签
  ///
  /// In zh, this message translates to:
  /// **'可用'**
  String get hardware_available;

  /// 已用标签
  ///
  /// In zh, this message translates to:
  /// **'已用'**
  String get hardware_used;

  /// 使用率标签
  ///
  /// In zh, this message translates to:
  /// **'使用率'**
  String get hardware_usageRate;

  /// 频率标签
  ///
  /// In zh, this message translates to:
  /// **'频率'**
  String get hardware_frequency;

  /// 通道数标签
  ///
  /// In zh, this message translates to:
  /// **'通道数'**
  String get hardware_channels;

  /// 文件系统标签
  ///
  /// In zh, this message translates to:
  /// **'文件系统'**
  String get hardware_fileSystem;

  /// 驱动版本标签
  ///
  /// In zh, this message translates to:
  /// **'驱动版本'**
  String get hardware_driverVersion;

  /// 显存标签
  ///
  /// In zh, this message translates to:
  /// **'显存'**
  String get hardware_videoMemory;

  /// 显存类型标签
  ///
  /// In zh, this message translates to:
  /// **'显存类型'**
  String get hardware_memoryType;

  /// IP地址标签
  ///
  /// In zh, this message translates to:
  /// **'IP地址'**
  String get hardware_ipAddress;

  /// IPv6地址标签
  ///
  /// In zh, this message translates to:
  /// **'IPv6地址'**
  String get hardware_ipv6Address;

  /// MAC地址标签
  ///
  /// In zh, this message translates to:
  /// **'MAC地址'**
  String get hardware_macAddress;

  /// 子网掩码标签
  ///
  /// In zh, this message translates to:
  /// **'子网掩码'**
  String get hardware_subnetMask;

  /// 网关标签
  ///
  /// In zh, this message translates to:
  /// **'网关'**
  String get hardware_gateway;

  /// DNS标签
  ///
  /// In zh, this message translates to:
  /// **'DNS'**
  String get hardware_dns;

  /// 运行进程标签
  ///
  /// In zh, this message translates to:
  /// **'运行进程'**
  String get hardware_runningProcesses;

  /// 磁盘读取标签
  ///
  /// In zh, this message translates to:
  /// **'磁盘读取'**
  String get hardware_diskRead;

  /// 磁盘写入标签
  ///
  /// In zh, this message translates to:
  /// **'磁盘写入'**
  String get hardware_diskWrite;

  /// 上传速度标签
  ///
  /// In zh, this message translates to:
  /// **'上传速度'**
  String get hardware_uploadSpeed;

  /// 下载速度标签
  ///
  /// In zh, this message translates to:
  /// **'下载速度'**
  String get hardware_downloadSpeed;

  /// 运行时间标签
  ///
  /// In zh, this message translates to:
  /// **'运行时间'**
  String get hardware_uptime;

  /// 图像分类器标题
  ///
  /// In zh, this message translates to:
  /// **'图像分类器'**
  String get imageClassifier_title;

  /// 模型选择标题
  ///
  /// In zh, this message translates to:
  /// **'模型选择'**
  String get imageClassifier_modelSelection;

  /// 选择模型文件提示
  ///
  /// In zh, this message translates to:
  /// **'选择模型文件 (.onnx / .tflite)'**
  String get imageClassifier_selectModelFile;

  /// 释放模型提示
  ///
  /// In zh, this message translates to:
  /// **'释放模型'**
  String get imageClassifier_releaseModel;

  /// 模型信息按钮
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get imageClassifier_modelInfo;

  /// 正在加载模型提示
  ///
  /// In zh, this message translates to:
  /// **'正在加载模型，请稍候...'**
  String get imageClassifier_loadingModel;

  /// 预训练模型提示
  ///
  /// In zh, this message translates to:
  /// **'预训练模型（需下载模型文件）:'**
  String get imageClassifier_pretrainedModels;

  /// 图片选择标题
  ///
  /// In zh, this message translates to:
  /// **'图片选择'**
  String get imageClassifier_imageSelection;

  /// 添加图片按钮
  ///
  /// In zh, this message translates to:
  /// **'添加图片'**
  String get imageClassifier_addImage;

  /// 添加目录按钮
  ///
  /// In zh, this message translates to:
  /// **'添加目录'**
  String get imageClassifier_addDirectory;

  /// 排序按钮
  ///
  /// In zh, this message translates to:
  /// **'排序'**
  String get imageClassifier_sort;

  /// 已分类状态
  ///
  /// In zh, this message translates to:
  /// **'已分类'**
  String get imageClassifier_classified;

  /// 请添加图片提示
  ///
  /// In zh, this message translates to:
  /// **'请添加图片进行分类'**
  String get imageClassifier_pleaseAddImages;

  /// 分类配置标题
  ///
  /// In zh, this message translates to:
  /// **'分类配置'**
  String get imageClassifier_classificationConfig;

  /// 置信度阈值标签
  ///
  /// In zh, this message translates to:
  /// **'置信度阈值'**
  String get imageClassifier_confidenceThreshold;

  /// 批量大小标签
  ///
  /// In zh, this message translates to:
  /// **'批量大小'**
  String get imageClassifier_batchSize;

  /// 开始分类按钮
  ///
  /// In zh, this message translates to:
  /// **'开始分类'**
  String get imageClassifier_startClassification;

  /// 分类中状态
  ///
  /// In zh, this message translates to:
  /// **'分类中...'**
  String get imageClassifier_classifying;

  /// 总图片数标签
  ///
  /// In zh, this message translates to:
  /// **'总图片数'**
  String get imageClassifier_totalImages;

  /// 已处理标签
  ///
  /// In zh, this message translates to:
  /// **'已处理'**
  String get imageClassifier_processed;

  /// 成功率标签
  ///
  /// In zh, this message translates to:
  /// **'成功率'**
  String get imageClassifier_successRate;

  /// 暂无分类结果
  ///
  /// In zh, this message translates to:
  /// **'暂无分类结果'**
  String get imageClassifier_noResults;

  /// 选择图片并分类提示
  ///
  /// In zh, this message translates to:
  /// **'选择图片并点击\"开始分类\"进行推理'**
  String get imageClassifier_selectAndClassify;

  /// 分类结果标题
  ///
  /// In zh, this message translates to:
  /// **'分类结果'**
  String get imageClassifier_classificationResults;

  /// 排序方式对话框标题
  ///
  /// In zh, this message translates to:
  /// **'排序方式'**
  String get imageClassifier_sortMethod;

  /// 文件名升序
  ///
  /// In zh, this message translates to:
  /// **'文件名升序'**
  String get imageClassifier_nameAsc;

  /// 文件名降序
  ///
  /// In zh, this message translates to:
  /// **'文件名降序'**
  String get imageClassifier_nameDesc;

  /// 路径升序
  ///
  /// In zh, this message translates to:
  /// **'路径升序'**
  String get imageClassifier_pathAsc;

  /// 路径降序
  ///
  /// In zh, this message translates to:
  /// **'路径降序'**
  String get imageClassifier_pathDesc;

  /// 导出结果对话框标题
  ///
  /// In zh, this message translates to:
  /// **'导出结果'**
  String get imageClassifier_exportResults;

  /// 导出为CSV
  ///
  /// In zh, this message translates to:
  /// **'导出为 CSV'**
  String get imageClassifier_exportCsv;

  /// 导出CSV描述
  ///
  /// In zh, this message translates to:
  /// **'表格格式，可用 Excel 打开'**
  String get imageClassifier_exportCsvDesc;

  /// 导出为JSON
  ///
  /// In zh, this message translates to:
  /// **'导出为 JSON'**
  String get imageClassifier_exportJson;

  /// 导出JSON描述
  ///
  /// In zh, this message translates to:
  /// **'结构化数据格式'**
  String get imageClassifier_exportJsonDesc;

  /// 复制到剪贴板
  ///
  /// In zh, this message translates to:
  /// **'复制到剪贴板'**
  String get imageClassifier_copyToClipboard;

  /// 复制到剪贴板描述
  ///
  /// In zh, this message translates to:
  /// **'复制 JSON 格式到剪贴板'**
  String get imageClassifier_copyToClipboardDesc;

  /// 已复制到剪贴板提示
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get imageClassifier_copiedToClipboard;

  /// 导出失败
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get imageClassifier_exportFailed;

  /// 已选择图片数量
  ///
  /// In zh, this message translates to:
  /// **'已选择 {count} 张图片'**
  String imageClassifier_selectedImages(int count);

  /// 输入尺寸标签
  ///
  /// In zh, this message translates to:
  /// **'输入尺寸'**
  String get imageClassifier_inputSize;

  /// 精度标签
  ///
  /// In zh, this message translates to:
  /// **'精度'**
  String get imageClassifier_accuracy;

  /// 类别标签
  ///
  /// In zh, this message translates to:
  /// **'类别'**
  String get imageClassifier_category;

  /// 后端标签
  ///
  /// In zh, this message translates to:
  /// **'后端'**
  String get imageClassifier_backend;

  /// 参数标签
  ///
  /// In zh, this message translates to:
  /// **'参数'**
  String get imageClassifier_params;

  /// 速度标签
  ///
  /// In zh, this message translates to:
  /// **'速度'**
  String get imageClassifier_speed;

  /// 适用场景标签
  ///
  /// In zh, this message translates to:
  /// **'适用场景'**
  String get imageClassifier_useCase;

  /// 参数量标签
  ///
  /// In zh, this message translates to:
  /// **'参数量'**
  String get imageClassifier_paramsCount;

  /// 分类中状态文本
  ///
  /// In zh, this message translates to:
  /// **'分类中: {text}'**
  String imageClassifier_classifyingStatus(String text);

  /// 模型标签
  ///
  /// In zh, this message translates to:
  /// **'模型: {name}'**
  String imageClassifier_modelLabel(String name);

  /// 分类结果标签
  ///
  /// In zh, this message translates to:
  /// **'类别: {className} | 置信度: {confidence}%'**
  String imageClassifier_classLabel(String className, String confidence);

  /// 错误标签
  ///
  /// In zh, this message translates to:
  /// **'错误: {error}'**
  String imageClassifier_errorLabel(String error);

  /// 未知错误
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get imageClassifier_unknownError;

  /// 已导出CSV提示
  ///
  /// In zh, this message translates to:
  /// **'已导出 {count} 条结果到 CSV'**
  String imageClassifier_exportedToCsv(int count);

  /// 已导出JSON提示
  ///
  /// In zh, this message translates to:
  /// **'已导出 {count} 条结果到 JSON'**
  String imageClassifier_exportedToJson(int count);

  /// 结果已复制到剪贴板
  ///
  /// In zh, this message translates to:
  /// **'结果已复制到剪贴板'**
  String get imageClassifier_resultsCopied;

  /// 移除操作
  ///
  /// In zh, this message translates to:
  /// **'移除'**
  String get remove;

  /// 添加规则提示
  ///
  /// In zh, this message translates to:
  /// **'添加规则'**
  String get addRule;

  /// 待处理状态
  ///
  /// In zh, this message translates to:
  /// **'{count} 待处理'**
  String previewStatus_pending(int count);

  /// 成功状态
  ///
  /// In zh, this message translates to:
  /// **'{count} 成功'**
  String previewStatus_success(int count);

  /// 失败状态
  ///
  /// In zh, this message translates to:
  /// **'{count} 失败'**
  String previewStatus_failed(int count);

  /// 正在生成预览
  ///
  /// In zh, this message translates to:
  /// **'正在生成预览...'**
  String get generatingPreview;

  /// 暂无预览
  ///
  /// In zh, this message translates to:
  /// **'暂无预览'**
  String get noPreview;

  /// 请先扫描目录提示
  ///
  /// In zh, this message translates to:
  /// **'请先扫描目录，然后添加规则并点击预览'**
  String get scanThenPreview;

  /// 请添加规则并预览提示
  ///
  /// In zh, this message translates to:
  /// **'请添加规则并点击预览按钮'**
  String get addRuleThenPreview;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
