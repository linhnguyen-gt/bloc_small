import 'package:bloc_small/reactive_subject.dart';
import 'package:flutter/material.dart';

class StockPrice extends StatefulWidget {
  @override
  _StockPriceState createState() => _StockPriceState();
}

class _StockPriceState extends State<StockPrice> {
  final ReactiveSubject<String> _stockSymbolSubject = ReactiveSubject<String>();
  late ReactiveSubject<double> _stockPriceSubject;

  @override
  void initState() {
    super.initState();
    // Switch to new stock price stream when symbol changes
    _stockPriceSubject = _stockSymbolSubject.switchMap((symbol) {
      return getStockPriceStream(symbol);
    });
  }

  Stream<double> getStockPriceStream(String symbol) async* {
    // Mock real-time stock prices
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield (100 +
          (symbol.codeUnitAt(0) * 0.1) +
          (DateTime.now().second * 0.01));
    }
  }

  @override
  void dispose() {
    _stockSymbolSubject.dispose();
    _stockPriceSubject.dispose();
    super.dispose();
  }

  void _onSymbolChanged(String symbol) {
    _stockSymbolSubject.add(symbol);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: _onSymbolChanged,
          decoration: InputDecoration(labelText: 'Enter Stock Symbol'),
        ),
        StreamBuilder<double>(
          stream: _stockPriceSubject.stream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                  'Current Price: \$${snapshot.data!.toStringAsFixed(2)}');
            } else {
              return Text('Enter a stock symbol to see the price');
            }
          },
        ),
      ],
    );
  }
}
