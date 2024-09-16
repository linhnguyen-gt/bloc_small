import 'package:bloc_small/reactive_subject.dart';
import 'package:flutter/material.dart';

class EmailFilter extends StatefulWidget {
  @override
  _EmailFilterState createState() => _EmailFilterState();
}

class _EmailFilterState extends State<EmailFilter> {
  final ReactiveSubject<String> _emailSubject = ReactiveSubject<String>();
  late ReactiveSubject<String> _validEmailSubject;

  @override
  void initState() {
    super.initState();
    // Filter valid email addresses
    _validEmailSubject = _emailSubject.where((email) => email.contains('@'));
  }

  @override
  void dispose() {
    _emailSubject.dispose();
    _validEmailSubject.dispose();
    super.dispose();
  }

  void _onEmailChanged(String email) {
    _emailSubject.add(email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _onEmailChanged,
          decoration: InputDecoration(labelText: 'Enter your email'),
        ),
        StreamBuilder<String>(
          stream: _validEmailSubject.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text('Valid email: ${snapshot.data}');
            } else {
              return Text('Please enter a valid email');
            }
          },
        ),
      ],
    );
  }
}
