import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/bookmark_node.dart';
import '../repositories/bookmark_repository.dart';

abstract class BookmarkEvent {
  const BookmarkEvent();
}

class BookmarksFileSelected extends BookmarkEvent {
  final String filePath;
  const BookmarksFileSelected(this.filePath);
}

class BookmarksLoaded extends BookmarkEvent {
  final List<BookmarkNode> bookmarks;
  const BookmarksLoaded(this.bookmarks);
}

class BookmarkSearchChanged extends BookmarkEvent {
  final String query;
  const BookmarkSearchChanged(this.query);
}

class BookmarkDeleteRequested extends BookmarkEvent {
  final String id;
  const BookmarkDeleteRequested(this.id);
}

class BookmarkEditRequested extends BookmarkEvent {
  final String id;
  final String newName;
  final String? newUrl;
  const BookmarkEditRequested(this.id, this.newName, this.newUrl);
}

class BookmarkExpanded extends BookmarkEvent {
  final String id;
  const BookmarkExpanded(this.id);
}

class BookmarkExportRequested extends BookmarkEvent {
  final String outputPath;
  const BookmarkExportRequested(this.outputPath);
}

@immutable
class BookmarkState {
  final List<BookmarkNode> bookmarks;
  final List<BookmarkNode> filteredBookmarks;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final Set<String> expandedFolders;
  final String? currentFilePath;

  const BookmarkState({
    this.bookmarks = const [],
    this.filteredBookmarks = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.expandedFolders = const {},
    this.currentFilePath,
  });

  bool get hasBookmarks => bookmarks.isNotEmpty;
  bool get hasError => error != null;

  int get totalUrls {
    int count = 0;
    for (final node in bookmarks) {
      count += _countUrls(node);
    }
    return count;
  }

  int _countUrls(BookmarkNode node) {
    if (node.isUrl) return 1;
    return node.children.fold(0, (sum, child) => sum + _countUrls(child));
  }

  int get totalFolders {
    int count = 0;
    for (final node in bookmarks) {
      count += _countFolders(node);
    }
    return count;
  }

  int _countFolders(BookmarkNode node) {
    if (node.isUrl) return 0;
    return 1 + node.children.fold(0, (sum, child) => sum + _countFolders(child));
  }

  BookmarkState copyWith({
    List<BookmarkNode>? bookmarks,
    List<BookmarkNode>? filteredBookmarks,
    String? searchQuery,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Set<String>? expandedFolders,
    String? currentFilePath,
  }) {
    return BookmarkState(
      bookmarks: bookmarks ?? this.bookmarks,
      filteredBookmarks: filteredBookmarks ?? this.filteredBookmarks,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      expandedFolders: expandedFolders ?? this.expandedFolders,
      currentFilePath: currentFilePath ?? this.currentFilePath,
    );
  }
}

class BookmarkBloc extends Bloc<BookmarkEvent, BookmarkState> {
  final BookmarkRepository _repository;

  BookmarkBloc({
    BookmarkRepository? repository,
  })  : _repository = repository ?? BookmarkRepository(),
        super(const BookmarkState()) {
    on<BookmarksFileSelected>(_onFileSelected);
    on<BookmarksLoaded>(_onBookmarksLoaded);
    on<BookmarkSearchChanged>(_onSearchChanged);
    on<BookmarkDeleteRequested>(_onDeleteRequested);
    on<BookmarkEditRequested>(_onEditRequested);
    on<BookmarkExpanded>(_onExpanded);
    on<BookmarkExportRequested>(_onExportRequested);
  }

  void _applyFilters(Emitter<BookmarkState> emit) {
    if (state.searchQuery.isEmpty) {
      emit(state.copyWith(filteredBookmarks: state.bookmarks));
    } else {
      final filtered = _repository.searchBookmarks(
        state.bookmarks,
        state.searchQuery,
      );
      emit(state.copyWith(filteredBookmarks: filtered));
    }
  }

  Future<void> _onFileSelected(
    BookmarksFileSelected event,
    Emitter<BookmarkState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final bookmarks = await _repository.parseBookmarksFile(event.filePath);
      emit(state.copyWith(
        bookmarks: bookmarks,
        isLoading: false,
        currentFilePath: event.filePath,
      ));
      _applyFilters(emit);
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load bookmarks: $e',
      ));
    }
  }

  void _onBookmarksLoaded(
    BookmarksLoaded event,
    Emitter<BookmarkState> emit,
  ) {
    emit(state.copyWith(
      bookmarks: event.bookmarks,
      isLoading: false,
      clearError: true,
    ));
    _applyFilters(emit);
  }

  void _onSearchChanged(
    BookmarkSearchChanged event,
    Emitter<BookmarkState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
    _applyFilters(emit);
  }

  void _onDeleteRequested(
    BookmarkDeleteRequested event,
    Emitter<BookmarkState> emit,
  ) {
    final updated = _repository.deleteBookmark(state.bookmarks, event.id);
    emit(state.copyWith(bookmarks: updated));
    _applyFilters(emit);
  }

  void _onEditRequested(
    BookmarkEditRequested event,
    Emitter<BookmarkState> emit,
  ) {
    final updated = _repository.editBookmark(
      state.bookmarks,
      event.id,
      event.newName,
      event.newUrl,
    );
    emit(state.copyWith(bookmarks: updated));
    _applyFilters(emit);
  }

  void _onExpanded(
    BookmarkExpanded event,
    Emitter<BookmarkState> emit,
  ) {
    final updated = Set<String>.from(state.expandedFolders);
    if (updated.contains(event.id)) {
      updated.remove(event.id);
    } else {
      updated.add(event.id);
    }
    emit(state.copyWith(expandedFolders: updated));
  }

  Future<void> _onExportRequested(
    BookmarkExportRequested event,
    Emitter<BookmarkState> emit,
  ) async {
    try {
      final success = await _repository.exportBookmarks(
        state.bookmarks,
        event.outputPath,
      );
      if (!success) {
        emit(state.copyWith(error: 'Export failed'));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Export failed: $e'));
    }
  }
}
