import 'dart:async';

import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

import 'reactive_subject_drawer.dart';

class StockPrice extends StatefulWidget {
  static const String route = '/stock_price';

  const StockPrice({super.key});

  @override
  StockPriceState createState() => StockPriceState();
}

class StockPriceState extends State<StockPrice> {
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

  ReactiveSubject<double> getStockPriceStream(String symbol) {
    final resultSubject = ReactiveSubject<double>();

    Future.delayed(Duration(seconds: 1))
        .then((_) {
          final price =
              100 +
              (symbol.codeUnitAt(0) * 0.1) +
              (DateTime.now().second * 0.01);
          resultSubject.add(price);
        })
        .catchError((error) {
          resultSubject.addError(error);
        });

    return resultSubject;
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
    return Scaffold(
      drawer: const ReactiveSubjectDrawer(StockPrice.route),
      appBar: AppBar(title: Text("Stock Price")),
      body: Column(
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
                  'Current Price: \$${snapshot.data!.toStringAsFixed(2)}',
                );
              } else {
                return Text('Enter a stock symbol to see the price');
              }
            },
          ),
        ],
      ),
    );
  }
}
