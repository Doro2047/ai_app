library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/models.dart';
import '../repositories/repositories.dart';

abstract class BookmarkManagerEvent {
  const BookmarkManagerEvent();
}

class BookmarkManagerFileLoaded extends BookmarkManagerEvent {
  final List<BookmarkNode> bookmarks;
  const BookmarkManagerFileLoaded(this.bookmarks);
}

class BookmarkManagerFileSelected extends BookmarkManagerEvent {
  final String filePath;
  const BookmarkManagerFileSelected(this.filePath);
}

class BookmarkManagerFolderSelected extends BookmarkManagerEvent {
  final String folderId;
  const BookmarkManagerFolderSelected(this.folderId);
}

class BookmarkManagerSearchChanged extends BookmarkManagerEvent {
  final String query;
  const BookmarkManagerSearchChanged(this.query);
}

class BookmarkManagerCategoryChanged extends BookmarkManagerEvent {
  final String categoryId;
  const BookmarkManagerCategoryChanged(this.categoryId);
}

class BookmarkManagerValidationStarted extends BookmarkManagerEvent {
  const BookmarkManagerValidationStarted();
}

class BookmarkManagerValidationCancelled extends BookmarkManagerEvent {
  const BookmarkManagerValidationCancelled();
}

class BookmarkManagerValidationCompleted extends BookmarkManagerEvent {
  final List<LinkValidationResult> results;
  const BookmarkManagerValidationCompleted(this.results);
}

class BookmarkManagerExportRequested extends BookmarkManagerEvent {
  final String filePath;
  const BookmarkManagerExportRequested(this.filePath);
}

class BookmarkManagerBookmarkMoved extends BookmarkManagerEvent {
  final String bookmarkId;
  final String targetFolderId;
  const BookmarkManagerBookmarkMoved(this.bookmarkId, this.targetFolderId);
}

class BookmarkManagerBookmarkDeleted extends BookmarkManagerEvent {
  final String bookmarkId;
  const BookmarkManagerBookmarkDeleted(this.bookmarkId);
}

class BookmarkManagerSearchTypeChanged extends BookmarkManagerEvent {
  final String searchType;
  const BookmarkManagerSearchTypeChanged(this.searchType);
}

class BookmarkManagerRefreshRequested extends BookmarkManagerEvent {
  const BookmarkManagerRefreshRequested();
}

class BookmarkManagerLogsCleared extends BookmarkManagerEvent {
  const BookmarkManagerLogsCleared();
}

@immutable
class BookmarkManagerState {
  final List<BookmarkNode> bookmarks;
  final List<BookmarkNode> filteredBookmarks;
  final String? selectedFolderId;
  final String searchQuery;
  final String searchType;
  final String? selectedCategoryId;
  final double validationProgress;
  final String currentValidatingUrl;
  final List<LinkValidationResult> validationResults;
  final BookmarkStatistics statistics;
  final bool isScanning;
  final bool isValidating;
  final String? error;
  final List<String> logs;
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

  bool get hasBookmarks => bookmarks.isNotEmpty;
  bool get hasFilteredResults => filteredBookmarks.isNotEmpty;
  bool get hasError => error != null;
  int get totalLinks => bookmarks.where((b) => b.isUrl).length;
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

class BookmarkManagerBloc
    extends Bloc<BookmarkManagerEvent, BookmarkManagerState> {
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
    _addLog(emit, 'Bookmarks loaded: ${event.bookmarks.length} total, '
        '$links links, $folders folders');
  }

  Future<void> _onFileSelected(
    BookmarkManagerFileSelected event,
    Emitter<BookmarkManagerState> emit,
  ) async {
    final filePath = event.filePath.trim();
    if (filePath.isEmpty) {
      emit(state.copyWith(error: 'Please select a bookmark file first'));
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) {
      emit(state.copyWith(error: 'Bookmark file not found: $filePath'));
      return;
    }

    emit(state.copyWith(
      isScanning: true,
      validationProgress: 0.0,
      validationResults: [],
      clearError: true,
    ));
    _addLog(emit, 'Loading bookmarks: $filePath');

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
      _addLog(emit, 'Bookmarks loaded: ${bookmarks.length} total, '
          '$links links, $folders folders');
    } catch (e) {
      _addLog(emit, 'Failed to load bookmarks: $e');
      emit(state.copyWith(
        isScanning: false,
        error: 'Failed to load bookmarks: $e',
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
      _addLog(emit, 'Folder selected: ${folder.name}');
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
      _addLog(emit, 'Category selected: ${event.categoryId}');
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
      emit(state.copyWith(error: 'No links to validate'));
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
    _addLog(emit, 'Validating ${links.length} links...');

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
        _addLog(emit, 'Validation cancelled');
        emit(state.copyWith(isValidating: false));
        return;
      }

      final validCount = validationResults.where((r) => r.isValid).length;
      final invalidCount = validationResults.where((r) => !r.isValid).length;

      _addLog(emit, 'Validation complete: $validCount valid, $invalidCount invalid');

      add(BookmarkManagerValidationCompleted(validationResults));
    } catch (e) {
      _addLog(emit, 'Validation failed: $e');
      emit(state.copyWith(
        isValidating: false,
        error: 'Validation failed: $e',
      ));
    }
  }

  void _onValidationCancelled(
    BookmarkManagerValidationCancelled event,
    Emitter<BookmarkManagerState> emit,
  ) {
    _cancelToken?.cancel();
    _addLog(emit, 'Cancelling validation...');
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
        _addLog(emit, 'Bookmarks exported: ${event.filePath}');
      } else {
        emit(state.copyWith(error: 'Export failed'));
        _addLog(emit, 'Export failed');
      }
    } catch (e) {
      emit(state.copyWith(error: 'Export failed: $e'));
      _addLog(emit, 'Export failed: $e');
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
    _addLog(emit, 'Bookmark moved');
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
    _addLog(emit, 'Bookmark deleted');
  }

  void _onRefreshRequested(
    BookmarkManagerRefreshRequested event,
    Emitter<BookmarkManagerState> emit,
  ) {
    _applyFilters(emit);
    _addLog(emit, 'Refreshed');
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
