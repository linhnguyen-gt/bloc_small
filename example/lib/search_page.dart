import 'package:bloc_small/bloc.dart';
import 'package:flutter/material.dart';

import 'bloc/search/search_bloc.dart';
import 'drawer/menu_drawer.dart';

class SearchPage extends StatefulWidget {
  static const String route = '/search_page';

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends BasePageState<SearchPage, SearchBloc> {
  _SearchPageState() : super();

  @override
  SearchBloc createBloc() => SearchBloc();

  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(SearchPage.route),
      appBar: AppBar(
        title: Text('Reactive + Bloc Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: _SearchInput(bloc: bloc),
          ),
          Expanded(
            child: buildLoadingOverlay(
                loadingKey: 'search', child: _SearchResults()),
          ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final SearchBloc bloc;

  _SearchInput({required this.bloc});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (query) {
        bloc.add(UpdateQuery(query));
      },
      decoration: InputDecoration(
        labelText: 'Search',
        hintText: 'Type to search...',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is Initial) {
          return Center(child: Text('Please enter a search term'));
        } else if (state is Loaded) {
          if (state.results.isEmpty) {
            return Center(child: Text('No results found'));
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(state.results[index]),
              );
            },
          );
        } else if (state is Error) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return Container();
        }
      },
    );
  }
}
