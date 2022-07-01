import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart';

class OrderScreen extends StatefulWidget {
  static const String route = 'orderscreen';
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isLoading = false;
  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _isLoading = true;
      });
      await Provider.of<Orders>(context, listen: false).setAndFetchOrders();

      setState(() {
        _isLoading = false;
      });
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context).items;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: orderData.length,
              itemBuilder: ((context, i) => Card(
                    child: ExpansionTile(
                      title: Text('\$${orderData[i].amount}'),
                      subtitle: Text(
                        DateFormat('dd/mm/yyyy hh:mm')
                            .format(orderData[i].dateTime),
                      ),
                      children: orderData[i]
                          .products
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.all(17.0),
                              child: Row(
                                children: [
                                  Text(e.title),
                                  const Spacer(),
                                  Text(e.price.toString())
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  )),
            ),
    );
  }
}
