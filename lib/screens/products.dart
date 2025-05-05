import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../database/product_database.dart';
import 'new_product.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductDatabase _productDatabase = ProductDatabase();


  List<Product> _products = [];


  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _productDatabase.getAllProducts();
    setState(() {
      _products = products;
    });
  }

  Future<void> _deleteProduct(int id) async {
    await _productDatabase.deleteProduct(id);
    _loadProducts();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16),
                _products.isEmpty
                    ? Center(child: Text('No products yet.'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Dismissible(
                      key: Key(product.id.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) async {
                        final deletedProduct = product;
                        final deletedIndex = index;

                        // Temporarily remove from UI
                        setState(() {
                          _products.removeAt(index);
                        });

                        // Show SnackBar with Undo
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${deletedProduct.name} deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Restore item in UI
                                setState(() {
                                  _products.insert(deletedIndex, deletedProduct);
                                });
                              },
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        ).closed.then((reason) async {
                          // If not undone, delete from database
                          final stillDeleted = !_products.contains(deletedProduct);
                          if (stillDeleted) {
                            await _deleteProduct(deletedProduct.id!);
                          }
                        });
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 100.0,
                          child: Row(
                            children: [
                              Container(
                                width: 80.0,
                                height: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                  ),
                                  child: product.imagePath != null &&
                                      File(product.imagePath!).existsSync()
                                      ? Image.file(
                                    File(product.imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        Center(child: Icon(Icons.image_not_supported)),
                                  )
                                      : Center(child: Icon(Icons.image_outlined)),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 16.0)),
                                      Text('TVA: ${product.tvaRate.toStringAsFixed(2)}%'),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Text(
                                  '${product.unitPrice.toStringAsFixed(2)} €',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );

                  },
                ),
              ],
            ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewProductPage(onProductAdded: _loadProducts)),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Product',
      ),
    );
  }
}

//TODO: add Category of product
//TODO: add search bar
//TODO: display as table or grid
