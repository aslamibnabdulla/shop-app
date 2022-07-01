import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/screens/products_details_screen.dart';

import '../providers/cart.dart';
import '../providers/products.dart';

class ProductItem extends StatelessWidget {
  const ProductItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context);
    final authToken = Provider.of<Auth>(context).token;
    final userId = Provider.of<Auth>(context).userId;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ProductsDetailScreen.routeName,
            arguments: product.id);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            leading: Consumer<Product>(
              builder: (ctx, product, child) => IconButton(
                onPressed: () {
                  product.toggleFavoriteStatus(authToken, userId!);
                },
                icon: Icon(
                  product.isFavourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ),
            title: FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                product.title,
                textAlign: TextAlign.center,
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                Provider.of<Cart>(context, listen: false).addItem(
                  product.id!,
                  product.title,
                  product.price,
                );
              },
              icon: const Icon(
                Icons.shopping_cart,
              ),
            ),
          ),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
