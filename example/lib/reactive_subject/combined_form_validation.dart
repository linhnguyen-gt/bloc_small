import 'package:bloc_small/reactive_subject.dart';
import 'package:flutter/material.dart';

class CombinedFormValidation extends StatefulWidget {
  @override
  _CombinedFormValidationState createState() => _CombinedFormValidationState();
}

class _CombinedFormValidationState extends State<CombinedFormValidation> {
  final ReactiveSubject<String> _nameSubject = ReactiveSubject<String>();
  final ReactiveSubject<String> _emailSubject = ReactiveSubject<String>();
  late ReactiveSubject<bool> _isFormValidSubject;

  @override
  void initState() {
    super.initState();
    // Combine latest values and validate
    _isFormValidSubject = ReactiveSubject.combineLatest<String>(
      [_nameSubject, _emailSubject],
    ).map((values) {
      final nameValid = values[0].isNotEmpty;
      final emailValid = values[1].contains('@');
      return nameValid && emailValid;
    });
  }

  @override
  void dispose() {
    _nameSubject.dispose();
    _emailSubject.dispose();
    _isFormValidSubject.dispose();
    super.dispose();
  }

  void _onSubmit() {
    // Submit the form
    print('Form submitted');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _nameSubject.add,
          decoration: InputDecoration(labelText: 'Name'),
        ),
        TextField(
          onChanged: _emailSubject.add,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        StreamBuilder<bool>(
          stream: _isFormValidSubject.stream,
          builder: (context, snapshot) {
            final isValid = snapshot.data ?? false;
            return ElevatedButton(
              onPressed: isValid ? _onSubmit : null,
              child: Text('Submit'),
            );
          },
        ),
      ],
    );
  }
}