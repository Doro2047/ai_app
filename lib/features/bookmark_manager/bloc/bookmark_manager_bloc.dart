library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/bloc/feature_bloc_base.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';

// ============================================================
// Events
// ============================================================

/// 书签管理器事件基类
abstract class BookmarkManagerEvent {
  const BookmarkManagerEvent();
}

/// 文件已加载
class BookmarkManagerFileLoaded extends BookmarkManagerEvent {
  final List<BookmarkNode> bookmarks;

  const BookmarkManagerFileLoaded(this.bookmarks);
}

/// 文件已选择
class BookmarkManagerFileSelected extends BookmarkManagerEvent {
  final String filePath;

  const BookmarkManagerFileSelected(this.filePath);
}

/// 文件夹已选择
class BookmarkManagerFolderSelected extends BookmarkManagerEvent {
  final String folderId;

  const BookmarkManagerFolderSelected(this.folderId);
}

/// 搜索关键词变更
class BookmarkManagerSearchChanged extends BookmarkManagerEvent {
  final String query;

  const BookmarkManagerSearchChanged(this.query);
}

/// 分类变更
class BookmarkManagerCategoryChanged extends BookmarkManagerEvent {
  final String categoryId;

  const BookmarkManagerCategoryChanged(this.categoryId);
}

/// 开始验证链接
class BookmarkManagerValidationStarted extends BookmarkManagerEvent {
  const BookmarkManagerValidationStarted();
}

/// 取消验证
class BookmarkManagerValidationCancelled extends BookmarkManagerEvent {
  const BookmarkManagerValidationCancelled();
}

/// 验证完成
class BookmarkManagerValidationCompleted extends BookmarkManagerEvent {
  final List<LinkValidationResult> results;

  const BookmarkManagerValidationCompleted(this.results);
}

/// 导出书签
class BookmarkManagerExportRequested extends BookmarkManagerEvent {
  final String filePath;

  const BookmarkManagerExportRequested(this.filePath);
}

/// 移动书签
class BookmarkManagerBookmarkMoved extends BookmarkManagerEvent {
  final String bookmarkId;
  final String targetFolderId;

  const BookmarkManagerBookmarkMoved(this.bookmarkId, this.targetFolderId);
}

/// 删除书签
class BookmarkManagerBookmarkDeleted extends BookmarkManagerEvent {
  final String bookmarkId;

  const BookmarkManagerBookmarkDeleted(this.bookmarkId);
}

/// 搜索类型变更
class BookmarkManagerSearchTypeChanged extends BookmarkManagerEvent {
  final String searchType;

  const BookmarkManagerSearchTypeChanged(this.searchType);
}

/// 请求刷新
class BookmarkManagerRefreshRequested extends BookmarkManagerEvent {
  const BookmarkManagerRefreshRequested();
}

/// 清空日志
class BookmarkManagerLogsCleared extends BookmarkManagerEvent {
  const BookmarkManagerLogsCleared();
}

// ============================================================
// State
// ============================================================

/// 书签管理器状态
@immutable
class BookmarkManagerState {
  final List<BookmarkNode> bookmarks;

  final List<BookmarkNode> filteredBookmarks;

  /// 当前选中的文件夹 ID
  final String? selectedFolderId;

  /// 搜索关键词
  final String searchQuery;

  /// 搜索类型 (title/url/all)
  final String searchType;

  /// 当前选中的分类 ID
  final String? selectedCategoryId;

  /// 验证进度 (0.0 - 1.0)
  final double validationProgress;

  /// 当前正在验证的 URL
  final String currentValidatingUrl;

  /// 验证结果
  final List<LinkValidationResult> validationResults;

  /// 统计信息
  final BookmarkStatistics statistics;

  /// 是否正在扫描/加载
  final bool isScanning;

  /// 是否正在验证链接
  final bool isValidating;

  /// 错误信息
  final String? error;

  /// 日志消息
  final List<String> logs;

  /// 当前文件路径
  final String? currentFilePath;

  const BookmarkManagerState({
    this.bookmarks = const [],
    this.filteredBookmarks = const [],
    this.selectedFolderId,
    this.searchQuery = '',
    this.searchType = 'all',
    this.selectedCategoryId,
    this.validationProgress = 0.0,
    this.currentValidatingUrl = '',
    this.validationResults = const [],
    this.statistics = const BookmarkStatistics(),
    this.isScanning = false,
    this.isValidating = false,
    this.error,
    this.logs = const [],
    this.currentFilePath,
  });

  /// 是否有书签
  bool get hasBookmarks => bookmarks.isNotEmpty;

  /// 是否有筛选结果
  bool get hasFilteredResults => filteredBookmarks.isNotEmpty;

  /// 是否有错误
  bool get hasError => error != null;

  /// 链接总数
  int get totalLinks => bookmarks.where((b) => b.isUrl).length;

  /// 文件夹总数
  int get totalFolders => bookmarks.where((b) => b.isFolder).length;

  BookmarkManagerState copyWith({
    List<BookmarkNode>? bookmarks,
    List<BookmarkNode>? filteredBookmarks,
    String? selectedFolderId,
    String? searchQuery,
    String? searchType,
    String? selectedCategoryId,
    double? validationProgress,
    String? currentValidatingUrl,
    List<LinkValidationResult>? validationResults,
    BookmarkStatistics? statistics,
    bool? isScanning,
    bool? isValidating,
    String? error,
    bool clearError = false,
    List<String>? logs,
    String? currentFilePath,
  }) {
    return BookmarkManagerState(
      bookmarks: bookmarks ?? this.bookmarks,
      filteredBookmarks: filteredBookmarks ?? this.filteredBookmarks,
      selectedFolderId: selectedFolderId ?? this.selectedFolderId,
      searchQuery: searchQuery ?? this.searchQuery,
      searchType: searchType ?? this.searchType,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      validationProgress: validationProgress ?? this.validationProgress,
      currentValidatingUrl:
          currentValidatingUrl ?? this.currentValidatingUrl,
      validationResults: validationResults ?? this.validationResults,
      statistics: statistics ?? this.statistics,
      isScanning: isScanning ?? this.isScanning,
      isValidating: isValidating ?? this.isValidating,
      error: clearError ? null : (error ?? this.error),
      logs: logs ?? this.logs,
      currentFilePath: currentFilePath ?? this.currentFilePath,
    );
  }
}

// ============================================================
// BLoC
// ============================================================

/// 书签管理器 BLoC
class BookmarkManagerBloc
    extends FeatureBlocBase<BookmarkManagerEvent, BookmarkManagerState> {
  final BookmarkRepository _bookmarkRepository;
  final LinkValidatorRepository _linkValidatorRepository;
  // ignore: unused_field
  final CategoryRepository _categoryRepository;

  CancellationToken? _cancelToken;

  BookmarkManagerBloc({
    BookmarkRepository? bookmarkRepository,
    LinkValidatorRepository? linkValidatorRepository,
    CategoryRepository? categoryRepository,
  })  : _bookmarkRepository = bookmarkRepository ?? BookmarkRepository(),
        _linkValidatorRepository =
            linkValidatorRepository ?? LinkValidatorRepository(),
        _categoryRepository = categoryRepository ?? CategoryRepository(),
        super(const BookmarkManagerState()) {
    on<BookmarkManagerFileLoaded>(_onFileLoaded);
    on<BookmarkManagerFileSelected>(_onFileSelected);
    on<BookmarkManagerFolderSelected>(_onFolderSelected);
    on<BookmarkManagerSearchChanged>(_onSearchChanged);
    on<BookmarkManagerCategoryChanged>(_onCategoryChanged);
    on<BookmarkManagerValidationStarted>(_onValidationStarted);
    on<BookmarkManagerValidationCancelled>(_onValidationCancelled);
    on<BookmarkManagerValidationCompleted>(_onValidationCompleted);
    on<BookmarkManagerExportRequested>(_onExportRequested);
    on<BookmarkManagerBookmarkMoved>(_onBookmarkMoved);
    on<BookmarkManagerBookmarkDeleted>(_onBookmarkDeleted);
    on<BookmarkManagerSearchTypeChanged>(_onSearchTypeChanged);
    on<BookmarkManagerRefreshRequested>(_onRefreshRequested);
    on<BookmarkManagerLogsCleared>(_onLogsCleared);
  }

  void _addLog(Emitter<BookmarkManagerState> emit, String message) {
    final newLogs = List<String>.from(state.logs)..add(message);
    emit(state.copyWith(logs: newLogs));
  }

  void _applyFilters(Emitter<BookmarkManagerState> emit) {
    var filtered = state.bookmarks;

    if (state.selectedFolderId != null) {
      final folder = _findNode(state.bookmarks, state.selectedFolderId!);
      if (folder != null && folder.id.isNotEmpty) {
        filtered = folder.children;
      }
    }

    if (state.searchQuery.isNotEmpty) {
      filtered = _bookmarkRepository.searchBookmarks(
        filtered,
        state.searchQuery,
      );
    }

    emit(state.copyWith(filteredBookmarks: filtered));
  }

  void _onFileLoaded(
    BookmarkManagerFileLoaded event,
    Emitter<BookmarkManagerState> emit,
  ) {
    emit(state.copyWith(
      bookmarks: event.bookmarks,
      isScanning: false,
      clearError: true,
    ));
    _applyFilters(emit);

    final links = event.bookmarks.where((b) => b.isUrl).length;
    final folders = event.bookmarks.where((b) => b.isFolder).length;
    _addLog(emit, '书签加载完成: 共 ${event.bookmarks.length} 个书签, '
        '$links 个链接, $folders 个文件夹');
  }

  Future<void> _onFileSelected(
    BookmarkManagerFileSelected event,
    Emitter<BookmarkManagerState> emit,
  ) async {
    final filePath = event.filePath.trim();
    if (filePath.isEmpty) {
      emit(state.copyWith(error: '请先选择书签文件'));
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      emit(state.copyWith(error: '书签文件不存在: $filePath'));
      return;
    }

    emit(state.copyWith(
      isScanning: true,
      validationProgress: 0.0,
      validationResults: [],
      clearError: true,
    ));
    _addLog(emit, '开始加载书签: $filePath');

    try {
      final bookmarks = await _bookmarkRepository.parseBookmarksFile(filePath);

      emit(state.copyWith(
        bookmarks: bookmarks,
        isScanning: false,
        currentFilePath: filePath,
      ));
      _applyFilters(emit);

      final links = bookmarks.where((b) => b.isUrl).length;
      final folders = bookmarks.where((b) => b.isFolder).length;
      _addLog(emit, '书签加载完成: 共 ${bookmarks.length} 个书签, '
          '$links 个链接, $folders 个文件夹');
    } catch (e) {
      _addLog(emit, '加载书签失败: $e');
      emit(state.copyWith(
        isScanning: false,
        error: '加载书签失败: $e',
      ));
    }
  }

  void _onFolderSelected(
    BookmarkManagerFolderSelected event,
    Emitter<BookmarkManagerState> emit,
  ) {
    emit(state.copyWith(selectedFolderId: event.folderId));
    _applyFilters(emit);

    final folder = _findNode(state.bookmarks, event.folderId);
    if (folder != null) {
      _addLog(emit, '已选择文件夹: ${folder.name}');
    }
  }

  void _onSearchChanged(
    BookmarkManagerSearchChanged event,
    Emitter<BookmarkManagerState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
    _applyFilters(emit);
  }

  void _onCategoryChanged(
    BookmarkManagerCategoryChanged event,
    Emitter<BookmarkManagerState> emit,
  ) {
    emit(state.copyWith(selectedCategoryId: event.categoryId));

    if (event.categoryId.isNotEmpty) {
      _addLog(emit, '已选择分类: ${event.categoryId}');
    }
  }

  void _onSearchTypeChanged(
    BookmarkManagerSearchTypeChanged event,
    Emitter<BookmarkManagerState> emit,
  ) {
    emit(state.copyWith(searchType: event.searchType));
    _applyFilters(emit);
  }

  Future<void> _onValidationStarted(
    BookmarkManagerValidationStarted event,
    Emitter<BookmarkManagerState> emit,
  ) async {
    final links = _collectAllUrls(state.bookmarks);

    if (links.isEmpty) {
      emit(state.copyWith(error: '没有可验证的链接'));
      return;
    }

    _cancelToken = CancellationToken();
    final results = <LinkValidationResult>[];

    emit(state.copyWith(
      isValidating: true,
      validationProgress: 0.0,
      validationResults: [],
      clearError: true,
    ));
    _addLog(emit, '开始验证 ${links.length} 个链接...');

    try {
      final validationResults = await _linkValidatorRepository.validateLinks(
        links.map((l) => l.url ?? '').toList(),
        cancelToken: _cancelToken,
        onProgress: (completed, total) {
          if (!isClosed) {
            emit(state.copyWith(validationProgress: completed / total));
          }
        },
        onResult: (result) {
          results.add(result);
          if (!isClosed) {
            emit(state.copyWith(
              currentValidatingUrl: result.url,
              validationResults: List.from(results),
            ));
          }
        },
      );

      if (_cancelToken?.isCancelled == true) {
        _addLog(emit, '验证已取消');
        emit(state.copyWith(isValidating: false));
        return;
      }

      final validCount = validationResults.where((r) => r.isValid).length;
      final invalidCount = validationResults.where((r) => !r.isValid).length;

      _addLog(emit, '验证完成: 有效 $validCount, 无效 $invalidCount');

      add(BookmarkManagerValidationCompleted(validationResults));
    } catch (e) {
      _addLog(emit, '验证失败: $e');
      emit(state.copyWith(
        isValidating: false,
        error: '验证失败: $e',
      ));
    }
  }

  void _onValidationCancelled(
    BookmarkManagerValidationCancelled event,
    Emitter<BookmarkManagerState> emit,
  ) {
    _cancelToken?.cancel();
    _addLog(emit, '正在取消验证...');
  }

  void _onValidationCompleted(
    BookmarkManagerValidationCompleted event,
    Emitter<BookmarkManagerState> emit,
  ) {
    final invalidCount = event.results.where((r) => !r.isValid).length;

    final stats = state.statistics.copyWith(
      totalLinks: state.totalLinks,
      validatedLinks: event.results.length,
      invalidLinks: invalidCount,
    );

    emit(state.copyWith(
      isValidating: false,
      validationProgress: 1.0,
      validationResults: event.results,
      statistics: stats,
    ));
  }

  Future<void> _onExportRequested(
    BookmarkManagerExportRequested event,
    Emitter<BookmarkManagerState> emit,
  ) async {
    try {
      final success = await _bookmarkRepository.exportBookmarks(
        state.bookmarks,
        event.filePath,
      );
      if (success) {
        _addLog(emit, '书签已导出: ${event.filePath}');
      } else {
        emit(state.copyWith(error: '导出失败'));
        _addLog(emit, '导出失败');
      }
    } catch (e) {
      emit(state.copyWith(error: '导出失败: $e'));
      _addLog(emit, '导出失败: $e');
    }
  }

  void _onBookmarkMoved(
    BookmarkManagerBookmarkMoved event,
    Emitter<BookmarkManagerState> emit,
  ) {
    final updatedBookmarks = _bookmarkRepository.moveBookmarkNode(
      state.bookmarks,
      event.bookmarkId,
      event.targetFolderId,
    );
    emit(state.copyWith(bookmarks: updatedBookmarks));
    _applyFilters(emit);
    _addLog(emit, '书签已移动');
  }

  void _onBookmarkDeleted(
    BookmarkManagerBookmarkDeleted event,
    Emitter<BookmarkManagerState> emit,
  ) {
    final updatedBookmarks = _bookmarkRepository.deleteBookmark(
      state.bookmarks,
      event.bookmarkId,
    );
    emit(state.copyWith(bookmarks: updatedBookmarks));
    _applyFilters(emit);
    _addLog(emit, '书签已删除');
  }

  void _onRefreshRequested(
    BookmarkManagerRefreshRequested event,
    Emitter<BookmarkManagerState> emit,
  ) {
    _applyFilters(emit);
    _addLog(emit, '已刷新');
  }

  void _onLogsCleared(
    BookmarkManagerLogsCleared event,
    Emitter<BookmarkManagerState> emit,
  ) {
    emit(state.copyWith(logs: []));
  }

  BookmarkNode? _findNode(List<BookmarkNode> nodes, String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
      if (node.isFolder) {
        final found = _findNode(node.children, id);
        if (found != null) return found;
      }
    }
    return null;
  }

  List<BookmarkNode> _collectAllUrls(List<BookmarkNode> nodes) {
    final result = <BookmarkNode>[];
    for (final node in nodes) {
      if (node.isUrl && (node.url ?? '').isNotEmpty) {
        result.add(node);
      }
      if (node.isFolder) {
        result.addAll(_collectAllUrls(node.children));
      }
    }
    return result;
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel();
    return super.close();
  }
}
