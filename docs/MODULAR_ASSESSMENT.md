# Modular Splitting Assessment

## Current Architecture

The project is a monolithic Flutter application (ai_app v3.0.0) structured as a feature-first architecture. All code resides in a single `lib/` directory with the following top-level organization:

```
lib/
  app/           -- Application shell (routing, DI, localization, root widget)
  core/          -- Core infrastructure (constants, DI, errors, network, storage, theme, utils)
  features/      -- 11 feature modules (each with bloc/models/repositories/views)
  l10n/          -- Localization files (en, zh)
  shared/        -- Shared components (bloc base, models, widgets)
  main.dart      -- Entry point
```

### Key Architectural Characteristics

- **Dependency Injection**: Centralized in `app/app_di.dart` using GetIt. All feature repositories and blocs are registered in a single function, creating tight coupling between the DI configuration and every feature module.
- **Routing**: Defined in `app/routes/app_router.dart` and `app/routes/routes.dart`, importing all feature page views directly. The `toolPages` constant list in `app_router.dart` is also consumed by `app_center` and `search` features.
- **State Management**: All features use flutter_bloc with a shared `FeatureBlocBase` base class. Theme and locale state are managed by global singletons (`ThemeBloc`, `LocaleBloc`).
- **Storage**: `StorageService` wraps Hive and is accessed globally via GetIt. Some features (e.g., `toolbox/program_repository`) also use Hive directly with separate boxes.
- **Cross-feature Dependencies**: `file_mover` and `extension_changer` both import `file_scanner/models/file_scan_result.dart`, creating a direct feature-to-feature dependency.

### Dependency Graph (Simplified)

```
main.dart
  -> app/ (DI setup, BlocObserver, Hive init)
    -> core/ (constants, storage, network, theme, utils)
    -> shared/ (bloc base, widgets)
    -> features/* (all features registered in DI)

features/app_center -> app/routes/app_router.dart (toolPages)
features/search     -> app/routes/app_router.dart (toolPages)
features/file_mover -> features/file_scanner/models (FileScanResult)
features/extension_changer -> features/file_scanner/models (FileScanResult)

All feature views -> shared/widgets/ (AppScaffold, etc.)
All feature views -> core/theme/ (via Theme.of(context))
All feature repos -> core/ (indirectly via constants, utils)
```

---

## Module Independence Analysis

### High Independence (Can be extracted first)

These modules have minimal dependencies on other feature modules and can be extracted with relatively low effort.

| Module | External Dependencies | Notes |
|--------|----------------------|-------|
| **bookmark_manager** | `uuid`, `shared/` widgets, `core/` theme | Self-contained; parses/manages browser bookmark JSON files. No cross-feature imports. Repository uses only `dart:io`, `dart:convert`, and `uuid`. |
| **apk_installer** | `shared/` widgets, `core/` theme | Self-contained; wraps ADB commands via `AdbClient`. Only depends on `dart:io` for process execution. No cross-feature imports. |
| **system_control** | `process_run`, `shared/` widgets, `core/` theme | Self-contained; uses `process_run` shell for Windows system commands. No cross-feature imports. Platform-specific (Windows/Android). |
| **image_classifier** | `shared/` widgets, `core/` theme | Self-contained; model loading and inference logic. Currently in mock mode. No cross-feature imports. |
| **file_dedup** | `crypto`, `shared/` widgets, `core/` theme | Self-contained; file hashing and duplicate detection. No cross-feature imports. Uses `crypto` package for MD5/SHA hashing. |
| **file_renamer** | `shared/` widgets, `core/` theme | Self-contained; rule-based file renaming. No cross-feature imports. Uses `dart:isolate` for scanning. |

### Medium Independence (Can be extracted with some refactoring)

These modules have some cross-module dependencies that need to be resolved before extraction.

| Module | External Dependencies | Refactoring Needed |
|--------|----------------------|-------------------|
| **file_scanner** | `shared/` widgets, `core/` theme | Its `FileScanResult` model is imported by `file_mover` and `extension_changer`. If extracted, the model must be moved to a shared package or duplicated. |
| **file_mover** | `file_scanner/models` (`FileScanResult`), `shared/` widgets, `core/` theme | Direct import of `file_scanner` models. Must either: (a) depend on `file_scanner` package, or (b) share models via a common package. |
| **extension_changer** | `file_scanner/models` (`FileScanResult`), `shared/` widgets, `core/` theme | Same situation as `file_mover`. Direct import of `file_scanner` models. |
| **toolbox** | `hive_flutter`, `uuid`, `shared/` widgets, `core/` theme | Uses Hive directly (separate box `toolbox_programs`) instead of the global `StorageService`. Relatively self-contained but has its own persistence layer. |
| **search** | `app/routes/app_router.dart` (`toolPages`), `shared/` widgets, `core/` theme | Depends on the `toolPages` list from `app_router.dart` to know what tools exist. This coupling must be abstracted (e.g., via a tool registry interface). |

### Low Independence (Should remain in main app)

These modules are tightly coupled to the application core and serve as glue/orchestration layers.

| Module | Reason for Low Independence |
|--------|---------------------------|
| **app_center** | The home page that aggregates all tools. Imports `app_router.dart` (`toolPages`), `app_di.dart` (`getIt`/`StorageService`), and `platform_utils`. It is the application entry point and navigation hub. |
| **app/** (shell) | Contains routing, DI, localization, and root widget. All features are wired together here. This is the composition root and must remain in the main app. |
| **core/** | Infrastructure layer shared by all features. Must remain accessible to all packages. Should be extracted as a separate package first, then depended upon. |
| **shared/** | Shared UI components and bloc bases used by all features. Same as core -- should be extracted as a package. |
| **l10n/** | Localization files tied to the application. Would be shared across packages. |

---

## Recommended Package Structure

### Package 1: ai_app_core

**Purpose**: Core infrastructure package providing shared foundations for all feature packages.

**Contents**:
- `core/constants/` -- AppConstants, storage keys, network timeouts
- `core/errors/` -- AppException, ErrorHandler
- `core/network/` -- ApiClient (Dio wrapper)
- `core/storage/` -- StorageService, DataMigrator, AppConfig
- `core/utils/` -- AppLogger, FileUtils, IsolateHelper, PermissionUtils, PlatformUtils, ToastUtils
- `core/di/` -- ServiceLocator exports (getIt, setupDependencies, resetDependencies)
- `shared/bloc/` -- BaseBloc, BaseEvent, BaseState, FeatureBlocBase
- `shared/models/` -- BaseModel

**Dependencies**:
- `flutter`, `flutter_bloc`, `get_it`, `hive`, `hive_flutter`, `dio`, `logging`, `path_provider`, `permission_handler`, `crypto`, `path`

**Rationale**: This package eliminates the most fundamental coupling -- all features currently depend on `core/` and `shared/bloc/`. By extracting these first, every subsequent feature extraction becomes straightforward.

---

### Package 2: ai_app_ui

**Purpose**: Shared UI components, theme system, and design tokens used across all feature pages.

**Contents**:
- `core/theme/` -- AppTheme, SkinConfig, all 7 skin definitions, AppTypography, AppSpacing, AppRadius, AppColors, AppAnimation
- `shared/widgets/` -- AppScaffold, AppHeader, AppStatusBar, AppToast, AppConfirmDialog, AppProgressDialog, AppTooltip, Card, EmptyState, ErrorWidget, FileListPanel, PathSelector, LogPanel, SkeletonLoader, StatusBadge, StepIndicator, ListItem, IconButton, CircularProgress, LoadingWidget, SectionHeader, SharedWidgets (Gap, SimpleAppCard)
- `shared/bloc/theme_bloc.dart` -- ThemeBloc (theme state management)
- `shared/bloc/locale_bloc.dart` -- LocaleBloc (locale state management)

**Dependencies**:
- `ai_app_core`
- `flutter`, `flutter_bloc`, `hive_flutter`

**Rationale**: Every feature page uses `AppScaffold`, theme system, and shared widgets. Extracting these into a UI package allows features to depend on a stable UI contract. ThemeBloc and LocaleBloc are global state that must be provided by the app shell but defined in the UI package.

---

### Package 3: ai_app_file_tools

**Purpose**: File management tools package grouping related file operation features that share models and logic.

**Contents**:
- `features/file_scanner/` -- File scanner (base scanning capability)
- `features/file_dedup/` -- File deduplication
- `features/file_renamer/` -- File renaming
- `features/file_mover/` -- File moving
- `features/extension_changer/` -- Extension changing

**Dependencies**:
- `ai_app_core`
- `ai_app_ui`
- `crypto`, `path`, `uuid`

**Rationale**: These five features form a natural cluster. `file_scanner` provides the `FileScanResult` model and scanning logic that `file_mover` and `extension_changer` depend on. Grouping them in one package eliminates cross-package model dependencies while still achieving modular isolation from the rest of the app. If finer granularity is desired later, `file_scanner` can be split out first (since it is the dependency provider).

---

### Remaining Features (Separate packages or stay in main app)

| Feature | Recommended Package | Notes |
|---------|-------------------|-------|
| **bookmark_manager** | `ai_app_bookmark_manager` | Fully independent; can be its own package |
| **apk_installer** | `ai_app_apk_installer` | Fully independent; can be its own package |
| **system_control** | `ai_app_system_control` | Fully independent; platform-specific |
| **image_classifier** | `ai_app_image_classifier` | Fully independent; AI inference module |
| **toolbox** | `ai_app_toolbox` | Nearly independent; uses its own Hive box |
| **search** | Stay in main app initially | Depends on tool registry; needs abstraction first |
| **app_center** | Stay in main app | Application entry point and navigation hub |

---

## Migration Steps

### Phase 1: Extract Foundation Packages (Low Risk)

1. **Create `packages/ai_app_core/`**
   - Move `core/constants/`, `core/errors/`, `core/network/`, `core/storage/`, `core/utils/` into the package
   - Move `shared/bloc/base_bloc.dart`, `shared/bloc/base_event.dart`, `shared/bloc/base_state.dart`, `shared/bloc/feature_bloc_base.dart` into the package
   - Move `shared/models/` into the package
   - Add `ai_app_core` as a dependency in the main app's `pubspec.yaml`
   - Update all imports across the project
   - Run tests to verify no regressions

2. **Create `packages/ai_app_ui/`**
   - Move `core/theme/` into the package
   - Move `shared/widgets/` into the package
   - Move `shared/bloc/theme_bloc.dart` and `shared/bloc/locale_bloc.dart` into the package
   - Add `ai_app_core` and `ai_app_ui` as dependencies in the main app
   - Update all imports
   - Run tests to verify no regressions

### Phase 2: Extract File Tools Package (Medium Risk)

3. **Create `packages/ai_app_file_tools/`**
   - Move `features/file_scanner/` into the package (first, since others depend on it)
   - Move `features/file_dedup/` into the package
   - Move `features/file_renamer/` into the package
   - Move `features/file_mover/` into the package
   - Move `features/extension_changer/` into the package
   - Resolve the `FileScanResult` cross-import: it stays within the same package, so no changes needed
   - Add `ai_app_core` and `ai_app_ui` as dependencies
   - Update DI registration in `app_di.dart` to import from the package
   - Update route imports in `app_router.dart`
   - Run tests to verify no regressions

### Phase 3: Extract Independent Features (Low Risk)

4. **Create `packages/ai_app_bookmark_manager/`**
   - Move `features/bookmark_manager/` into the package
   - Add `ai_app_core` and `ai_app_ui` as dependencies
   - Update DI and routing in main app
   - Run tests

5. **Create `packages/ai_app_apk_installer/`**
   - Move `features/apk_installer/` into the package
   - Add `ai_app_core` and `ai_app_ui` as dependencies
   - Update DI and routing in main app
   - Run tests

6. **Create `packages/ai_app_system_control/`**
   - Move `features/system_control/` into the package
   - Add `ai_app_core` and `ai_app_ui` as dependencies
   - Update DI and routing in main app
   - Run tests

7. **Create `packages/ai_app_image_classifier/`**
   - Move `features/image_classifier/` into the package
   - Add `ai_app_core` and `ai_app_ui` as dependencies
   - Update DI and routing in main app
   - Run tests

8. **Create `packages/ai_app_toolbox/`**
   - Move `features/toolbox/` into the package
   - Add `ai_app_core` and `ai_app_ui` as dependencies
   - Update DI and routing in main app
   - Run tests

### Phase 4: Abstract Cross-cutting Concerns (Higher Risk)

9. **Create Tool Registry abstraction**
   - Define a `ToolRegistry` interface in `ai_app_core` that provides tool metadata (name, route, icon, description)
   - Move `toolPages` list and `ToolPageInfo` from `app_router.dart` into a registry pattern
   - Each feature package registers its tools via the registry
   - `app_center` and `search` depend on the registry interface instead of concrete route definitions

10. **Refactor DI registration**
    - Each feature package provides its own `registerDependencies(GetIt getIt)` function
    - Main app's `app_di.dart` calls each package's registration function
    - This eliminates the monolithic DI file that imports all features

11. **Refactor `search` feature**
    - After tool registry is in place, extract `search` into its own package
    - `SearchRepository` depends on `ToolRegistry` interface instead of `app_router.dart`

---

## Risks and Considerations

### High Priority Risks

1. **Import Path Explosion**: Moving code to packages changes all import paths from relative imports (e.g., `../../../core/theme/app_theme.dart`) to package imports (e.g., `package:ai_app_ui/theme/app_theme.dart`). This is a large-scale, error-prone refactoring. **Mitigation**: Use IDE refactoring tools; do one package at a time with full test runs between each.

2. **DI Registration Coupling**: `app_di.dart` currently imports every feature's repository and bloc classes. After extraction, the main app must depend on every feature package just for DI wiring. **Mitigation**: Each feature package exports a `registerDependencies()` function, reducing the main app's knowledge of feature internals.

3. **Hive Box Initialization Order**: `main.dart` calls `Hive.initFlutter()` before `setupDependencies()`. Some repositories (e.g., `ProgramRepository`) open their own Hive boxes during `init()`. If packages initialize Hive independently, there could be race conditions. **Mitigation**: Keep Hive initialization in the main app; pass the initialized Hive instance or use a lazy initialization pattern in packages.

4. **Cross-feature Model Dependency**: `file_mover` and `extension_changer` import `FileScanResult` from `file_scanner`. If these are in separate packages, this creates a package-to-package dependency. **Mitigation**: Group all file tools in one package (`ai_app_file_tools`) as recommended, or extract `FileScanResult` to `ai_app_core`.

### Medium Priority Risks

5. **Theme and Localization Coupling**: All feature pages use `Theme.of(context)` and rely on `ThemeBloc`/`LocaleBloc` being provided by the app shell. Extracted packages must document this requirement. **Mitigation**: `ai_app_ui` package defines the theme system; the app shell provides `BlocProvider` wrappers. Document the contract clearly.

6. **Tool Registry Synchronization**: The `toolPages` list in `app_router.dart` and the `_getToolDescription()` methods in `app_center_page.dart` and `search_repository.dart` contain duplicate tool metadata. After extraction, keeping these synchronized across packages is a maintenance risk. **Mitigation**: Implement the `ToolRegistry` pattern so each feature self-registers its metadata.

7. **Testing Complexity**: Integration tests that span multiple packages become harder to write and maintain. **Mitigation**: Each package should have comprehensive unit and widget tests. Integration tests remain in the main app.

8. **Build Time Impact**: Adding packages increases the number of `pubspec.yaml` files and dependency resolution steps. **Mitigation**: Use Melos or similar tool for monorepo management. The impact is minimal for a project of this size.

### Low Priority Risks

9. **Version Compatibility**: If packages are published or shared, version skew between `ai_app_core` and feature packages could cause issues. **Mitigation**: Use path dependencies during development; consider strict version constraints if publishing.

10. **Feature Intercommunication**: Currently, features don't communicate with each other directly. If future requirements need cross-feature events (e.g., file dedup notifying file scanner), a new event bus or messaging layer will be needed. **Mitigation**: Plan for this in `ai_app_core` with an event bus interface, but don't implement until needed.

11. **Platform-specific Code**: `system_control` and `apk_installer` have platform-specific implementations (Windows commands, ADB). These may need conditional imports or platform interfaces when extracted. **Mitigation**: Use Flutter's platform interface pattern; keep platform-specific code behind abstract interfaces.

### Assumptions

- The project will continue using GetIt for DI (not switching to Provider or Riverpod)
- The project will continue using flutter_bloc for state management
- Hive remains the local storage solution
- The feature set is relatively stable; no major new features are expected that would change the dependency graph significantly
- The team is comfortable with monorepo-style package management (multiple packages in one repository)
