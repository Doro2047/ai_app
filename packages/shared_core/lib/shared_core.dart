/// Shared Core Library
///
/// A shared Flutter package containing:
/// - Theme system with multiple skins
/// - Utility classes (logging, file, toast, permission, platform)
/// - Error handling and exception classes
/// - Constants and extensions
/// - Common widgets
/// - BLoC base classes
///
/// Usage:
/// ```dart
/// import 'package:shared_core/shared_core.dart';
/// ```
library;

// Theme System
export 'shared_core/theme/app_theme.dart';
export 'shared_core/theme/app_colors.dart';
export 'shared_core/theme/app_radius.dart';
export 'shared_core/theme/app_spacing.dart';
export 'shared_core/theme/app_text_styles.dart';
export 'shared_core/theme/app_typography.dart';
export 'shared_core/theme/app_animation.dart';

// Theme Skins
export 'shared_core/theme/skins/default_light.dart';
export 'shared_core/theme/skins/default_dark.dart';
export 'shared_core/theme/skins/classic_blue.dart';
export 'shared_core/theme/skins/fresh_green.dart';
export 'shared_core/theme/skins/sunset_red.dart';
export 'shared_core/theme/skins/purple_soul.dart';
export 'shared_core/theme/skins/pink_man.dart';

// Utilities
export 'shared_core/utils/export.dart';
export 'shared_core/utils/app_logger.dart';
export 'shared_core/utils/file_utils.dart';
export 'shared_core/utils/toast_utils.dart';
export 'shared_core/utils/permission_utils.dart';
export 'shared_core/utils/platform_utils.dart';

// Error Handling
export 'shared_core/errors/app_exception.dart';
export 'shared_core/errors/error_handler.dart';

// Constants
export 'shared_core/constants/app_constants.dart';

// Extensions
export 'shared_core/extensions/extensions.dart';

// BLoC
export 'shared_core/bloc/base_bloc.dart';
export 'shared_core/bloc/base_event.dart';
export 'shared_core/bloc/base_state.dart';
export 'shared_core/bloc/theme_bloc.dart';

// Models
export 'shared_core/models/base_model.dart';

// Widgets
export 'shared_core/widgets/app_header.dart';
export 'shared_core/widgets/app_scaffold.dart';
export 'shared_core/widgets/app_status_bar.dart';
export 'shared_core/widgets/app_toast.dart';
export 'shared_core/widgets/app_tooltip.dart';
export 'shared_core/widgets/card.dart';
export 'shared_core/widgets/empty_state.dart';
export 'shared_core/widgets/error_widget.dart';
export 'shared_core/widgets/icon_button.dart';
export 'shared_core/widgets/list_item.dart';
export 'shared_core/widgets/loading_widget.dart';
export 'shared_core/widgets/log_panel.dart';
export 'shared_core/widgets/path_selector.dart';
export 'shared_core/widgets/section_header.dart';
export 'shared_core/widgets/shared_widgets.dart';
export 'shared_core/widgets/status_badge.dart';
export 'shared_core/widgets/step_indicator.dart';
export 'shared_core/widgets/widgets.dart';
export 'shared_core/widgets/app_confirm_dialog.dart';
export 'shared_core/widgets/app_progress_dialog.dart';
export 'shared_core/widgets/circular_progress.dart';
export 'shared_core/widgets/file_list_panel.dart';
export 'shared_core/widgets/skeleton_loader.dart';
