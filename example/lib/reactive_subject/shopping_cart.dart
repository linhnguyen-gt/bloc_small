import 'package:bloc_small/bloc_small.dart';
import 'package:flutter/material.dart';

import '../drawer/menu_drawer.dart';

class ShoppingCart extends StatefulWidget {
  static const String route = '/shopping_cart';

  @override
  _ShoppingCartState createState() => _ShoppingCartState();
}

class _ShoppingCartState extends State<ShoppingCart> {
  final ReactiveSubject<double> _itemPriceSubject = ReactiveSubject<double>();
  late ReactiveSubject<double> _totalPriceSubject;

  @override
  void initState() {
    super.initState();
    // Calculate running total price
    _totalPriceSubject = _itemPriceSubject.scan<double>(
      0.0,
      (accumulated, current, index) => accumulated + current,
    );
  }

  @override
  void dispose() {
    _itemPriceSubject.dispose();
    _totalPriceSubject.dispose();
    super.dispose();
  }

  void _addItem(double price) {
    _itemPriceSubject.add(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MenuDrawer(ShoppingCart.route),
      appBar: AppBar(
        title: Text("Shopping Cart"),
      ),
      body: Column(
        children: [
          StreamBuilder<double>(
            stream: _totalPriceSubject.stream,
            builder: (context, snapshot) {
              final total = snapshot.data ?? 0.0;
              return Text('Total Price: \$${total.toStringAsFixed(2)}');
            },
          ),
          ElevatedButton(
            onPressed: () => _addItem(29.99),
            child: Text('Add Item (\$29.99)'),
          ),
          ElevatedButton(
            onPressed: () => _addItem(49.99),
            child: Text('Add Item (\$49.99)'),
          ),
        ],
      ),
    );
  }
}
