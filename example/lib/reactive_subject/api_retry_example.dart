import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';
import 'reactive_subject_drawer.dart';

class ApiRetryExample extends StatefulWidget {
  static const String route = '/api_retry_example';

  @override
  _ApiRetryExampleState createState() => _ApiRetryExampleState();
}

class _ApiRetryExampleState extends State<ApiRetryExample> {
  final ReactiveSubject<String> _apiCallSubject = ReactiveSubject<String>();
  late ReactiveSubject<String> _resultSubject;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _resultSubject = ReactiveSubject<String>(
      initialValue: 'Enter text to search...',
    );

    _apiCallSubject
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap((query) => _makeApiCall(query))
        .onErrorResumeNext((error) {
          print('Error occurred: $error');
          return ReactiveSubject<String>(
            initialValue: 'Error: ${error.toString()}',
          );
        })
        .retry(3)
        .debug(tag: 'API_CALL')
        .listen(
          (result) => _resultSubject.add(result),
          onError: (error) => _resultSubject.addError(error),
        );
  }

  ReactiveSubject<String> _makeApiCall(String query) {
    return ReactiveSubject.fromFutureWithError(
      Future.delayed(Duration(seconds: 1)).then((_) {
        if (query.contains('error')) {
          throw Exception('API Error');
        }
        return 'Result for: $query';
      }),
      onError: (error) => print('API call failed: $error'),
      onFinally: () => print('API call completed'),
      timeout: Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _apiCallSubject.dispose();
    _resultSubject.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _apiCallSubject.add(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReactiveSubjectDrawer(ApiRetryExample.route),
      appBar: AppBar(
        title: Text("API Retry Example"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                labelText: 'Search (type "error" to simulate error)',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _resultSubject.add('Enter text to search...');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<String>(
              stream: _resultSubject.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return Center(
                  child: Text(
                    snapshot.data!,
                    style: TextStyle(fontSize: 18),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
