import 'package:bloc_small/bloc.dart';
import 'package:flutter/material.dart';

import '../drawer/menu_drawer.dart';

class ActionWithLatestContext extends StatefulWidget {
  static const String route = '/action_with_latest_context';

  @override
  _ActionWithLatestContextState createState() =>
      _ActionWithLatestContextState();
}

class _ActionWithLatestContextState extends State<ActionWithLatestContext> {
  final ReactiveSubject<void> _actionSubject = ReactiveSubject<void>();
  final ReactiveSubject<String> _selectedItemSubject =
      ReactiveSubject<String>(initialValue: 'Item 1');
  late ReactiveSubject<String> _actionWithItemSubject;

  @override
  void initState() {
    super.initState();
    // Combine action with the latest selected item
    _actionWithItemSubject = _actionSubject.withLatestFrom(
      _selectedItemSubject,
      (_, String selectedItem) => selectedItem,
    );
    _actionWithItemSubject.stream.listen((item) {
      // Perform action with the selected item
      print('Action performed on $item');
    });
  }

  @override
  void dispose() {
    _actionSubject.dispose();
    _selectedItemSubject.dispose();
    _actionWithItemSubject.dispose();
    super.dispose();
  }

  void _onActionPressed() {
    _actionSubject.add(null);
  }

  void _onItemSelected(String? item) {
    if (item != null) {
      _selectedItemSubject.add(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(ActionWithLatestContext.route),
      appBar: AppBar(
        title: Text("Action With Latest"),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedItemSubject.value,
            onChanged: _onItemSelected,
            items: [
              DropdownMenuItem(value: 'Item 1', child: Text('Item 1')),
              DropdownMenuItem(value: 'Item 2', child: Text('Item 2')),
            ],
          ),
          ElevatedButton(
            onPressed: _onActionPressed,
            child: Text('Perform Action'),
          ),
        ],
      ),
    );
  }
}
