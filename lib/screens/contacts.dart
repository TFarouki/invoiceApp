import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/contact.dart';
import '../database/contact_database.dart';
import 'new_contact.dart';

class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final ContactDatabase _contactDatabase = ContactDatabase();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _sirenController = TextEditingController();

  List<Contact> _contacts = [];
  Set<int> _expandedIds = {};

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
        child: _contacts.isEmpty
            ? Center(child: Text('No contacts yet.'))
            : ListView.builder(
          itemCount: _contacts.length,
          itemBuilder: (context, index) {
            final contact = _contacts[index];
            final isExpanded = _expandedIds.contains(contact.id);

            return Dismissible(
              key: ValueKey(contact.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                final removed = contact;
                await _deleteContact(contact.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${removed.name} deleted'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () async {
                        await _contactDatabase.insertContact(removed);
                        _loadContacts();
                      },
                    ),
                  ),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person, size: 40, color: Colors.blue),
                      title: Text(contact.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('SIREN: ${contact.siren ?? 'Not Available'}'),
                      trailing: IconButton(
                        icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                        onPressed: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedIds.remove(contact.id);
                            } else {
                              _expandedIds.add(contact.id!);
                            }
                          });
                        },
                      ),
                    ),
                    if (isExpanded)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (contact.address != null)
                              Text('Address: ${contact.address!}'),
                            if (contact.phoneNumber != null)
                              Text('Phone: ${contact.phoneNumber!}'),
                            if (contact.email != null)
                              Text('Email: ${contact.email!}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NewContactPage(onContactAdded: _loadContacts)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

//TODO: search bar
//TODO: display as grid or table
