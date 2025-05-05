import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/product.dart';
import '../database/product_database.dart';

class NewProductPage extends StatefulWidget {
  final VoidCallback onProductAdded;

  NewProductPage({required this.onProductAdded});

  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _tvaController = TextEditingController();
  String? _imagePath;

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _nameController.text,
        unitPrice: double.tryParse(_priceController.text) ?? 0.0,
        tvaRate: double.tryParse(_tvaController.text) ?? 0.0,
        imagePath: _imagePath,
      );

      await ProductDatabase().insertProduct(product);
      widget.onProductAdded();
      Navigator.pop(context, true);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
                ),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(labelText: 'Unit Price'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                  value!.isEmpty || double.tryParse(value) == null
                      ? 'Please enter a valid number'
                      : null,
                ),
                TextFormField(
                  controller: _tvaController,
                  decoration: InputDecoration(labelText: 'TVA Rate (%)'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) =>
                  value!.isEmpty || double.tryParse(value) == null
                      ? 'Please enter a valid number'
                      : null,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Pick Image', style: TextStyle(fontSize: 14)),
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
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveProduct,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
