// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'AI Apps 工具集';

  @override
  String get home => '首页';

  @override
  String get settings => '设置';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get retry => '重试';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get edit => '编辑';

  @override
  String get search => '搜索';

  @override
  String get noData => '暂无数据';

  @override
  String get networkError => '网络错误';

  @override
  String get pageNotFound => '页面未找到';

  @override
  String get backToHome => '返回首页';

  @override
  String get ok => '确定';

  @override
  String get close => '关闭';

  @override
  String get add => '添加';

  @override
  String get refresh => '刷新';

  @override
  String get select_all => '全选';

  @override
  String get export => '导出';

  @override
  String get import => '导入';

  @override
  String get ready => '就绪';

  @override
  String get warning => '警告';

  @override
  String get success => '成功';

  @override
  String get info => '信息';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get apply => '应用';

  @override
  String get tools => '工具';

  @override
  String get help => '帮助';

  @override
  String get about => '关于';

  @override
  String get exit => '退出';

  @override
  String get file => '文件';

  @override
  String get view => '视图';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get light_mode => '浅色模式';

  @override
  String get dark_mode => '深色模式';

  @override
  String get follow_system => '跟随系统';

  @override
  String get recent => '最近使用';

  @override
  String get favorites => '收藏';

  @override
  String get all => '全部';

  @override
  String get name => '名称';

  @override
  String get description => '描述';

  @override
  String get status => '状态';

  @override
  String get action => '操作';

  @override
  String get time => '时间';

  @override
  String get size => '大小';

  @override
  String get type => '类型';

  @override
  String get path => '路径';

  @override
  String get progress => '进度';

  @override
  String get completed => '完成';

  @override
  String get failed => '失败';

  @override
  String get version => '版本';

  @override
  String get update => '更新';

  @override
  String get download => '下载';

  @override
  String get install => '安装';

  @override
  String get check_update => '检查更新';

  @override
  String get no_update => '暂无更新';

  @override
  String get new_version_available => '新版本可用';

  @override
  String get already_latest => '当前已是最新版本';

  @override
  String hello_name(String name) {
    return '你好，$name！';
  }

  @override
  String item_count(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 个项目';
  }

  @override
  String get migration_title => '数据迁移';

  @override
  String get migration_detecting => '正在检测旧版数据...';

  @override
  String get migration_found => '发现旧版数据，是否迁移？';

  @override
  String get migration_in_progress => '正在迁移数据...';

  @override
  String get migration_success => '数据迁移完成';

  @override
  String get migration_failed => '数据迁移失败';

  @override
  String get migration_backup => '正在备份旧版数据...';

  @override
  String get migration_skip => '跳过迁移';

  @override
  String get migration_start => '开始迁移';

  @override
  String get migration_config => '迁移配置';

  @override
  String get migration_programs => '迁移程序列表';

  @override
  String get migration_categories => '迁移分类';

  @override
  String get migration_themes => '迁移主题';

  @override
  String get migration_verify => '校验迁移数据...';

  @override
  String get migration_verify_pass => '迁移校验通过';

  @override
  String get migration_verify_fail => '迁移校验失败，数据条目不一致';

  @override
  String get featureInProgress => '功能开发中...';

  @override
  String get tool_freeToolbox => 'FREE工具箱';

  @override
  String get tool_apkInstaller => 'APK批量安装工具';

  @override
  String get tool_fileDedup => '批量文件查重清理工具';

  @override
  String get tool_extensionChanger => '批量扩展名修改器';

  @override
  String get tool_fileRenamer => '批量重命名工具';

  @override
  String get tool_fileScanner => '文件扫描器';

  @override
  String get tool_fileMover => '文件移动工具';

  @override
  String get tool_systemControl => '系统时间管理与设备控制工具';

  @override
  String get tool_bookmarkManager => 'Edge书签管理器';

  @override
  String get tool_imageClassifier => 'ImageClassifier';

  @override
  String get toolDesc_apkInstaller => '批量安装 APK 应用文件';

  @override
  String get toolDesc_fileDedup => '扫描并删除重复文件，释放磁盘空间';

  @override
  String get toolDesc_extensionChanger => '批量修改文件扩展名';

  @override
  String get toolDesc_fileRenamer => '按照规则批量重命名文件';

  @override
  String get toolDesc_fileScanner => '扫描目录文件并统计信息';

  @override
  String get toolDesc_fileMover => '按照规则批量移动文件到目标目录';

  @override
  String get toolDesc_systemControl => '同步系统时间和控制设备状态';

  @override
  String get toolDesc_bookmarkManager => '管理浏览器书签';

  @override
  String get toolDesc_imageClassifier => '使用 AI 对图片进行分类整理';

  @override
  String get toolDesc_toolbox => 'FREE 综合工具箱';

  @override
  String get toolDesc_default => '工具';

  @override
  String get category_fileManagement => '文件管理';

  @override
  String get category_systemTools => '系统工具';

  @override
  String get category_other => '其他';

  @override
  String get appCenter_noTools => '暂无工具';

  @override
  String get appCenter_noToolsDesc => '该分类下没有可用工具';

  @override
  String get appCenter_globalSearch => '全局搜索';

  @override
  String appCenter_useCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '使用 $countString 次';
  }

  @override
  String get browse => '浏览';

  @override
  String get scan => '扫描';

  @override
  String get preview => '预览';

  @override
  String get execute => '执行';

  @override
  String get confirmExecute => '确定执行';

  @override
  String get pause => '暂停';

  @override
  String get monitor => '监控';

  @override
  String get scanning => '正在扫描...';

  @override
  String get executingModification => '正在执行修改...';

  @override
  String get syncing => '正在同步...';

  @override
  String get togglingDevice => '正在切换设备状态...';

  @override
  String get executingPowerAction => '正在执行电源操作...';

  @override
  String get fileDedup_selectDirectoryFirst => '请先选择要扫描的目录';

  @override
  String get fileDedup_selectFilesToDelete => '请先选择要删除的文件';

  @override
  String get fileDedup_noSelectedFiles => '没有选中的文件';

  @override
  String get fileDedup_scanFailed => '扫描失败';

  @override
  String get fileDedup_deleteFailed => '删除失败';

  @override
  String get fileDedup_confirmDelete => '确认删除';

  @override
  String fileDedup_confirmDeleteMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '确定要删除选中的 $countString 个文件吗？\n此操作不可撤销。';
  }

  @override
  String fileDedup_selectedDirectories(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '已选择 $countString 个目录';
  }

  @override
  String get fileDedup_configUpdated => '扫描配置已更新';

  @override
  String get fileDedup_startScan => '开始扫描文件...';

  @override
  String get fileDedup_scanCancelled => '扫描已取消';

  @override
  String get fileDedup_scanComplete => '扫描完成';

  @override
  String fileDedup_startDelete(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '开始删除 $countString 个文件...';
  }

  @override
  String get fileDedup_deleteComplete => '删除完成';

  @override
  String get fileDedup_noDirectorySelected => '尚未选择任何目录';

  @override
  String get fileDedup_removeDirectory => '移除此目录';

  @override
  String get fileDedup_addDirectory => '添加目录';

  @override
  String get fileDedup_clear => '清空';

  @override
  String get fileDedup_directorySelection => '目录选择';

  @override
  String get fileDedup_scanConfig => '扫描配置';

  @override
  String get fileDedup_hashAlgorithm => '哈希算法:';

  @override
  String get fileDedup_minFileSize => '最小文件大小:';

  @override
  String get fileDedup_minFileSizeHint => '0 (不限制)';

  @override
  String get fileDedup_bytes => '字节';

  @override
  String get fileDedup_recursiveScan => '递归扫描子目录';

  @override
  String get fileDedup_startScanBtn => '开始扫描';

  @override
  String get fileDedup_cancelScanBtn => '取消扫描';

  @override
  String fileDedup_deleteSelected(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '删除选中 ($countString)';
  }

  @override
  String get fileDedup_scanningStatus => '扫描中';

  @override
  String get fileDedup_deletingStatus => '正在删除...';

  @override
  String fileDedup_duplicateGroups(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 组重复文件';
  }

  @override
  String get fileDedup_scanResult => '扫描结果';

  @override
  String get fileDedup_scannedFiles => '扫描文件';

  @override
  String get fileDedup_duplicateGroupsCount => '重复组数';

  @override
  String get fileDedup_duplicateFiles => '重复文件';

  @override
  String get fileDedup_releasableSpace => '可释放空间';

  @override
  String get fileDedup_duplicateFileList => '重复文件列表';

  @override
  String get operationLog => '操作日志';

  @override
  String get noLogs => '暂无日志';

  @override
  String get extChanger_directorySelection => '目录选择';

  @override
  String get extChanger_directoryHint => '请选择要修改扩展名的文件目录';

  @override
  String get extChanger_extensionRules => '扩展名规则';

  @override
  String get extChanger_noRules => '暂无规则，点击 + 添加扩展名修改规则';

  @override
  String get extChanger_addRule => '添加规则';

  @override
  String get extChanger_editRule => '编辑规则';

  @override
  String get extChanger_originalExt => '原扩展名（如 .txt 或留空表示无扩展名）';

  @override
  String get extChanger_newExt => '新扩展名（如 .md）';

  @override
  String get extChanger_recursiveSubdirs => '递归应用到子目录';

  @override
  String get extChanger_newExtRequired => '新扩展名不能为空';

  @override
  String get extChanger_noExtension => '(无扩展名)';

  @override
  String get extChanger_previewResult => '预览结果';

  @override
  String get extChanger_pending => '待处理';

  @override
  String get extChanger_confirmExecute => '确认执行';

  @override
  String extChanger_confirmExecuteMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '即将修改 $countString 个文件的扩展名，此操作不可撤销。确定要继续吗？';
  }

  @override
  String get extChanger_noPreview => '暂无预览';

  @override
  String get extChanger_scanThenPreview => '请先扫描目录，然后添加规则并点击预览';

  @override
  String get extChanger_addRuleThenPreview => '请添加规则并点击预览按钮';

  @override
  String get extChanger_generatingPreview => '正在生成预览...';

  @override
  String extChanger_scannedFiles(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '已扫描 $countString 个文件';
  }

  @override
  String extChanger_fileCount(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 个文件';
  }

  @override
  String get sysControl_timeSync => '时间同步';

  @override
  String get sysControl_deviceControl => '设备控制';

  @override
  String get sysControl_systemOperation => '系统操作';

  @override
  String get sysControl_currentSystemTime => '当前系统时间';

  @override
  String get sysControl_autoSync => '自动同步';

  @override
  String get sysControl_ntpServer => 'NTP 服务器';

  @override
  String get sysControl_refreshServerList => '刷新服务器列表';

  @override
  String get sysControl_selectServer => '选择此服务器';

  @override
  String get sysControl_sync => '同步';

  @override
  String get sysControl_manualSetTime => '手动设置时间';

  @override
  String get sysControl_hour => '时';

  @override
  String get sysControl_minute => '分';

  @override
  String get sysControl_setTime => '设置时间';

  @override
  String get sysControl_confirmSetTime => '确认设置系统时间';

  @override
  String get sysControl_confirmSetTimeMessage => '确定要将系统时间设置为：';

  @override
  String get sysControl_timeChangeWarning => '这可能会影响系统日志和证书验证。';

  @override
  String get sysControl_syncResult => '同步结果';

  @override
  String get sysControl_server => '服务器';

  @override
  String get sysControl_localTime => '本地时间';

  @override
  String get sysControl_serverTime => '服务器时间';

  @override
  String get sysControl_timeOffset => '时间偏移';

  @override
  String get sysControl_clearLog => '清除日志';

  @override
  String get sysControl_timeSyncRestriction => '时间同步功能限制';

  @override
  String get sysControl_timeSyncRestrictionDesc =>
      'Android 平台不支持设置系统时间，请在系统设置中同步网络时间。';

  @override
  String get sysControl_deviceSwitches => '设备开关';

  @override
  String get sysControl_wifiSubtitle => '无线网络连接';

  @override
  String get sysControl_bluetoothSubtitle => '蓝牙设备连接';

  @override
  String get sysControl_ethernetSubtitle => '有线网络连接';

  @override
  String get sysControl_deviceList => '设备列表';

  @override
  String get sysControl_refreshDeviceList => '刷新设备列表';

  @override
  String get sysControl_noDeviceDetected => '未检测到设备';

  @override
  String get sysControl_confirmDeviceAction => '确认设备操作';

  @override
  String sysControl_confirmToggleDevice(String action, String device) {
    return '确定要$action $device 吗？';
  }

  @override
  String get sysControl_enable => '启用';

  @override
  String get sysControl_disable => '禁用';

  @override
  String get sysControl_deviceControlRestriction => '设备控制功能限制';

  @override
  String get sysControl_deviceControlRestrictionDesc =>
      'Android 平台的设备控制需要 Platform Channel 支持。';

  @override
  String get sysControl_shutdown => '关机';

  @override
  String get sysControl_restart => '重启';

  @override
  String get sysControl_sleep => '睡眠';

  @override
  String get sysControl_hibernate => '休眠';

  @override
  String get sysControl_lock => '锁定';

  @override
  String get sysControl_powerWarning => '注意：执行关机或重启操作前，请保存所有未保存的工作。';

  @override
  String get sysControl_confirmAction => '确认操作';

  @override
  String get sysControl_systemOperationRestriction => '系统操作功能限制';

  @override
  String get sysControl_systemOperationRestrictionDesc =>
      'Android 平台不支持关机、重启等系统操作。';

  @override
  String get fileMover_sourceDirectory => '源目录';

  @override
  String get fileMover_targetDirectory => '目标目录';

  @override
  String get fileMover_sourceDirHint => '请选择要移动文件的源目录';

  @override
  String get fileMover_targetDirHint => '请选择文件移动的目标目录（可选）';

  @override
  String get fileMover_moveRules => '移动规则';

  @override
  String get fileMover_noRules => '暂无规则，点击 + 添加移动规则（或仅使用目标目录）';

  @override
  String get fileMover_executingMove => '正在执行移动...';

  @override
  String fileMover_confirmMoveMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '即将移动 $countString 个文件，此操作不可撤销。确定要继续吗？';
  }

  @override
  String get fileRenamer_directorySelection => '目录选择';

  @override
  String get fileRenamer_directoryHint => '请选择要重命名文件的目录';

  @override
  String get fileRenamer_ruleSettings => '规则设置';

  @override
  String get fileRenamer_noRules => '暂无规则，点击 + 添加规则或从模板加载';

  @override
  String get fileRenamer_saveAsTemplate => '保存当前规则为模板';

  @override
  String get fileRenamer_saveTemplate => '保存模板';

  @override
  String get fileRenamer_templateName => '模板名称';

  @override
  String get fileRenamer_templateDesc => '模板描述';

  @override
  String get fileRenamer_executingRename => '正在执行重命名...';

  @override
  String fileRenamer_confirmRenameMessage(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '即将重命名 $countString 个文件，此操作不可撤销。确定要继续吗？';
  }

  @override
  String get apkInstaller_deviceList => '设备列表';

  @override
  String get apkInstaller_refreshDeviceList => '刷新设备列表';

  @override
  String get apkInstaller_noDevice => '未发现已连接的设备\n请使用 USB 连接设备或启动无线调试';

  @override
  String get apkInstaller_apkFiles => 'APK 文件';

  @override
  String get apkInstaller_noApkFiles => '尚未添加 APK 文件\n点击下方按钮选择文件';

  @override
  String get apkInstaller_installOptions => '安装选项';

  @override
  String get apkInstaller_replaceInstall => '覆盖安装';

  @override
  String get apkInstaller_replaceInstallDesc => '如果应用已存在，将覆盖原有版本（-r 参数）';

  @override
  String get apkInstaller_allowDowngrade => '允许降级安装';

  @override
  String get apkInstaller_allowDowngradeDesc => '允许安装比当前版本更低的版本（-d 参数）';

  @override
  String get apkInstaller_cancelInstall => '取消安装';

  @override
  String apkInstaller_startInstall(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '开始安装 ($countString)';
  }

  @override
  String apkInstaller_installProgress(int percent) {
    final intl.NumberFormat percentNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String percentString = percentNumberFormat.format(percent);

    return '安装进度: $percentString%';
  }

  @override
  String get apkInstaller_installResult => '安装结果将在此显示';

  @override
  String get apkInstaller_installStats => '安装统计';

  @override
  String get apkInstaller_total => '总计';

  @override
  String get apkInstaller_successCount => '成功';

  @override
  String get apkInstaller_failedCount => '失败';

  @override
  String get apkInstaller_totalDuration => '总耗时';

  @override
  String get apkInstaller_installSuccess => '安装成功';

  @override
  String get apkInstaller_runLog => '运行日志';

  @override
  String get apkInstaller_preparing => '准备中...';

  @override
  String apkInstaller_installing(String name) {
    return '正在安装: $name';
  }

  @override
  String get search_hint => '搜索工具名称或描述...';

  @override
  String get search_inputKeyword => '输入关键词搜索工具';

  @override
  String get search_searchNameOrDesc => '可搜索工具名称或描述';

  @override
  String get search_noResults => '未找到相关工具';

  @override
  String get search_tryOtherKeywords => '尝试使用其他关键词';

  @override
  String get search_open => '打开';

  @override
  String get search_back => '返回';

  @override
  String get search_clear => '清除';

  @override
  String get toolbox_freeToolbox => 'FREE工具箱';

  @override
  String get toolbox_collapseSidebar => '折叠侧边栏';

  @override
  String get toolbox_expandSidebar => '展开侧边栏';

  @override
  String get toolbox_home => '首页';

  @override
  String get toolbox_toolLibrary => '工具库';

  @override
  String get toolbox_programCategories => '程序分类';

  @override
  String get toolbox_addProgram => '添加程序';

  @override
  String get hardware_realtimeMonitor => '实时监控';

  @override
  String get hardware_systemInfo => '系统信息';

  @override
  String get hardware_computerInfo => '计算机信息';

  @override
  String get hardware_cpuInfo => 'CPU 信息';

  @override
  String get hardware_memoryInfo => '内存信息';

  @override
  String hardware_diskInfo(String drive) {
    return '磁盘 $drive';
  }

  @override
  String get hardware_gpuInfo => 'GPU';

  @override
  String hardware_networkInfo(String interface) {
    return '网络 $interface';
  }

  @override
  String get hardware_loadFailed => '加载硬件信息失败';

  @override
  String get hardware_osName => '操作系统';

  @override
  String get hardware_osVersion => '版本';

  @override
  String get hardware_osBuild => '构建号';

  @override
  String get hardware_architecture => '架构';

  @override
  String get hardware_computerName => '计算机名';

  @override
  String get hardware_userName => '用户名';

  @override
  String get hardware_manufacturer => '制造商';

  @override
  String get hardware_model => '型号';

  @override
  String get hardware_productName => '产品名称';

  @override
  String get hardware_biosVersion => 'BIOS版本';

  @override
  String get hardware_baseboardManufacturer => '主板制造商';

  @override
  String get hardware_baseboardProduct => '主板产品';

  @override
  String hardware_coresThreads(int cores, int threads) {
    final intl.NumberFormat coresNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String coresString = coresNumberFormat.format(cores);
    final intl.NumberFormat threadsNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String threadsString = threadsNumberFormat.format(threads);

    return '$coresString核 / $threadsString线程';
  }

  @override
  String get hardware_maxFrequency => '最大频率';

  @override
  String get hardware_l2Cache => 'L2缓存';

  @override
  String get hardware_l3Cache => 'L3缓存';

  @override
  String get hardware_totalCapacity => '总容量';

  @override
  String get hardware_available => '可用';

  @override
  String get hardware_used => '已用';

  @override
  String get hardware_usageRate => '使用率';

  @override
  String get hardware_frequency => '频率';

  @override
  String get hardware_channels => '通道数';

  @override
  String get hardware_fileSystem => '文件系统';

  @override
  String get hardware_driverVersion => '驱动版本';

  @override
  String get hardware_videoMemory => '显存';

  @override
  String get hardware_memoryType => '显存类型';

  @override
  String get hardware_ipAddress => 'IP地址';

  @override
  String get hardware_ipv6Address => 'IPv6地址';

  @override
  String get hardware_macAddress => 'MAC地址';

  @override
  String get hardware_subnetMask => '子网掩码';

  @override
  String get hardware_gateway => '网关';

  @override
  String get hardware_dns => 'DNS';

  @override
  String get hardware_runningProcesses => '运行进程';

  @override
  String get hardware_diskRead => '磁盘读取';

  @override
  String get hardware_diskWrite => '磁盘写入';

  @override
  String get hardware_uploadSpeed => '上传速度';

  @override
  String get hardware_downloadSpeed => '下载速度';

  @override
  String get hardware_uptime => '运行时间';

  @override
  String get imageClassifier_title => '图像分类器';

  @override
  String get imageClassifier_modelSelection => '模型选择';

  @override
  String get imageClassifier_selectModelFile => '选择模型文件 (.onnx / .tflite)';

  @override
  String get imageClassifier_releaseModel => '释放模型';

  @override
  String get imageClassifier_modelInfo => '信息';

  @override
  String get imageClassifier_loadingModel => '正在加载模型，请稍候...';

  @override
  String get imageClassifier_pretrainedModels => '预训练模型（需下载模型文件）:';

  @override
  String get imageClassifier_imageSelection => '图片选择';

  @override
  String get imageClassifier_addImage => '添加图片';

  @override
  String get imageClassifier_addDirectory => '添加目录';

  @override
  String get imageClassifier_sort => '排序';

  @override
  String get imageClassifier_classified => '已分类';

  @override
  String get imageClassifier_pleaseAddImages => '请添加图片进行分类';

  @override
  String get imageClassifier_classificationConfig => '分类配置';

  @override
  String get imageClassifier_confidenceThreshold => '置信度阈值';

  @override
  String get imageClassifier_batchSize => '批量大小';

  @override
  String get imageClassifier_startClassification => '开始分类';

  @override
  String get imageClassifier_classifying => '分类中...';

  @override
  String get imageClassifier_totalImages => '总图片数';

  @override
  String get imageClassifier_processed => '已处理';

  @override
  String get imageClassifier_successRate => '成功率';

  @override
  String get imageClassifier_noResults => '暂无分类结果';

  @override
  String get imageClassifier_selectAndClassify => '选择图片并点击\"开始分类\"进行推理';

  @override
  String get imageClassifier_classificationResults => '分类结果';

  @override
  String get imageClassifier_sortMethod => '排序方式';

  @override
  String get imageClassifier_nameAsc => '文件名升序';

  @override
  String get imageClassifier_nameDesc => '文件名降序';

  @override
  String get imageClassifier_pathAsc => '路径升序';

  @override
  String get imageClassifier_pathDesc => '路径降序';

  @override
  String get imageClassifier_exportResults => '导出结果';

  @override
  String get imageClassifier_exportCsv => '导出为 CSV';

  @override
  String get imageClassifier_exportCsvDesc => '表格格式，可用 Excel 打开';

  @override
  String get imageClassifier_exportJson => '导出为 JSON';

  @override
  String get imageClassifier_exportJsonDesc => '结构化数据格式';

  @override
  String get imageClassifier_copyToClipboard => '复制到剪贴板';

  @override
  String get imageClassifier_copyToClipboardDesc => '复制 JSON 格式到剪贴板';

  @override
  String get imageClassifier_copiedToClipboard => '已复制到剪贴板';

  @override
  String get imageClassifier_exportFailed => '导出失败';

  @override
  String imageClassifier_selectedImages(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '已选择 $countString 张图片';
  }

  @override
  String get imageClassifier_inputSize => '输入尺寸';

  @override
  String get imageClassifier_accuracy => '精度';

  @override
  String get imageClassifier_category => '类别';

  @override
  String get imageClassifier_backend => '后端';

  @override
  String get imageClassifier_params => '参数';

  @override
  String get imageClassifier_speed => '速度';

  @override
  String get imageClassifier_useCase => '适用场景';

  @override
  String get imageClassifier_paramsCount => '参数量';

  @override
  String imageClassifier_classifyingStatus(String text) {
    return '分类中: $text';
  }

  @override
  String imageClassifier_modelLabel(String name) {
    return '模型: $name';
  }

  @override
  String imageClassifier_classLabel(String className, String confidence) {
    return '类别: $className | 置信度: $confidence%';
  }

  @override
  String imageClassifier_errorLabel(String error) {
    return '错误: $error';
  }

  @override
  String get imageClassifier_unknownError => '未知错误';

  @override
  String imageClassifier_exportedToCsv(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '已导出 $countString 条结果到 CSV';
  }

  @override
  String imageClassifier_exportedToJson(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '已导出 $countString 条结果到 JSON';
  }

  @override
  String get imageClassifier_resultsCopied => '结果已复制到剪贴板';

  @override
  String get remove => '移除';

  @override
  String get addRule => '添加规则';

  @override
  String previewStatus_pending(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 待处理';
  }

  @override
  String previewStatus_success(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 成功';
  }

  @override
  String previewStatus_failed(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '$countString 失败';
  }

  @override
  String get generatingPreview => '正在生成预览...';

  @override
  String get noPreview => '暂无预览';

  @override
  String get scanThenPreview => '请先扫描目录，然后添加规则并点击预览';

  @override
  String get addRuleThenPreview => '请添加规则并点击预览按钮';
}
