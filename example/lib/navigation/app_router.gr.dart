// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:bloc_small_example/count_page_cubit.dart' as _i1;
import 'package:bloc_small_example/home.dart' as _i2;
import 'package:bloc_small_example/reactive_subject/reacttive_subject_screen.dart'
    as _i3;
import 'package:bloc_small_example/search_page.dart' as _i4;

/// generated route for
/// [_i1.CounterPage]
class CounterRoute extends _i5.PageRouteInfo<void> {
  const CounterRoute({List<_i5.PageRouteInfo>? children})
    : super(CounterRoute.name, initialChildren: children);

  static const String name = 'CounterRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return _i1.CounterPage();
    },
  );
}

/// generated route for
/// [_i2.MyHomePage]
class MyHomeRoute extends _i5.PageRouteInfo<void> {
  const MyHomeRoute({List<_i5.PageRouteInfo>? children})
    : super(MyHomeRoute.name, initialChildren: children);

  static const String name = 'MyHomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.MyHomePage();
    },
  );
}

/// generated route for
/// [_i3.ReactiveSubjectScreen]
class ReactiveSubjectScreen extends _i5.PageRouteInfo<void> {
  const ReactiveSubjectScreen({List<_i5.PageRouteInfo>? children})
    : super(ReactiveSubjectScreen.name, initialChildren: children);

  static const String name = 'ReactiveSubjectScreen';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.ReactiveSubjectScreen();
    },
  );
}

/// generated route for
/// [_i4.SearchPage]
class SearchRoute extends _i5.PageRouteInfo<void> {
  const SearchRoute({List<_i5.PageRouteInfo>? children})
    : super(SearchRoute.name, initialChildren: children);

  static const String name = 'SearchRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return _i4.SearchPage();
    },
  );
}
