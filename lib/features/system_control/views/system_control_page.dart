/// 系统控制主页面
///
/// 包含时间同步、设备控制和系统操作三个标签页。
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../app/app_di.dart';
import '../bloc/system_control_bloc.dart';
import '../models/models.dart';
import '../repositories/power_control_repository.dart';
import 'android_unavailable_notice.dart';

/// 系统控制页面
class SystemControlPage extends StatefulWidget {
  const SystemControlPage({super.key});

  @override
  State<SystemControlPage> createState() => _SystemControlPageState();
}

class _SystemControlPageState extends State<SystemControlPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentTime = DateTime.now();
    _startClock();

    // 初始加载数据
    context.read<SystemControlBloc>().add(const SystemControlNtpServersRefreshed());
    context.read<SystemControlBloc>().add(const SystemControlNetworkDevicesRefreshed());
  }

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<SystemControlBloc>(),
      child: BlocBuilder<SystemControlBloc, SystemControlState>(
        builder: (context, state) {
          String statusText;
          if (state.error != null) {
            statusText = '错误: ${state.error}';
          } else if (state.isSyncing) {
            statusText = '正在同步...';
          } else if (state.isToggling) {
            statusText = '正在切换设备状态...';
          } else if (state.isPowerActionExecuting) {
            statusText = '正在执行电源操作...';
          } else {
            statusText = '就绪';
          }

          return AppScaffold(
            title: '系统时间管理与设备控制工具',
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '时间同步', icon: Icon(Icons.sync)),
                    Tab(text: '设备控制', icon: Icon(Icons.devices)),
                    Tab(text: '系统操作', icon: Icon(Icons.power_settings_new)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _TimeSyncTab(state: state, currentTime: _currentTime),
                      _DeviceControlTab(state: state),
                      _SystemOperationTab(state: state),
                    ],
                  ),
                ),
              ],
            ),
            statusBarText: statusText,
            statusBarProgress: 0.0,
            showStatusBarProgress: false,
          );
        },
      ),
    );
  }
}

// ============================================================
// 时间同步标签页
// ============================================================

class _TimeSyncTab extends StatefulWidget {
  final SystemControlState state;
  final DateTime currentTime;

  const _TimeSyncTab({required this.state, required this.currentTime});

  @override
  State<_TimeSyncTab> createState() => _TimeSyncTabState();
}

class _TimeSyncTabState extends State<_TimeSyncTab> {
  bool _autoSync = false;
  late TextEditingController _hourController;
  late TextEditingController _minuteController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _hourController = TextEditingController(text: now.hour.toString().padLeft(2, '0'));
    _minuteController = TextEditingController(text: now.minute.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const AndroidUnavailableNotice(
        title: '时间同步功能限制',
        description: 'Android 平台不支持设置系统时间，请在系统设置中同步网络时间。',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 当前系统时间卡片
          _buildCurrentTimeCard(),
          const SizedBox(height: 16),

          // NTP 服务器列表
          _buildNtpServerCard(),
          const SizedBox(height: 16),

          // 手动设置时间
          _buildManualSetTimeCard(),
          const SizedBox(height: 16),

          // 同步结果
          if (widget.state.syncResults.isNotEmpty) _buildSyncResultsCard(),
          const SizedBox(height: 16),

          // 操作日志
          if (widget.state.logs.isNotEmpty) _buildLogCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeCard() {
    final now = widget.currentTime;
    final timeStr =
        '${now.year}年${now.month.toString().padLeft(2, '0')}月${now.day.toString().padLeft(2, '0')}日 '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 24),
                const SizedBox(width: 8),
                Text(
                  '当前系统时间',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Switch(
                  value: _autoSync,
                  onChanged: (value) {
                    setState(() => _autoSync = value);
                  },
                ),
                const Text('自动同步'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              timeStr,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNtpServerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns, size: 24),
                const SizedBox(width: 8),
                Text(
                  'NTP 服务器',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: '刷新服务器列表',
                  onPressed: () {
                    context
                        .read<SystemControlBloc>()
                        .add(const SystemControlNtpServersRefreshed());
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.state.isSyncing)
              const LinearProgressIndicator()
            else
              ...widget.state.ntpServers.map((server) => _buildServerTile(server)),
          ],
        ),
      ),
    );
  }

  Widget _buildServerTile(TimeServer server) {
    final isSelected = server.host == widget.state.selectedServer;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.dns),
        title: Text(server.name),
        subtitle: Text('${server.host}\n${server.description}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              tooltip: '选择此服务器',
              onPressed: () {
                // 选中服务器，但不同步
              },
            ),
            FilledButton.icon(
              onPressed: widget.state.isSyncing
                  ? null
                  : () {
                      context
                          .read<SystemControlBloc>()
                          .add(SystemControlTimeSyncRequested(server.host));
                    },
              icon: const Icon(Icons.sync, size: 16),
              label: const Text('同步'),
            ),
          ],
        ),
        onTap: () {
          // 选中服务器
        },
      ),
    );
  }

  Widget _buildManualSetTimeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_calendar, size: 24),
                const SizedBox(width: 8),
                Text(
                  '手动设置时间',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _hourController,
                    decoration: const InputDecoration(
                      labelText: '时',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _minuteController,
                    decoration: const InputDecoration(
                      labelText: '分',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showManualTimeDialog(context);
                  },
                  icon: const Icon(Icons.access_time),
                  label: const Text('设置时间'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showManualTimeDialog(BuildContext context) {
    final now = DateTime.now();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认设置系统时间'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('确定要将系统时间设置为：'),
            const SizedBox(height: 8),
            Text(
              '${now.year}年${now.month}月${now.day}日 '
              '${_hourController.text}:${_minuteController.text}:00',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('这可能会影响系统日志和证书验证。',
                style: TextStyle(color: Colors.orange)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final hour = int.tryParse(_hourController.text) ?? now.hour;
              final minute = int.tryParse(_minuteController.text) ?? now.minute;
              final newTime = DateTime(now.year, now.month, now.day, hour, minute);
              context.read<SystemControlBloc>().add(SystemControlTimeSet(newTime));
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncResultsCard() {
    final results = widget.state.syncResults;
    if (results.isEmpty) return const SizedBox.shrink();

    final latest = results.last;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  latest.success ? Icons.check_circle : Icons.error,
                  color: latest.success ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '同步结果',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('服务器', latest.serverName),
            _buildInfoRow('本地时间', latest.localTime),
            _buildInfoRow('服务器时间', latest.serverTime),
            _buildInfoRow('时间偏移', latest.offsetDescription),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, size: 24),
                const SizedBox(width: 8),
                Text(
                  '操作日志',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  tooltip: '清除日志',
                  onPressed: () {
                    // 日志清除功能可通过添加事件实现
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.state.logs
                      .map((log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• $log',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 设备控制标签页
// ============================================================

class _DeviceControlTab extends StatefulWidget {
  final SystemControlState state;

  const _DeviceControlTab({required this.state});

  @override
  State<_DeviceControlTab> createState() => _DeviceControlTabState();
}

class _DeviceControlTabState extends State<_DeviceControlTab> {
  @override
  void initState() {
    super.initState();
    // 初始加载设备信息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<SystemControlBloc>()
          .add(const SystemControlDeviceInfoRefreshed());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemControlBloc, SystemControlState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Android 提示
              if (Platform.isAndroid)
                const AndroidUnavailableNotice(
                  title: '设备控制功能限制',
                  description: 'Android 平台的设备控制需要 Platform Channel 支持。',
                ),

              // 设备开关卡片
              _buildDeviceSwitchesCard(state),
              const SizedBox(height: 16),

              // 设备列表
              _buildDeviceListCard(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceSwitchesCard(SystemControlState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.toggle_on, size: 24),
                const SizedBox(width: 8),
                Text(
                  '设备开关',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _buildSwitchTile(
              icon: Icons.wifi,
              title: 'WiFi',
              subtitle: '无线网络连接',
              value: state.wifiEnabled,
              onChanged: (enabled) {
                _showDeviceToggleConfirm(
                  context,
                  'WiFi',
                  enabled,
                  () {
                    context
                        .read<SystemControlBloc>()
                        .add(SystemControlWifiToggled(enabled));
                  },
                );
              },
            ),
            _buildSwitchTile(
              icon: Icons.bluetooth,
              title: '蓝牙',
              subtitle: '蓝牙设备连接',
              value: state.bluetoothEnabled,
              onChanged: (enabled) {
                _showDeviceToggleConfirm(
                  context,
                  '蓝牙',
                  enabled,
                  () {
                    context
                        .read<SystemControlBloc>()
                        .add(SystemControlBluetoothToggled(enabled));
                  },
                );
              },
            ),
            _buildSwitchTile(
              icon: Icons.lan,
              title: '以太网',
              subtitle: '有线网络连接',
              value: state.ethernetEnabled,
              onChanged: (enabled) {
                _showDeviceToggleConfirm(
                  context,
                  '以太网',
                  enabled,
                  () {
                    // 可以通过添加事件实现
                    context
                        .read<SystemControlBloc>()
                        .add(const SystemControlNetworkDevicesRefreshed());
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: widget.state.isToggling ? null : onChanged,
      ),
    );
  }

  Widget _buildDeviceListCard(SystemControlState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices, size: 24),
                const SizedBox(width: 8),
                Text(
                  '设备列表',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: '刷新设备列表',
                  onPressed: () {
                    context
                        .read<SystemControlBloc>()
                        .add(const SystemControlDeviceInfoRefreshed());
                  },
                ),
              ],
            ),
            const Divider(),
            if (state.isSyncing)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.devices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('未检测到设备'),
                ),
              )
            else
              ...state.devices.map((device) => _buildDeviceTile(device)),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceTile(DeviceInfo device) {
    IconData icon;
    switch (device.type) {
      case DeviceType.bluetooth:
        icon = Icons.bluetooth;
        break;
      case DeviceType.wifi:
        icon = Icons.wifi;
        break;
      case DeviceType.network:
        icon = Icons.lan;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(device.name),
        subtitle: Text(device.description),
        trailing: StatusBadge(
          text: device.status.displayName,
          status: device.status == DeviceStatus.enabled
              ? AppBadgeStatus.success
              : device.status == DeviceStatus.disabled
                  ? AppBadgeStatus.warning
                  : AppBadgeStatus.info,
        ),
      ),
    );
  }

  void _showDeviceToggleConfirm(
    BuildContext context,
    String deviceName,
    bool enabled,
    VoidCallback onConfirm,
  ) {
    if (Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deviceName 控制需要 Platform Channel 支持'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认设备操作'),
        content: Text('确定要${enabled ? '启用' : '禁用'} $deviceName 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 系统操作标签页
// ============================================================

class _SystemOperationTab extends StatelessWidget {
  final SystemControlState state;

  const _SystemOperationTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const AndroidUnavailableNotice(
        title: '系统操作功能限制',
        description: 'Android 平台不支持关机、重启等系统操作。',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPowerActionCard(context),
          const SizedBox(height: 16),
          if (state.logs.isNotEmpty) _buildLogCard(context),
        ],
      ),
    );
  }

  Widget _buildPowerActionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.power_settings_new, size: 24),
                const SizedBox(width: 8),
                Text(
                  '系统操作',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildPowerButton(
                  context: context,
                  icon: Icons.power_off,
                  label: '关机',
                  color: Colors.red,
                  action: PowerAction.shutdown,
                ),
                _buildPowerButton(
                  context: context,
                  icon: Icons.restart_alt,
                  label: '重启',
                  color: Colors.orange,
                  action: PowerAction.restart,
                ),
                _buildPowerButton(
                  context: context,
                  icon: Icons.bedtime,
                  label: '睡眠',
                  color: Colors.blue,
                  action: PowerAction.sleep,
                ),
                _buildPowerButton(
                  context: context,
                  icon: Icons.bedtime_outlined,
                  label: '休眠',
                  color: Colors.purple,
                  action: PowerAction.hibernate,
                ),
                _buildPowerButton(
                  context: context,
                  icon: Icons.lock,
                  label: '锁定',
                  color: Colors.grey,
                  action: PowerAction.lock,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '注意：执行关机或重启操作前，请保存所有未保存的工作。',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required PowerAction action,
  }) {
    return SizedBox(
      width: 100,
      height: 80,
      child: Card(
        child: InkWell(
          onTap: state.isPowerActionExecuting
              ? null
              : () {
                  _showPowerActionConfirm(context, action);
                },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPowerActionConfirm(BuildContext context, PowerAction action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认操作'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getPowerActionIcon(action),
              size: 48,
              color: _getPowerActionColor(action),
            ),
            const SizedBox(height: 16),
            Text(
              action.confirmationMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<SystemControlBloc>()
                  .add(SystemControlPowerAction(action));
            },
            style: FilledButton.styleFrom(
              backgroundColor: _getPowerActionColor(action),
            ),
            child: Text('确认${action.displayName}'),
          ),
        ],
      ),
    );
  }

  IconData _getPowerActionIcon(PowerAction action) {
    switch (action) {
      case PowerAction.shutdown:
        return Icons.power_off;
      case PowerAction.restart:
        return Icons.restart_alt;
      case PowerAction.sleep:
        return Icons.bedtime;
      case PowerAction.hibernate:
        return Icons.bedtime_outlined;
      case PowerAction.lock:
        return Icons.lock;
    }
  }

  Color _getPowerActionColor(PowerAction action) {
    switch (action) {
      case PowerAction.shutdown:
        return Colors.red;
      case PowerAction.restart:
        return Colors.orange;
      case PowerAction.sleep:
        return Colors.blue;
      case PowerAction.hibernate:
        return Colors.purple;
      case PowerAction.lock:
        return Colors.grey;
    }
  }

  Widget _buildLogCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list_alt, size: 24),
                const SizedBox(width: 8),
                Text(
                  '操作日志',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: context
                      .read<SystemControlBloc>()
                      .state.logs
                      .map((log) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              '• $log',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
