library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_core/shared_core.dart';

import '../../../injection.dart';
import '../bloc/system_control_bloc.dart';
import '../models/models.dart';
import '../repositories/power_control_repository.dart';
import 'android_unavailable_notice.dart';

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
            statusText = '\u9519\u8BEF: ${state.error}';
          } else if (state.isSyncing) {
            statusText = '\u6B63\u5728\u540C\u6B65...';
          } else if (state.isToggling) {
            statusText = '\u6B63\u5728\u5207\u6362\u8BBE\u5907\u72B6\u6001...';
          } else if (state.isPowerActionExecuting) {
            statusText = '\u6B63\u5728\u6267\u884C\u7535\u6E90\u64CD\u4F5C...';
          } else {
            statusText = '\u5C31\u7EEA';
          }

          return AppScaffold(
            title: '\u7CFB\u7EDF\u65F6\u95F4\u7BA1\u7406\u4E0E\u8BBE\u5907\u63A7\u5236\u5DE5\u5177',
            body: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: '\u65F6\u95F4\u540C\u6B65', icon: Icon(Icons.sync)),
                    Tab(text: '\u8BBE\u5907\u63A7\u5236', icon: Icon(Icons.devices)),
                    Tab(text: '\u7CFB\u7EDF\u64CD\u4F5C', icon: Icon(Icons.power_settings_new)),
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
// Time Sync Tab
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
        title: '\u65F6\u95F4\u540C\u6B65\u529F\u80FD\u9650\u5236',
        description: 'Android \u5E73\u53F0\u4E0D\u652F\u6301\u8BBE\u7F6E\u7CFB\u7EDF\u65F6\u95F4\uFF0C\u8BF7\u5728\u7CFB\u7EDF\u8BBE\u7F6E\u4E2D\u540C\u6B65\u7F51\u7EDC\u65F6\u95F4\u3002',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentTimeCard(),
          const SizedBox(height: 16),
          _buildNtpServerCard(),
          const SizedBox(height: 16),
          _buildManualSetTimeCard(),
          const SizedBox(height: 16),
          if (widget.state.syncResults.isNotEmpty) _buildSyncResultsCard(),
          const SizedBox(height: 16),
          if (widget.state.logs.isNotEmpty) _buildLogCard(),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeCard() {
    final now = widget.currentTime;
    final timeStr =
        '${now.year}\u5E74${now.month.toString().padLeft(2, '0')}\u6708${now.day.toString().padLeft(2, '0')}\u65E5 '
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
                  '\u5F53\u524D\u7CFB\u7EDF\u65F6\u95F4',
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
                const Text('\u81EA\u52A8\u540C\u6B65'),
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
                  'NTP \u670D\u52A1\u5668',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: '\u5237\u65B0\u670D\u52A1\u5668\u5217\u8868',
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
              tooltip: '\u9009\u62E9\u6B64\u670D\u52A1\u5668',
              onPressed: () {
                // Select server
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
              label: const Text('\u540C\u6B65'),
            ),
          ],
        ),
        onTap: () {
          // Select server
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
                  '\u624B\u52A8\u8BBE\u7F6E\u65F6\u95F4',
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
                      labelText: '\u65F6',
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
                      labelText: '\u5206',
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
                  label: const Text('\u8BBE\u7F6E\u65F6\u95F4'),
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
        title: const Text('\u786E\u8BA4\u8BBE\u7F6E\u7CFB\u7EDF\u65F6\u95F4'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u786E\u5B9A\u8981\u5C06\u7CFB\u7EDF\u65F6\u95F4\u8BBE\u7F6E\u4E3A\uFF1A'),
            const SizedBox(height: 8),
            Text(
              '${now.year}\u5E74${now.month}\u6708${now.day}\u65E5 '
              '${_hourController.text}:${_minuteController.text}:00',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('\u8FD9\u53EF\u80FD\u4F1A\u5F71\u54CD\u7CFB\u7EDF\u65E5\u5FD7\u548C\u8BC1\u4E66\u9A8C\u8BC1\u3002',
                style: TextStyle(color: Colors.orange)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('\u53D6\u6D88'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final hour = int.tryParse(_hourController.text) ?? now.hour;
              final minute = int.tryParse(_minuteController.text) ?? now.minute;
              final newTime = DateTime(now.year, now.month, now.day, hour, minute);
              context.read<SystemControlBloc>().add(SystemControlTimeSet(newTime));
            },
            child: const Text('\u786E\u5B9A'),
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
                  '\u540C\u6B65\u7ED3\u679C',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('\u670D\u52A1\u5668', latest.serverName),
            _buildInfoRow('\u672C\u5730\u65F6\u95F4', latest.localTime),
            _buildInfoRow('\u670D\u52A1\u5668\u65F6\u95F4', latest.serverTime),
            _buildInfoRow('\u65F6\u95F4\u504F\u79FB', latest.offsetDescription),
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
                  '\u64CD\u4F5C\u65E5\u5FD7',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.clear_all),
                  tooltip: '\u6E05\u9664\u65E5\u5FD7',
                  onPressed: () {
                    // Clear logs
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
                              '\u2022 $log',
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
// Device Control Tab
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
              if (Platform.isAndroid)
                const AndroidUnavailableNotice(
                  title: '\u8BBE\u5907\u63A7\u5236\u529F\u80FD\u9650\u5236',
                  description: 'Android \u5E73\u53F0\u7684\u8BBE\u5907\u63A7\u5236\u9700\u8981 Platform Channel \u652F\u6301\u3002',
                ),
              _buildDeviceSwitchesCard(state),
              const SizedBox(height: 16),
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
                  '\u8BBE\u5907\u5F00\u5173',
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
              subtitle: '\u65E0\u7EBF\u7F51\u7EDC\u8FDE\u63A5',
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
              title: '\u84DD\u7259',
              subtitle: '\u84DD\u7259\u8BBE\u5907\u8FDE\u63A5',
              value: state.bluetoothEnabled,
              onChanged: (enabled) {
                _showDeviceToggleConfirm(
                  context,
                  '\u84DD\u7259',
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
              title: '\u4EE5\u592A\u7F51',
              subtitle: '\u6709\u7EBF\u7F51\u7EDC\u8FDE\u63A5',
              value: state.ethernetEnabled,
              onChanged: (enabled) {
                _showDeviceToggleConfirm(
                  context,
                  '\u4EE5\u592A\u7F51',
                  enabled,
                  () {
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
                  '\u8BBE\u5907\u5217\u8868',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: '\u5237\u65B0\u8BBE\u5907\u5217\u8868',
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
                  child: Text('\u672A\u68C0\u6D4B\u5230\u8BBE\u5907'),
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
          content: Text('$deviceName \u63A7\u5236\u9700\u8981 Platform Channel \u652F\u6301'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('\u786E\u8BA4\u8BBE\u5907\u64CD\u4F5C'),
        content: Text('\u786E\u5B9A\u8981${enabled ? "\u542F\u7528" : "\u7981\u7528"} $deviceName \u5417\uFF1F'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('\u53D6\u6D88'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('\u786E\u5B9A'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// System Operation Tab
// ============================================================

class _SystemOperationTab extends StatelessWidget {
  final SystemControlState state;

  const _SystemOperationTab({required this.state});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return const AndroidUnavailableNotice(
        title: '\u7CFB\u7EDF\u64CD\u4F5C\u529F\u80FD\u9650\u5236',
        description: 'Android \u5E73\u53F0\u4E0D\u652F\u6301\u5173\u673A\u3001\u91CD\u542F\u7B49\u7CFB\u7EDF\u64CD\u4F5C\u3002',
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
                  '\u7CFB\u7EDF\u64CD\u4F5C',
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
                  label: '\u5173\u673A',
                  color: Colors.red,
                  action: PowerAction.shutdown,
                ),
                _buildPowerButton(
                  context: context,
                  icon: Icons.restart_alt,
                  label: '\u91CD\u542F',
                  color: Colors.orange,
                  action: PowerAction.restart,
                ),
                _buildPowerButton(
                  context: context,
                  icon: Icons.bedtime,
                  label: '\u7761\u7720',
                  color: Colors.blue,
                  action: PowerAction.sleep,
                ),
                _buildPowerButton(
                  context: context,
                  icon: Icons.bedtime_outlined,
                  label: '\u4F11\u7720',
                  color: Colors.purple,
                  action: PowerAction.hibernate,
                ),
                _buildPowerButton(
                  context: context,
                  icon: Icons.lock,
                  label: '\u9501\u5B9A',
                  color: Colors.grey,
                  action: PowerAction.lock,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '\u6CE8\u610F\uFF1A\u6267\u884C\u5173\u673A\u6216\u91CD\u542F\u64CD\u4F5C\u524D\uFF0C\u8BF7\u4FDD\u5B58\u6240\u6709\u672A\u4FDD\u5B58\u7684\u5DE5\u4F5C\u3002',
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
        title: const Text('\u786E\u8BA4\u64CD\u4F5C'),
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
            child: const Text('\u53D6\u6D88'),
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
            child: Text('\u786E\u8BA4${action.displayName}'),
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
                  '\u64CD\u4F5C\u65E5\u5FD7',
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
                              '\u2022 $log',
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
