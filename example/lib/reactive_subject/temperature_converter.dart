import 'package:bloc_small/reactive_subject.dart';
import 'package:flutter/material.dart';

class TemperatureConverter extends StatefulWidget {
  @override
  _TemperatureConverterState createState() => _TemperatureConverterState();
}

class _TemperatureConverterState extends State<TemperatureConverter> {
  final ReactiveSubject<double> _celsiusSubject = ReactiveSubject<double>();
  late ReactiveSubject<double> _fahrenheitSubject;

  @override
  void initState() {
    super.initState();
    // Convert Celsius to Fahrenheit
    _fahrenheitSubject = _celsiusSubject.map((celsius) => celsius * 9 / 5 + 32);
  }

  @override
  void dispose() {
    _celsiusSubject.dispose();
    _fahrenheitSubject.dispose();
    super.dispose();
  }

  void _onCelsiusChanged(String value) {
    final celsius = double.tryParse(value);
    if (celsius != null) {
      _celsiusSubject.add(celsius);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _onCelsiusChanged,
          decoration: InputDecoration(labelText: 'Temperature in Celsius'),
          keyboardType: TextInputType.number,
        ),
        StreamBuilder<double>(
          stream: _fahrenheitSubject.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                  'Temperature in Fahrenheit: ${snapshot.data!.toStringAsFixed(2)}°F');
            } else {
              return Text('Enter a valid temperature');
            }
          },
        ),
      ],
    );
  }
}
