import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';
import 'package:shop_app/screens/products_details_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/splash_screen.dart';
import 'package:shop_app/screens/user_products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (BuildContext context) => Auth()),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (BuildContext context, auth, previousProducts) => Products(
              auth.token ?? '',
              auth.userId ?? '',
              previousProducts?.items ?? []),
          create: (BuildContext context) => Products('', '', []),
        ),
        ChangeNotifierProvider(create: ((BuildContext context) => Cart())),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: ((BuildContext context) => Orders('', [])),
          update: (ctx, auth, previousProducts) =>
              Orders(auth.token!, previousProducts?.items ?? []),
        ),
      ],
      child: Consumer<Auth>(builder: (context, auth, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme(
                brightness: Brightness.dark,
                primary: Colors.black,
                onPrimary: Colors.yellow,
                secondary: Colors.red,
                onSecondary: Colors.yellow,
                error: Colors.red,
                onError: Colors.red,
                background: Colors.blue.shade100,
                onBackground: Colors.yellow,
                surface: Colors.blue,
                onSurface: Colors.black),
            primarySwatch: Colors.purple,
          ),
          home: auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.autoLogin(),
                  builder: ((context, snapshot) =>
                      snapshot.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen())),
          routes: {
            ProductsDetailScreen.routeName: (context) =>
                const ProductsDetailScreen(),
            CartScreen.route: (context) => const CartScreen(),
            OrderScreen.route: (context) => const OrderScreen(),
            UserProductScreen.route: (context) => const UserProductScreen(),
            EditScreen.route: (context) => const EditScreen(),
            AuthScreen.routeName: (context) => const AuthScreen()
          },
        );
      }),
    );
  }
}
