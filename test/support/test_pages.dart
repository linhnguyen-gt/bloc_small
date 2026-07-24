import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

/// Minimal blocs, cubits and pages used as the subject under test across the
/// DI / delegate / navigation suites.
///
/// Kept in one place rather than redefined per test file so that phase 3's
/// signature changes land in exactly one fixture.

// ---------------------------------------------------------------------------
// State / events
// ---------------------------------------------------------------------------

class TestState extends MainBlocState {
  final int count;

  const TestState({this.count = 0});

  TestState copyWith({int? count}) => TestState(count: count ?? this.count);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is TestState && other.count == count);

  @override
  int get hashCode => count.hashCode;
}

class TestEvent extends MainBlocEvent {
  const TestEvent();
}

class Increment extends TestEvent {
  const Increment();
}

// ---------------------------------------------------------------------------
// Bloc / cubit
// ---------------------------------------------------------------------------

class TestBloc extends MainBloc<TestEvent, TestState>
    with BaseErrorHandlerMixin {
  TestBloc() : super(const TestState()) {
    on<Increment>((event, emit) => emit(state.copyWith(count: state.count + 1)));
  }
}

class TestCubit extends MainCubit<TestState> with BaseErrorHandlerMixin {
  TestCubit() : super(const TestState());

  void increment() => emit(state.copyWith(count: state.count + 1));
}

// ---------------------------------------------------------------------------
// Stateful pages
// ---------------------------------------------------------------------------

class TestBlocPage extends StatefulWidget {
  const TestBlocPage({super.key});

  @override
  State<TestBlocPage> createState() => TestBlocPageState();
}

class TestBlocPageState extends BaseBlocPageState<TestBlocPage, TestBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      child: BlocBuilder<TestBloc, TestState>(
        builder: (context, state) => Text('${state.count}'),
      ),
    );
  }
}

class TestCubitPage extends StatefulWidget {
  const TestCubitPage({super.key});

  @override
  State<TestCubitPage> createState() => TestCubitPageState();
}

class TestCubitPageState extends BaseCubitPageState<TestCubitPage, TestCubit> {
  @override
  Widget buildPage(BuildContext context) {
    return buildLoadingOverlay(
      child: BlocBuilder<TestCubit, TestState>(
        builder: (context, state) => Text('${state.count}'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stateless pages
// ---------------------------------------------------------------------------

class TestStatelessBlocPage extends BaseBlocPage<TestBloc> {
  const TestStatelessBlocPage({super.key});

  @override
  Widget buildPage(BuildContext context, TestBloc bloc) {
    return buildLoadingOverlay(
      child: BlocBuilder<TestBloc, TestState>(
        builder: (context, state) => Text('${state.count}'),
      ),
    );
  }
}

/// Records the bloc handed to [buildPage] on each build.
///
/// Lets a test assert that what the page is given to drive is the same object
/// the tree provides — the divergence C7 was about.
class RecordingStatelessBlocPage extends BaseBlocPage<TestBloc> {
  final List<TestBloc> received;

  const RecordingStatelessBlocPage({required this.received, super.key});

  @override
  Widget buildPage(BuildContext context, TestBloc bloc) {
    received.add(bloc);
    return buildLoadingOverlay(
      child: BlocBuilder<TestBloc, TestState>(
        builder: (context, state) => Text('${state.count}'),
      ),
    );
  }
}

class TestStatelessCubitPage extends BaseCubitPage<TestCubit> {
  const TestStatelessCubitPage({super.key});

  @override
  Widget buildPage(BuildContext context, TestCubit cubit) {
    return buildLoadingOverlay(
      child: BlocBuilder<TestCubit, TestState>(
        builder: (context, state) => Text('${state.count}'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Harness
// ---------------------------------------------------------------------------

/// Wraps [child] in the minimum widget tree a delegate needs to build.
///
/// Uses [Directionality] + [Material] rather than a full [MaterialApp] so the
/// tree under test stays close to the delegate itself.
Widget wrapForTest(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}
