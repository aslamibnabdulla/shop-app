import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/widgets/badge.dart';

import '../providers/products.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/products_grid.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavorites = false;
  bool _isInit = true;

  bool _isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // Future<void> fechData() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   await Provider.of<Products>(context, listen: false).fetchAndSetProducts();

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: CustomDrawe(),
        appBar: AppBar(
          toolbarHeight: 100,
          actions: [
            PopupMenuButton(
                onSelected: (FilterOptions selectedValue) {
                  setState(() {
                    if (selectedValue == FilterOptions.Favorites) {
                      _showFavorites = true;
                    } else {
                      _showFavorites = false;
                    }
                  });
                },
                icon: const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: FilterOptions.Favorites,
                        child: Text('Facorites only'),
                      ),
                      const PopupMenuItem(
                        value: FilterOptions.All,
                        child: Text('All'),
                      )
                    ]),
            Consumer<Cart>(
              builder: (context, cart, child) {
                return Badge(child: child!, value: cart.itemCount.toString());
              },
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, CartScreen.route);
                },
              ),
            ),
            IconButton(
              onPressed: () {
                // Navigator.pushNamed(context, OrderScreen.route);
                Provider.of<Auth>(context, listen: false).autoLogin();
              },
              icon: const Icon(Icons.shopping_bag),
            )
          ],
          title: const Text(
            'My Shop',
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : ProductsGrid(
                showFavs: _showFavorites,
              ),
      ),
    );
  }
}
