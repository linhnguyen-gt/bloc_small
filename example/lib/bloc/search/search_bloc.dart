import 'package:bloc_small/bloc_small.dart';

part 'search_bloc.freezed.dart';
part 'search_event.dart';
part 'search_state.dart';

@injectable
class SearchBloc extends MainBloc<SearchEvent, SearchState>
    with BlocErrorHandlerMixin {
  final ReactiveSubject<String> _searchQuery = ReactiveSubject<String>();
  late final ReactiveSubject<List<String>> _searchResults;

  SearchBloc() : super(const SearchState.initial()) {
    // Initialize _searchResults with debounced search queries
    _searchResults = _searchQuery
        .debounceTime(Duration(milliseconds: 100))
        .doOnData((query) {
          showLoading(key: 'search');
        })
        .switchMap((query) => _performSearch(query));

    // Listen to search results and update the state
    _searchResults.stream.listen((results) {
      add(UpdateResults(results));
    });

    on<UpdateQuery>(_onUpdateQuery);
    on<UpdateResults>(_onUpdateResults);
    on<SearchError>(_onSearchError);
  }

  Future<void> _onUpdateQuery(
    UpdateQuery event,
    Emitter<SearchState> emit,
  ) async {
    await blocCatch(
      keyLoading: 'search',
      actions: () async {
        await Future.delayed(Duration(seconds: 2));
        // Check if bloc is closed before adding to ReactiveSubject
        if (!isClosed && !_searchQuery.isDisposed) {
          _searchQuery.add(event.query);
        }
      },
      onError: handleError,
    );
  }

  void _onUpdateResults(UpdateResults event, Emitter<SearchState> emit) {
    emit(SearchState.loaded(event.results));
  }

  void _onSearchError(SearchError event, Emitter<SearchState> emit) {
    emit(SearchState.error(event.message));
  }

  ReactiveSubject<List<String>> _performSearch(String query) {
    return ReactiveSubject.fromFutureWithError(
      Future.delayed(Duration(seconds: 1)).then((_) {
        if (query.isEmpty) {
          return <String>[];
        } else {
          return ['Result 1 for "$query"', 'Result 2 for "$query"'];
        }
      }),
      onError: (error) {
        add(SearchError(error.toString()));
        hideLoading(key: 'search');
      },
      onFinally: () {
        hideLoading(key: 'search');
      },
    );
  }

  @override
  Future<void> close() {
    _searchQuery.dispose();
    _searchResults.dispose();
    return super.close();
  }
}
