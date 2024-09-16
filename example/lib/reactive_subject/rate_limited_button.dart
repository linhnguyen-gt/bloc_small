import 'package:bloc_small/reactive_subject.dart';
import 'package:flutter/material.dart';

class RateLimitedButton extends StatefulWidget {
  @override
  _RateLimitedButtonState createState() => _RateLimitedButtonState();
}

class _RateLimitedButtonState extends State<RateLimitedButton> {
  final ReactiveSubject<void> _buttonPressSubject = ReactiveSubject<void>();
  late ReactiveSubject<void> _throttledPressSubject;

  @override
  void initState() {
    super.initState();
    // Throttle button presses
    _throttledPressSubject =
        _buttonPressSubject.throttleTime(Duration(seconds: 2));
    _throttledPressSubject.stream.listen((_) {
      // Handle the button press
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Button pressed')),
      );
    });
  }

  @override
  void dispose() {
    _buttonPressSubject.dispose();
    _throttledPressSubject.dispose();
    super.dispose();
  }

  void _onButtonPressed() {
    _buttonPressSubject.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _onButtonPressed,
      child: Text('Press me'),
    );
  }
}
