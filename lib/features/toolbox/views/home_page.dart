/// 首页面板
///
/// 硬件信息面板，实时监控数据展示。
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/hardware_bloc.dart';
import '../models/hardware_info.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';

/// 首页面板
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HardwareBloc, HardwareState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('加载硬件信息失败', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(state.error!, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => context.read<HardwareBloc>().add(
                        const HardwareInfoRequested(),
                      ),
                  child: const Text('重试'),
                ),
              ],
            ),
          );
        }

        return _HomePageContent(info: state.hardwareInfo, stats: state.realtimeStats);
      },
    );
  }
}

class _HomePageContent extends StatelessWidget {
  final HardwareInfo info;
  final RealtimeStats stats;

  const _HomePageContent({required this.info, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 实时监控卡片
          _RealtimeMonitorCard(stats: stats),
          const SizedBox(height: AppSpacing.lg),
          // 系统信息
          _InfoSection(
            title: '系统信息',
            icon: Icons.computer,
            items: [
              _InfoItem('操作系统', info.system.osName),
              _InfoItem('版本', info.system.osVersion),
              _InfoItem('构建号', info.system.osBuild),
              _InfoItem('架构', info.system.osArchitecture),
              _InfoItem('计算机名', info.system.computerName),
              _InfoItem('用户名', info.system.userName),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 计算机信息
          _InfoSection(
            title: '计算机信息',
            icon: Icons.memory,
            items: [
              _InfoItem('制造商', info.computer.manufacturer),
              _InfoItem('型号', info.computer.model),
              _InfoItem('产品名称', info.computer.productName),
              _InfoItem('BIOS版本', info.computer.biosVersion),
              _InfoItem('主板制造商', info.computer.baseboardManufacturer),
              _InfoItem('主板产品', info.computer.baseboardProduct),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // CPU 信息
          _InfoSection(
            title: 'CPU 信息',
            icon: Icons.speed,
            items: [
              _InfoItem('名称', info.cpu.name),
              _InfoItem('核心/线程', '${info.cpu.cores}核 / ${info.cpu.threads}线程'),
              _InfoItem('最大频率', info.cpu.maxSpeed),
              _InfoItem('制造商', info.cpu.manufacturer),
              _InfoItem('L2缓存', info.cpu.l2Cache),
              _InfoItem('L3缓存', info.cpu.l3Cache),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 内存信息
          _InfoSection(
            title: '内存信息',
            icon: Icons.ramen_dining,
            items: [
              _InfoItem('总容量', info.memory.total),
              _InfoItem('可用', info.memory.available),
              _InfoItem('已用', info.memory.used),
              _InfoItem('使用率', info.memory.usedPercent),
              _InfoItem('频率', info.memory.frequency),
              _InfoItem('通道数', info.memory.channels),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // 磁盘信息
          ...info.disks.map((disk) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _InfoSection(
                  title: '磁盘 ${disk.drive}',
                  icon: Icons.storage,
                  items: [
                    _InfoItem('总容量', disk.total),
                    _InfoItem('可用', disk.free),
                    _InfoItem('已用', disk.used),
                    _InfoItem('使用率', disk.usedPercent),
                    _InfoItem('文件系统', disk.fileSystem),
                    _InfoItem('型号', disk.model),
                  ],
                ),
              )),
          // GPU 信息
          ...info.gpus.map((gpu) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _InfoSection(
                  title: 'GPU',
                  icon: Icons.videogame_asset,
                  items: [
                    _InfoItem('名称', gpu.name),
                    _InfoItem('驱动版本', gpu.driverVersion),
                    _InfoItem('显存', gpu.memoryTotal),
                    _InfoItem('显存类型', gpu.memoryType),
                  ],
                ),
              )),
          // 网络信息
          ...info.networks.map((net) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _InfoSection(
                  title: '网络 ${net.interfaceName}',
                  icon: Icons.wifi,
                  items: [
                    _InfoItem('IP地址', net.ipAddress),
                    _InfoItem('IPv6地址', net.ipv6Address),
                    _InfoItem('MAC地址', net.macAddress),
                    _InfoItem('子网掩码', net.subnetMask),
                    _InfoItem('网关', net.gateway),
                    _InfoItem('DNS', net.dnsServers),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// 实时监控卡片
class _RealtimeMonitorCard extends StatelessWidget {
  final RealtimeStats stats;

  const _RealtimeMonitorCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monitor_heart_outlined,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('实时监控', style: theme.textTheme.titleMedium),
                const Spacer(),
                // 监控开关
                BlocBuilder<HardwareBloc, HardwareState>(
                  builder: (context, state) {
                    return FilledButton.tonalIcon(
                      onPressed: () => context.read<HardwareBloc>().add(
                            const RealtimeMonitoringToggled(),
                          ),
                      icon: Icon(
                        state.isMonitoring ? Icons.pause : Icons.play_arrow,
                        size: 18,
                      ),
                      label: Text(state.isMonitoring ? '暂停' : '监控'),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _UsageBar(
                    label: 'CPU',
                    value: stats.cpuUsage,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: _UsageBar(
                    label: '内存',
                    value: stats.memoryUsage,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.xl,
              runSpacing: AppSpacing.sm,
              children: [
                _StatChip(label: '运行进程', value: '${stats.runningProcesses}'),
                _StatChip(label: '磁盘读取', value: stats.diskReadSpeed),
                _StatChip(label: '磁盘写入', value: stats.diskWriteSpeed),
                _StatChip(label: '上传速度', value: stats.networkUploadSpeed),
                _StatChip(label: '下载速度', value: stats.networkDownloadSpeed),
                _StatChip(label: '运行时间', value: stats.uptime),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 使用率进度条
class _UsageBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _UsageBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: (value / 100).clamp(0.0, 1.0),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

/// 状态标签
class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        )),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        )),
      ],
    );
  }
}

/// 信息区块
class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoItem> items;

  const _InfoSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...items,
          ],
        ),
      ),
    );
  }
}

/// 信息项
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
