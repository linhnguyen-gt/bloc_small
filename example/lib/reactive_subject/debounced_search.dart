import 'package:bloc_small/reactive_subject.dart';
import 'package:flutter/material.dart';

class DebouncedSearch extends StatefulWidget {
  @override
  _DebouncedSearchState createState() => _DebouncedSearchState();
}

class _DebouncedSearchState extends State<DebouncedSearch> {
  final ReactiveSubject<String> _searchQuerySubject = ReactiveSubject<String>();
  late ReactiveSubject<List<String>> _searchResultsSubject;

  @override
  void initState() {
    super.initState();
    // Debounce the search input
    _searchResultsSubject = _searchQuerySubject
        .debounceTime(Duration(milliseconds: 500))
        .switchMap((query) => performSearch(query));
  }

  Stream<List<String>> performSearch(String query) async* {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    // Return mock results
    yield ['Result 1 for $query', 'Result 2 for $query'];
  }

  @override
  void dispose() {
    _searchQuerySubject.dispose();
    _searchResultsSubject.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchQuerySubject.add(query);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _onSearchChanged,
          decoration: InputDecoration(labelText: 'Search'),
        ),
        Expanded(
          child: StreamBuilder<List<String>>(
            stream: _searchResultsSubject.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final results = snapshot.data!;
                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(results[index]),
                  ),
                );
              } else {
                return Center(child: Text('No results'));
              }
            },
          ),
        ),
      ],
    );
  }
}
