import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../database/contact_database.dart'; // Assuming you have a ContactDatabase for CRUD operations

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final ContactDatabase _contactDatabase = ContactDatabase(); // You should have this class for DB operations
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _sirenController = TextEditingController();

  List<Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _contactDatabase.getAllContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  Future<void> _addContact() async {
    if (_formKey.currentState!.validate()) {
      final newContact = Contact(
        name: _nameController.text,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        phoneNumber: _phoneNumberController.text.isNotEmpty ? _phoneNumberController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        siren: _sirenController.text.isNotEmpty ? _sirenController.text : null,
      );

      await _contactDatabase.insertContact(newContact);
      _loadContacts();
      _clearForm();
    }
  }

  Future<void> _deleteContact(int id) async {
    await _contactDatabase.deleteContact(id);
    _loadContacts();
  }

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _phoneNumberController.clear();
    _emailController.clear();
    _sirenController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ExpansionTile(
                  title: Text('Add New Contact'),
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
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text('Add Contact'),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 16),
                _contacts.isEmpty
                    ? Center(child: Text('No contacts yet.'))
                    : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            Icon(Icons.person, size: 60.0, color: Colors.blue),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact.name,
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                    ),
                                    Text(
                                      'SIREN: ${contact.siren ?? 'Not Available'}',
                                      style: TextStyle(fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteContact(contact.id!), // Adjust this to your delete method
                            ),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (contact.address != null) Text('Address: ${contact.address!}'),
                                if (contact.phoneNumber != null) Text('Phone: ${contact.phoneNumber!}'),
                                if (contact.email != null) Text('Email: ${contact.email!}'),
                                // Add more fields here if needed
                              ],
                            ),
                          ),
                        ],
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
