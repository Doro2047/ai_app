library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shared_core/shared_core.dart';

import '../../../main.dart';
import '../bloc/apk_installer_bloc.dart';
import '../models/models.dart';

class ApkInstallerPage extends StatefulWidget {
  const ApkInstallerPage({super.key});

  @override
  State<ApkInstallerPage> createState() => _ApkInstallerPageState();
}

class _ApkInstallerPageState extends State<ApkInstallerPage> {
  final GlobalKey _logPanelKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ApkInstallerBloc>()
        ..add(const ApkInstallerDevicesRefreshed()),
      child: _ApkInstallerView(logPanelKey: _logPanelKey),
    );
  }
}

class _ApkInstallerView extends StatelessWidget {
  final GlobalKey logPanelKey;

  const _ApkInstallerView({required this.logPanelKey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
        builder: (context, state) {
          return AppScaffold(
            title: 'APK Batch Installer',
            body: _buildBody(context, state),
            showStatusBar: true,
            statusBarText: state.isInstalling
                ? 'Installing: ${state.currentInstallingApk ?? 'Preparing...'}'
                : state.error != null
                    ? 'Error: ${state.error}'
                    : 'Ready',
            statusBarProgress: state.installProgress,
            showStatusBarProgress: state.isInstalling,
            statusBarExtraInfo: state.statistics.totalFiles > 0
                ? 'Success: ${state.statistics.successCount} / Failed: ${state.statistics.failedCount}'
                : null,
          );
        },
    );
  }

  Widget _buildBody(BuildContext context, ApkInstallerState state) {
    final isDesktop = PlatformUtils.isDesktop();

    if (isDesktop) {
      return _DesktopLayout(logPanelKey: logPanelKey);
    } else {
      return _MobileLayout(logPanelKey: logPanelKey);
    }
  }
}

// ============================================================
// Desktop Layout
// ============================================================

class _DesktopLayout extends StatelessWidget {
  final GlobalKey logPanelKey;

  const _DesktopLayout({required this.logPanelKey});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 380,
          child: Column(
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DeviceSection(),
                      SizedBox(height: 16),
                      _ApkFilesSection(),
                      SizedBox(height: 16),
                      _InstallOptionsSection(),
                      SizedBox(height: 16),
                      _ActionButtonsSection(),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _InlineLogPanel(key: logPanelKey),
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        const Expanded(
          child: _ResultsPanel(),
        ),
      ],
    );
  }
}

// ============================================================
// Mobile Layout
// ============================================================

class _MobileLayout extends StatelessWidget {
  final GlobalKey logPanelKey;

  const _MobileLayout({required this.logPanelKey});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DeviceSection(),
          SizedBox(height: 16),
          _ApkFilesSection(),
          SizedBox(height: 16),
          _InstallOptionsSection(),
          SizedBox(height: 16),
          _ActionButtonsSection(),
          SizedBox(height: 16),
          _ResultsPanel(),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ============================================================
// Inline Log Panel (using BLoC logs list)
// ============================================================

class _InlineLogPanel extends StatelessWidget {
  const _InlineLogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
      builder: (context, state) {
        final logs = state.logs;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Logs',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: logs.isEmpty
                    ? Center(
                        child: Text(
                          'No logs yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final level = _getLogLevel(log);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '[${_formatTime(DateTime.now())}]',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '[${_levelText(level)}]',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _levelColor(level, colorScheme),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    log,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: _levelColor(level, colorScheme),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  LogLevel _getLogLevel(String log) {
    if (log.contains('Failed') ||
        log.contains('Error') ||
        log.contains('error') ||
        log.contains('timeout')) {
      return LogLevel.error;
    }
    if (log.contains('Warning') || log.contains('No connected')) {
      return LogLevel.warn;
    }
    return LogLevel.info;
  }

  String _levelText(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warn:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  Color _levelColor(LogLevel level, ColorScheme colorScheme) {
    switch (level) {
      case LogLevel.debug:
        return colorScheme.outline;
      case LogLevel.info:
        return colorScheme.onSurface;
      case LogLevel.warn:
        return const Color(0xFFF59E0B);
      case LogLevel.error:
        return colorScheme.error;
    }
  }

  String _formatTime(DateTime now) {
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}

// ============================================================
// Device Section
// ============================================================

class _DeviceSection extends StatelessWidget {
  const _DeviceSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.devices, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Devices',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
                  builder: (context, state) {
                    return IconButton(
                      onPressed: state.isInstalling
                          ? null
                          : () {
                              context.read<ApkInstallerBloc>().add(
                                    const ApkInstallerDevicesRefreshed(),
                                  );
                            },
                      icon: state.isDevicesLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, size: 20),
                      tooltip: 'Refresh device list',
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 16),
            BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
              builder: (context, state) {
                if (state.isDevicesLoading) {
                  return const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (state.devices.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.devices_other,
                    message: 'No connected devices found\nConnect a device via USB or enable wireless debugging',
                  );
                }

                return Column(
                  children: state.devices.map((device) {
                    final isSelected =
                        device.serialNumber == state.selectedDeviceId;
                    return RadioListTile<String>(
                      value: device.serialNumber,
                      groupValue: state.selectedDeviceId,
                      onChanged: state.isInstalling
                          ? null
                          : (value) {
                              context.read<ApkInstallerBloc>().add(
                                    ApkInstallerDeviceSelected(value!),
                                  );
                            },
                      title: Row(
                        children: [
                          Icon(
                            device.isOnline
                                ? Icons.smartphone
                                : Icons.phone_disabled,
                            size: 18,
                            color: device.isOnline
                                ? colorScheme.primary
                                : colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              device.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${device.serialNumber}  •  ${device.status.toUpperCase()}',
                        style: theme.textTheme.bodySmall,
                      ),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: colorScheme.primary,
                      selected: isSelected,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// APK Files Section
// ============================================================

class _ApkFilesSection extends StatelessWidget {
  const _ApkFilesSection();

  Future<void> _pickFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final paths = result.files
          .map((f) => f.path)
          .whereType<String>()
          .toList();

      if (paths.isNotEmpty) {
        if (!context.mounted) return;
        context.read<ApkInstallerBloc>().add(
              ApkInstallerFilesAdded(paths),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.android,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'APK Files',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
                  builder: (context, state) {
                    return Text(
                      '${state.apkFiles.length} file(s)',
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 16),
            BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
              builder: (context, state) {
                if (state.apkFiles.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.file_open,
                    message: 'No APK files added yet\nClick the button below to select files',
                  );
                }

                return Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.apkFiles.length,
                        itemBuilder: (context, index) {
                          final file = state.apkFiles[index];
                          return _ApkFileTile(file: file);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: state.isInstalling
                              ? null
                              : () => _pickFiles(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: state.isInstalling || state.apkFiles.isEmpty
                              ? null
                              : () {
                                  context.read<ApkInstallerBloc>().add(
                                        const ApkInstallerFilesCleared(),
                                      );
                                },
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// APK File Tile
// ============================================================

class _ApkFileTile extends StatelessWidget {
  final ApkFile file;

  const _ApkFileTile({required this.file});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(
        Icons.file_present,
        color: colorScheme.secondary,
        size: 28,
      ),
      title: Text(
        file.displayName,
        style: theme.textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          if (file.packageName != null) file.packageName,
          if (file.version != null) 'v${file.version}',
          file.formattedSize,
        ].whereType<String>().join('  •  '),
        style: theme.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: () {
          context.read<ApkInstallerBloc>().add(
                ApkInstallerFileRemoved(file.path),
              );
        },
        icon: const Icon(Icons.close, size: 18),
        tooltip: 'Remove',
        visualDensity: VisualDensity.compact,
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }
}

// ============================================================
// Install Options Section
// ============================================================

class _InstallOptionsSection extends StatelessWidget {
  const _InstallOptionsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings,
                    color: Theme.of(context).colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Install Options',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const Divider(height: 16),
            BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
              builder: (context, state) {
                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Replace Install'),
                      subtitle: Text(
                        'Overwrite existing version if app is already installed (-r flag)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      value: state.replace,
                      onChanged: state.isInstalling
                          ? null
                          : (value) {
                              context.read<ApkInstallerBloc>().add(
                                    ApkInstallerReplaceToggled(value),
                                  );
                            },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    SwitchListTile(
                      title: const Text('Allow Downgrade'),
                      subtitle: Text(
                        'Allow installing a lower version than the current one (-d flag)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      value: state.allowDowngrade,
                      onChanged: state.isInstalling
                          ? null
                          : (value) {
                              context.read<ApkInstallerBloc>().add(
                                    ApkInstallerDowngradeToggled(value),
                                  );
                            },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Action Buttons Section
// ============================================================

class _ActionButtonsSection extends StatelessWidget {
  const _ActionButtonsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
      builder: (context, state) {
        final canInstall = state.canInstall;

        if (state.isInstalling) {
          return Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.read<ApkInstallerBloc>().add(
                          const ApkInstallerInstallCancelled(),
                        );
                  },
                  icon: const Icon(Icons.stop, size: 18),
                  label: const Text('Cancel Install'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: canInstall
                    ? () {
                        context.read<ApkInstallerBloc>().add(
                              const ApkInstallerInstallStarted(),
                            );
                      }
                    : null,
                icon: const Icon(Icons.install_mobile, size: 20),
                label: Text(
                  'Start Install (${state.selectedApkFiles.length})',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// Results Panel
// ============================================================

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<ApkInstallerBloc, ApkInstallerState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isInstalling)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircularProgress(
                      size: 100,
                      strokeWidth: 8,
                      progress: state.installProgress,
                      showLabel: true,
                      labelFormat: '{value}',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.currentInstallingApk ?? 'Preparing...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Progress: ${(state.installProgress * 100).toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

            if (state.statistics.totalFiles > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _StatisticsCard(statistics: state.statistics),
              ),

            Expanded(
              child: state.installResults.isEmpty && !state.isInstalling
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: colorScheme.outline.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Install results will appear here',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: state.installResults.length,
                      itemBuilder: (context, index) {
                        final result = state.installResults[index];
                        return _InstallResultTile(result: result);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// Statistics Card
// ============================================================

class _StatisticsCard extends StatelessWidget {
  final InstallStatistics statistics;

  const _StatisticsCard({required this.statistics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Statistics',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              children: [
                _StatItem(
                  label: 'Total',
                  value: '${statistics.totalFiles}',
                  icon: Icons.folder,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Success',
                  value: '${statistics.successCount}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Failed',
                  value: '${statistics.failedCount}',
                  icon: Icons.error,
                  color: colorScheme.error,
                ),
                const Spacer(),
                _StatItem(
                  label: 'Duration',
                  value: statistics.formattedTotalDuration,
                  icon: Icons.timer,
                  color: colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Stat Item
// ============================================================

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ============================================================
// Install Result Tile
// ============================================================

class _InstallResultTile extends StatelessWidget {
  final ApkInstallResult result;

  const _InstallResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          result.success ? Icons.check_circle : Icons.error,
          color: result.success ? Colors.green : colorScheme.error,
          size: 24,
        ),
        title: Text(
          result.apkName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          result.success ? 'Success' : result.statusText,
          style: theme.textTheme.bodySmall?.copyWith(
            color: result.success
                ? Colors.green
                : colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          result.formattedDuration,
          style: theme.textTheme.bodySmall,
        ),
        dense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      ),
    );
  }
}

// ============================================================
// Empty State
// ============================================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
