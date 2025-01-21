import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

import 'reactive_subject_drawer.dart';

class DistinctApiCalls extends StatefulWidget {
  static const String route = '/distinct_api_calls';

  @override
  _DistinctApiCallsState createState() => _DistinctApiCallsState();
}

class _DistinctApiCallsState extends State<DistinctApiCalls> {
  final ReactiveSubject<String> _apiParamSubject = ReactiveSubject<String>();
  late ReactiveSubject<String> _distinctParamSubject;

  @override
  void initState() {
    super.initState();
    // Emit only distinct parameters
    _distinctParamSubject = _apiParamSubject.distinct();
    _distinctParamSubject.stream.listen((param) {
      // Make API call with param
      print('Making API call with parameter: $param');
    });
  }

  @override
  void dispose() {
    _apiParamSubject.dispose();
    _distinctParamSubject.dispose();
    super.dispose();
  }

  void _onParamChanged(String param) {
    _apiParamSubject.add(param);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReactiveSubjectDrawer(DistinctApiCalls.route),
      appBar: AppBar(
        title: Text("Distinct Api Calls"),
      ),
      body: TextField(
        onChanged: _onParamChanged,
        decoration: InputDecoration(labelText: 'API Parameter'),
      ),
    );
  }
}
