import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products.dart';

class EditScreen extends StatefulWidget {
  const EditScreen({Key? key}) : super(key: key);
  static const String route = 'editscreen';

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _imageUrlController = TextEditingController();
  final _imageFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  bool _isInit = true;
  bool _isLoading = false;

  var _editedProducts = Product(
    id: null,
    imageUrl: '',
    title: '',
    description: '',
    price: 0,
  );
  Map _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': ''
  };

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImageUrl);
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context)?.settings.arguments;
      if (productId != null) {
        _editedProducts = Provider.of<Products>(context, listen: false)
            .findById(productId.toString());

        _initValues = {
          'title': _editedProducts.title,
          'price': _editedProducts.price.toString(),
          'description': _editedProducts.description,
          'imageUrl': _editedProducts.imageUrl
        };

        _imageUrlController.text = _editedProducts.imageUrl;
      }
    } else {}
    _isInit = false;
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus) {
      print('heolll');
      setState(() {});
    }
  }

  void saveForm() {
    final _isValid = _form.currentState!.validate();
    if (!_isValid) {
      return;
    }

    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });

    if (_editedProducts.id != null) {
      Provider.of<Products>(context, listen: false)
          .editProducts(_editedProducts.id.toString(), _editedProducts)
          .then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      });
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(_editedProducts)
          .catchError((error) {
        return showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text(error.toString()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Text('dismiss'))
                ],
              );
            });
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _imageFocusNode.dispose();
    _imageUrlController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveForm,
            icon: const Icon(Icons.save),
          )
        ],
        title: const Text('Edit Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _form,
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Provide a value';
                          }

                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          label: Text('Title'),
                        ),
                        onSaved: (value) {
                          _editedProducts = Product(
                            id: _editedProducts.id,
                            isFavourite: _editedProducts.isFavourite,
                            imageUrl: _editedProducts.imageUrl,
                            title: value!,
                            description: _editedProducts.description,
                            price: _editedProducts.price,
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['price'],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Provide a value';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Provide a valid value';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Provide value greater than zero';
                          }

                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text('Price'),
                        ),
                        onSaved: (value) {
                          _editedProducts = Product(
                            id: _editedProducts.id,
                            isFavourite: _editedProducts.isFavourite,
                            imageUrl: _editedProducts.imageUrl,
                            title: _editedProducts.title,
                            description: _editedProducts.description,
                            price: double.parse(value!),
                          );
                        },
                      ),
                      TextFormField(
                        initialValue: _initValues['description'],
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Provide a value';
                          }
                          if (value.length < 8) {
                            return 'Provide lengthy description';
                          }
                          return null;
                        },
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        // textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          label: Text('Description'),
                        ),
                        onSaved: (value) {
                          _editedProducts = Product(
                            id: _editedProducts.id,
                            isFavourite: _editedProducts.isFavourite,
                            imageUrl: _editedProducts.imageUrl,
                            title: _editedProducts.title,
                            description: value!,
                            price: _editedProducts.price,
                          );
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.red,
                              ),
                            ),
                            height: 100,
                            width: 100,
                            child: _imageUrlController.text.isEmpty
                                ? const Text('No image')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Provide a Url';
                                }
                                if (!value.startsWith('http')) {
                                  return 'Provide a valid Url';
                                }
                                if (!value.endsWith('.jpeg') &&
                                    !value.endsWith('.jpg')) {
                                  return 'Provide a valid Url';
                                }

                                return null;
                              },
                              focusNode: _imageFocusNode,
                              controller: _imageUrlController,
                              onEditingComplete: () {
                                setState(() {});
                              },
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                label: Text('image'),
                              ),
                              onSaved: (value) {
                                _editedProducts = Product(
                                  id: _editedProducts.id,
                                  isFavourite: _editedProducts.isFavourite,
                                  imageUrl: value!,
                                  title: _editedProducts.title,
                                  description: _editedProducts.description,
                                  price: _editedProducts.price,
                                );
                              },
                              onFieldSubmitted: (_) {
                                saveForm();
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
