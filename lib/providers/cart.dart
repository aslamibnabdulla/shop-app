import 'package:flutter/cupertino.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.price,
    required this.quantity,
    required this.title,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, prod) {
      total += prod.quantity * prod.price;
    });
    return total;
  }

  Map<String, CartItem> get items {
    return {..._items};
  }

  void addItem(String prodId, String title, double price) {
    if (_items.containsKey(prodId)) {
      _items.update(
        prodId,
        (existingProduct) => CartItem(
            id: existingProduct.id,
            price: existingProduct.price,
            quantity: existingProduct.quantity + 1,
            title: existingProduct.title),
      );
    } else {
      _items.putIfAbsent(
        prodId,
        () => CartItem(
          id: DateTime.now().toString(),
          price: price,
          quantity: 1,
          title: title,
        ),
      );
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void removeItem(String prodId) {
    _items.remove(prodId);
    notifyListeners();
  }
}
