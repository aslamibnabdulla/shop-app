import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';

import '../providers/cart.dart' show Cart;

class CartScreen extends StatelessWidget {
  static const String route = 'cartscreen';
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final item = Provider.of<Cart>(context).items.values.toList();
    final prodId = Provider.of<Cart>(context).items.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          TextButton(
            onPressed: () {
              cart.clearCart();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            color: const Color.fromARGB(255, 219, 231, 221),
            margin: const EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total'),
                  const Spacer(),
                  Chip(
                    label: Text('\$${(cart.totalAmount).toStringAsFixed(2)}'),
                    backgroundColor: Colors.blue,
                  ),
                  OrderButton(item: item, cart: cart)
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cart.itemCount,
              itemBuilder: (context, i) =>
                  CartProduct(prodId: prodId[i], item: item[i]),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.item,
    required this.cart,
  }) : super(key: key);

  final List<CartItem> item;
  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: widget.cart.itemCount <= 0
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false)
                  .addOrder(widget.item, widget.cart.totalAmount);

              _isLoading = false;
              setState(() {});
              widget.cart.clearCart();
            },
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('Order Now'),
    );
  }
}

class CartProduct extends StatelessWidget {
  const CartProduct({
    Key? key,
    required this.prodId,
    required this.item,
  }) : super(key: key);

  final String prodId;
  final CartItem item;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(prodId);
      },
      direction: DismissDirection.endToStart,
      key: UniqueKey(),
      background: Container(
        padding: const EdgeInsets.all(10),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.all(10),
        color: Colors.red,
      ),
      child: Card(
        margin: const EdgeInsets.all(10),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: FittedBox(child: Text('\$${item.price}')),
            ),
          ),
          // ignore: unnecessary_string_interpolations
          title: Text('${item.title}'),
          trailing: Text('${item.quantity}x'),
          subtitle: Text('\$${(item.quantity * item.price)}'),
        ),
      ),
    );
  }
}
