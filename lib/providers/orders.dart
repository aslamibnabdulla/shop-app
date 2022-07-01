import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.dateTime,
    required this.products,
  });
}

class Orders with ChangeNotifier {
  Orders(this.authToken, this._items);
  final String authToken;

  List<OrderItem> _items = [];

  List<OrderItem> get items {
    return [..._items];
  }

  Future<void> setAndFetchOrders() async {
    final url = Uri.parse(
        'https://shop-app-931e4-default-rtdb.firebaseio.com/orders.json?auth=$authToken');

    final response = await http.get(url);
    const String? test = null;
    if (test == null) {
      return;
    }

    final decodedData = json.decode(response.body) as Map<String, dynamic>;
    final List<OrderItem> loadedOrders = [];

    decodedData.forEach((key, value) {
      {
        loadedOrders.add(
          OrderItem(
            id: key,
            amount: value['amount'],
            dateTime: DateTime.parse(value['dateTime']),
            products: (value['products'] as List<dynamic>)
                .map(
                  (e) => CartItem(
                      id: e['id'],
                      price: e['price'],
                      quantity: e['quantity'],
                      title: e['title']),
                )
                .toList(),
          ),
        );
      }
    });
    _items = loadedOrders;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cart, double total) async {
    final url = Uri.parse(
        'https://shop-app-931e4-default-rtdb.firebaseio.com/orders.json?auth=$authToken');

    final timeStamp = DateTime.now();

    final response = await http.post(url,
        body: jsonEncode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cart
              .map((e) => {
                    'id': e.id,
                    'price': e.price,
                    'quantity': e.quantity,
                    'title': e.title
                  })
              .toList()
        }));
    _items.insert(
      0,
      OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          dateTime: timeStamp,
          products: cart),
    );

    notifyListeners();
  }
}
