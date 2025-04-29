import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For File handling
import '../models/company.dart';
import '../database/database_helper.dart';

class CompanysPage extends StatefulWidget {
  const CompanysPage({Key? key}) : super(key: key);

  @override
  State<CompanysPage> createState() => _CompanysPageState();
}

class _CompanysPageState extends State<CompanysPage> {
  final _formKey = GlobalKey<FormState>();
  Company? _company; // Make it nullable to handle both add and update scenarios
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _sirenController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  // Load company if exists
  Future<void> _loadCompany() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db!.query('company');

    if (maps.isNotEmpty) {
      // If a company already exists, load the data
      _company = Company.fromMap(maps.first);
      _nameController.text = _company!.name;
      _addressController.text = _company!.address ?? '';
      _phoneController.text = _company!.phone ?? '';
      _emailController.text = _company!.email ?? '';
      _sirenController.text = _company!.siren ?? '';
      _imagePath = _company!.logoPath; // Load the logo if available
    } else {
      // If no company exists, clear the form for adding a new company
      _company = null;
      _clearForm();
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Save or update company
  Future<void> _saveCompany() async {
    if (_formKey.currentState!.validate()) {
      final newCompany = Company(
        id: _company?.id, // If updating, pass the existing ID
        name: _nameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        siren: _sirenController.text,
        logoPath: _imagePath, // Use selected logo path
      );

      if (_company == null) {
        // Insert new company
        await _insertCompany(newCompany);
      } else {
        // Update existing company
        await _updateCompany(newCompany);
      }

      // Reload the company data to reflect the changes
      _loadCompany();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Company info saved')),
      );
    }
  }

  // Insert new company into the database
  Future<void> _insertCompany(Company company) async {
    final db = await DatabaseHelper.instance.database;
    await db!.insert('company', company.toMap());
  }

  // Update existing company in the database
  Future<void> _updateCompany(Company company) async {
    final db = await DatabaseHelper.instance.database;
    await db!.update(
      'company',
      company.toMap(),
      where: 'id = ?',
      whereArgs: [company.id],
    );
  }

  // Clear the form fields
  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _phoneController.clear();
    _emailController.clear();
    _sirenController.clear();
    setState(() {
      _imagePath = null;
    });
  }

  // Pick an image from the gallery
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('Company')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Image and Pick Button Section
              if (_imagePath != null)
                Image.file(
                  File(_imagePath!),
                  width: screenWidth * 0.5, // 50% of the screen width
                  height: 200, // Set a height for the image
                  fit: BoxFit.cover, // Ensure the image scales well
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Pick Logo'),
              ),
              const SizedBox(height: 20),

              // Form Section
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Company Name'),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextFormField(
                      controller: _sirenController,
                      decoration: const InputDecoration(labelText: 'SIREN'),
                    ),
                    const SizedBox(height: 20),

                    // Row for Save and Delete Buttons in same line
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Save Button as Save Icon
                        IconButton(
                          icon: const Icon(Icons.save),
                          onPressed: _saveCompany,
                          iconSize: 30, // Icon size
                          color: Colors.blue,
                        ),
                        // Delete Button as Trash Icon (only show if a company exists)
                        if (_company != null)
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: _deleteCompany,
                            iconSize: 30, // Icon size
                            color: Colors.red,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Delete company if needed
  Future<void> _deleteCompany() async {
    final db = await DatabaseHelper.instance.database;
    await db!.delete(
      'company',
      where: 'id = ?',
      whereArgs: [_company!.id],
    );

    // Reload the company list after deletion
    _loadCompany();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company deleted')),
    );
  }
}
