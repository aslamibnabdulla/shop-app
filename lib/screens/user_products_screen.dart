import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/edit_screen.dart';
import 'package:shop_app/widgets/custom_drawer.dart';

import '../providers/products.dart';

class UserProductScreen extends StatelessWidget {
  static const String route = 'userproductscreen';
  const UserProductScreen({Key? key}) : super(key: key);

  Future<void> _pullRefresh(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Products>(context).items;
    return Scaffold(
      drawer: const CustomDrawe(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                EditScreen.route,
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _pullRefresh(context),
        child: ListView.builder(
          itemCount: product.length,
          itemBuilder: ((context, i) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    product[i].imageUrl,
                  ),
                ),
                title: Text(
                  product[i].title,
                ),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.pink,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, EditScreen.route,
                              arguments: product[i].id);
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          Provider.of<Products>(context, listen: false)
                              .removeProduct(product[i].id.toString());
                        },
                      )
                    ],
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
