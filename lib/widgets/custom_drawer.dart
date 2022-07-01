import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/screens/user_products_screen.dart';

import '../screens/orders_screen.dart';

class CustomDrawe extends StatelessWidget {
  const CustomDrawe({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            toolbarHeight: 100,
            title: const Text('Drawer'),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            title: const Text('My Shop'),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, OrderScreen.route);
            },
            title: const Text('Orders'),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              Navigator.pushNamed(context, UserProductScreen.route);
            },
            title: const Text('Manage Products'),
          ),
          const Divider(),
          ListTile(
            onTap: () {
              Navigator.pop(context);
              Provider.of<Auth>(context, listen: false).logOut();
            },
            title: const Text('logOut'),
          ),
          const Divider()
        ],
      ),
    );
  }
}
