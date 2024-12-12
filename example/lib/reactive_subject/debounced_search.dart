import 'package:bloc_small/bloc.dart';
import 'package:flutter/material.dart';

import '../drawer/menu_drawer.dart';

class DebouncedSearch extends StatefulWidget {
  static const String route = '/debounced_search';

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

  ReactiveSubject<List<String>> performSearch(String query) {
    return ReactiveSubject.fromFutureWithError(
      Future.delayed(Duration(seconds: 1)).then((_) {
        return ['Result 1 for $query', 'Result 2 for $query'];
      }),
      onError: (error) {
        print('Error occurred during search: $error');
      },
    );
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
    return Scaffold(
      drawer: const MenuDrawer(DebouncedSearch.route),
      appBar: AppBar(
        title: Text("Debounced Search"),
      ),
      body: Column(
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
      ),
    );
  }
}
