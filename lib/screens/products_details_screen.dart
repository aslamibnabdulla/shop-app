import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductsDetailScreen extends StatelessWidget {
  static const routeName = '/haha';
  const ProductsDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final prodct =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          prodct.title,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              height: 300,
              width: double.infinity,
              child: Image.network(
                prodct.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text('\$${prodct.price}'),
            const SizedBox(
              height: 10,
            ),
            Text(prodct.description)
          ],
        ),
      ),
    );
  }
}
