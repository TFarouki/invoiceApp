import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../database/product_database.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductDatabase _productDatabase = ProductDatabase();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _tvaRateController = TextEditingController();

  List<Product> _products = [];
  String? _imagePath;

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

  Future<void> _addProduct() async {
    if (_formKey.currentState!.validate()) {
      final newProduct = Product(
        name: _nameController.text,
        unitPrice: double.parse(_unitPriceController.text),
        tvaRate: double.parse(_tvaRateController.text),
        imagePath: _imagePath,
      );

      await _productDatabase.insertProduct(newProduct);
      _loadProducts();
      _clearForm();
    }
  }

  Future<void> _deleteProduct(int id) async {
    await _productDatabase.deleteProduct(id);
    _loadProducts();
  }

  void _clearForm() {
    _nameController.clear();
    _unitPriceController.clear();
    _tvaRateController.clear();
    setState(() {
      _imagePath = null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExpansionTile(
                  title: Text('Add New Product'),
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Product Name'),
                      validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
                    ),
                    TextFormField(
                      controller: _unitPriceController,
                      decoration: InputDecoration(labelText: 'Unit Price'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null
                          ? 'Please enter a valid number'
                          : null,
                    ),
                    TextFormField(
                      controller: _tvaRateController,
                      decoration: InputDecoration(labelText: 'TVA Rate (%)'),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) =>
                      value!.isEmpty || double.tryParse(value) == null
                          ? 'Please enter a valid number'
                          : null,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text('Pick Image', style: TextStyle(fontSize: 12)),
                        ),
                        if (_imagePath != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text('Image Selected'),
                          ),
                      ],
                    ),
                    if (_imagePath != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          height: 100,
                          width: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text('Add Product'),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                _products.isEmpty
                    ? Center(child: Text('No products yet.'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Card(
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
                                    Text('Price: \$${product.unitPrice.toStringAsFixed(2)}'),
                                    Text('TVA: ${product.tvaRate.toStringAsFixed(2)}%'),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(product.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
