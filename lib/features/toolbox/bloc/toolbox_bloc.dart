/// 工具箱 BLoC
///
/// 管理工具箱全局状态：当前分类、搜索查询、侧边栏展开状态等。
library;

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/bloc/feature_bloc_base.dart';
import '../models/category.dart';

// ============================================================
// 事件定义
// ============================================================

@immutable
abstract class ToolboxEvent {
  const ToolboxEvent();
}

/// 工具箱初始化
class ToolboxInitialized extends ToolboxEvent {
  const ToolboxInitialized();
}

/// 分类选择
class CategorySelected extends ToolboxEvent {
  final String categoryId;
  const CategorySelected(this.categoryId);
}

/// 搜索查询变更
class SearchChanged extends ToolboxEvent {
  final String query;
  const SearchChanged(this.query);
}

/// 侧边栏切换
class SidebarToggled extends ToolboxEvent {
  const SidebarToggled();
}

// ============================================================
// 状态定义
// ============================================================

@immutable
class ToolboxState {
  /// 当前选中的分类 ID
  final String currentCategoryId;

  /// 搜索查询
  final String searchQuery;

  /// 侧边栏是否展开
  final bool isSidebarExpanded;

  /// 分类列表
  final List<Category> categories;

  const ToolboxState({
    this.currentCategoryId = 'all',
    this.searchQuery = '',
    this.isSidebarExpanded = true,
    this.categories = const [],
  });

  ToolboxState copyWith({
    String? currentCategoryId,
    String? searchQuery,
    bool? isSidebarExpanded,
    List<Category>? categories,
  }) {
    return ToolboxState(
      currentCategoryId: currentCategoryId ?? this.currentCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isSidebarExpanded: isSidebarExpanded ?? this.isSidebarExpanded,
      categories: categories ?? this.categories,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToolboxState &&
        other.currentCategoryId == currentCategoryId &&
        other.searchQuery == searchQuery &&
        other.isSidebarExpanded == isSidebarExpanded &&
        _listEquals(other.categories, categories);
  }

  @override
  int get hashCode => Object.hash(
        currentCategoryId,
        searchQuery,
        isSidebarExpanded,
        categories.length,
      );

  static bool _listEquals(List<Category> a, List<Category> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ============================================================
// BLoC 定义
// ============================================================

class ToolboxBloc extends FeatureBlocBase<ToolboxEvent, ToolboxState> {
  ToolboxBloc() : super(const ToolboxState()) {
    on<ToolboxInitialized>(_onInitialized);
    on<CategorySelected>(_onCategorySelected);
    on<SearchChanged>(_onSearchChanged);
    on<SidebarToggled>(_onSidebarToggled);
  }

  void _onInitialized(
    ToolboxInitialized event,
    Emitter<ToolboxState> emit,
  ) {
    emit(state.copyWith(categories: DefaultCategories.defaults));
  }

  void _onCategorySelected(
    CategorySelected event,
    Emitter<ToolboxState> emit,
  ) {
    emit(state.copyWith(currentCategoryId: event.categoryId));
  }

  void _onSearchChanged(
    SearchChanged event,
    Emitter<ToolboxState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onSidebarToggled(
    SidebarToggled event,
    Emitter<ToolboxState> emit,
  ) {
    emit(state.copyWith(isSidebarExpanded: !state.isSidebarExpanded));
  }
}
