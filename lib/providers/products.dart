import 'dart:convert';
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/exceptions.dart';

import 'product.dart';

class Products with ChangeNotifier {
  // ignore: prefer_final_fields, unused_field
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  final String? authToken;
  final String? userId;
  Products(this.authToken, this.userId, this._items);
  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavourite == true).toList();
  }

  List<Product> get items => [..._items];

  Product findById(String id) {
    return _items.firstWhere((e) => e.id == id);
  }

  Future<void> fetchAndSetProducts() async {
    try {
      var url = Uri.parse(
          'https://shop-app-931e4-default-rtdb.firebaseio.com/products.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"');

      var response = await http.get(url);

      var extractedData = json.decode(response.body) as Map<String, dynamic>;

      final List<Product> loadedProducts = [];
      url = Uri.parse(
          'https://shop-app-931e4-default-rtdb.firebaseio.com/userFavorite/$userId.json?auth=$authToken');
      var favoriteResponse = await http.get(url);
      var favoriteResponseStatus = json.decode(favoriteResponse.body);

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            title: prodData['title'],
            price: prodData['price'],
            description: prodData['description'],
            isFavourite: favoriteResponseStatus == null
                ? false
                : favoriteResponseStatus[prodId] ?? false,
            imageUrl: prodData['imageUrl'],
            id: prodId));
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) {
    // _items.add(value);
    final url = Uri.parse(
        'https://shop-app-931e4-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    return http
        .post(url,
            body: json.encode({
              'title': product.title,
              'price': product.price,
              'description': product.description,
              'imageUrl': product.imageUrl,
              'isFavorite': product.isFavourite,
              'creatorId': userId
            }))
        .then((value) {
      final newProduct = Product(
          description: product.description,
          imageUrl: product.imageUrl,
          title: product.title,
          price: product.price,
          id: json.decode(value.body)['name']);

      _items.add(newProduct);
      notifyListeners();
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> editProducts(String id, Product newProduct) async {
    final url = Uri.parse(
        'https://shop-app-931e4-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    try {
      await http.patch(
        url,
        body: json.encode(
          {
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl
          },
        ),
      );
      final productIndex = _items.indexWhere(
        (element) => element.id == id,
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void removeProduct(String id) {
    final url = Uri.parse(
        'https://shop-app-931e4-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final prodIndex = _items.indexWhere((element) => element.id == id);
    Product? _existingProduct = _items[prodIndex];
    _items.removeAt(prodIndex);
    notifyListeners();

    http.delete(url).then((response) {
      if (response.statusCode >= 400) {
        throw HttpException('haha error occured');
      }
      _existingProduct = null;
    }).catchError((_) {
      _items.insert(prodIndex, _existingProduct!);
      notifyListeners();
    });
  }
}
