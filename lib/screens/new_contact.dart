import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../database/contact_database.dart';
import 'contacts.dart';

class NewContactPage extends StatefulWidget {
  final VoidCallback onContactAdded;

  NewContactPage({required this.onContactAdded});

  @override
  _NewContactPageState createState() => _NewContactPageState();
}

class _NewContactPageState extends State<NewContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _sirenController = TextEditingController();

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final contact = Contact(
        name: _nameController.text,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        phoneNumber: _phoneNumberController.text.isNotEmpty ? _phoneNumberController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        siren: _sirenController.text.isNotEmpty ? _sirenController.text : null,
      );

      await ContactDatabase().insertContact(contact);
      widget.onContactAdded();
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Contact')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Contact Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _sirenController,
                decoration: InputDecoration(labelText: 'SIREN'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
