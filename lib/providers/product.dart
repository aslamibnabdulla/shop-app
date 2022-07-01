import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product(
      {required this.id,
      required this.imageUrl,
      required this.title,
      required this.description,
      required this.price,
      this.isFavourite = false});

  void toggleFavoriteStatus(String? authToken, String userId) async {
    final url = Uri.parse(
        'https://shop-app-931e4-default-rtdb.firebaseio.com/userFavorite/$userId/$id.json?auth=$authToken');

    final oldStatus = isFavourite;

    isFavourite = !isFavourite;
    notifyListeners();
    try {
      final response = await http.put(url, body: json.encode(isFavourite));
      if (response.statusCode >= 400) {
        isFavourite = oldStatus;
        notifyListeners();
      } else {}
    } catch (e) {
      isFavourite = oldStatus;
      notifyListeners();
    }
  }
}
