import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../features/app_center/views/app_center_page.dart';
import '../../../features/apk_installer/views/apk_installer_page.dart';
import '../../../features/bookmark_manager/views/bookmark_manager_page.dart';
import '../../../features/extension_changer/views/extension_changer_page.dart';
import '../../../features/file_dedup/views/file_dedup_page.dart';
import '../../../features/file_mover/views/file_mover_page.dart';
import '../../../features/file_renamer/views/file_renamer_page.dart';
import '../../../features/file_scanner/views/file_scanner_page.dart';
import '../../../features/image_classifier/views/image_classifier_page.dart';
import '../../../features/search/views/global_search_page.dart';
import '../../../features/system_control/views/system_control_page.dart';
import '../../../features/toolbox/views/toolbox_page.dart';

@TypedGoRoute<HomeRoute>(path: '/')
class HomeRoute extends GoRouteData {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AppCenterPage();
  }
}

@TypedGoRoute<SearchRoute>(path: '/search')
class SearchRoute extends GoRouteData {
  const SearchRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const GlobalSearchPage();
  }
}

@TypedGoRoute<ToolboxRoute>(path: '/toolbox')
class ToolboxRoute extends GoRouteData {
  const ToolboxRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ToolboxPage();
  }
}

@TypedGoRoute<ApkInstallerRoute>(path: '/apk-installer')
class ApkInstallerRoute extends GoRouteData {
  const ApkInstallerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ApkInstallerPage();
  }
}

@TypedGoRoute<FileDedupRoute>(path: '/file-dedup')
class FileDedupRoute extends GoRouteData {
  const FileDedupRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FileDedupPage();
  }
}

@TypedGoRoute<ExtensionChangerRoute>(path: '/extension-changer')
class ExtensionChangerRoute extends GoRouteData {
  const ExtensionChangerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ExtensionChangerPage();
  }
}

@TypedGoRoute<FileRenamerRoute>(path: '/file-renamer')
class FileRenamerRoute extends GoRouteData {
  const FileRenamerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FileRenamerPage();
  }
}

@TypedGoRoute<FileScannerRoute>(path: '/file-scanner')
class FileScannerRoute extends GoRouteData {
  const FileScannerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FileScannerPage();
  }
}

@TypedGoRoute<FileMoverRoute>(path: '/file-mover')
class FileMoverRoute extends GoRouteData {
  const FileMoverRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FileMoverPage();
  }
}

@TypedGoRoute<SystemControlRoute>(path: '/system-control')
class SystemControlRoute extends GoRouteData {
  const SystemControlRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SystemControlPage();
  }
}

@TypedGoRoute<BookmarkManagerRoute>(path: '/bookmark-manager')
class BookmarkManagerRoute extends GoRouteData {
  const BookmarkManagerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BookmarkManagerPage();
  }
}

@TypedGoRoute<ImageClassifierRoute>(path: '/image-classifier')
class ImageClassifierRoute extends GoRouteData {
  const ImageClassifierRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ImageClassifierPage();
  }
}
