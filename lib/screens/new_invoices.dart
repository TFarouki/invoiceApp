import 'package:flutter/material.dart';
import 'dart:io';
import '../database/contact_database.dart';
import '../database/invoice_database.dart';
import '../database/invoice_detail_database.dart';
import '../database/product_database.dart';
import '../models/contact.dart';
import '../models/invoice.dart';
import '../models/invoice_detail.dart';
import '../models/product.dart';

class NewInvoicesPage extends StatefulWidget {
  final VoidCallback? onInvoiceCreated;

  const NewInvoicesPage({Key? key, this.onInvoiceCreated}) : super(key: key);

  @override
  State<NewInvoicesPage> createState() => _NewInvoicesPageState();
}

class _NewInvoicesPageState extends State<NewInvoicesPage> {
  final _formKey = GlobalKey<FormState>();
  List<Contact> _contacts = [];
  Contact? _selectedContact;
  List<InvoiceDetail> _invoiceDetails = [];
  String _paymentMethod = 'TPE';
  String _action = 'Sell';
  final _totalController = TextEditingController(text: '0.00');

  // Database instances
  final ContactDatabase _contactDatabase = ContactDatabase();
  final InvoiceDetailDatabase _invoiceDetailDatabase = InvoiceDetailDatabase();
  final ProductDatabase _productDatabase = ProductDatabase();
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadProducts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _contactDatabase.getAllContacts();
    setState(() {
      _contacts = contacts;
      if (_contacts.isNotEmpty) {
        _selectedContact = _contacts.first;
      }
    });
  }

  Future<void> _loadProducts() async {
    final products = await _productDatabase.getAllProducts();
    setState(() {
      _products = products;
    });
  }

  void _showProductSelectionModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final imageFile = product.imagePath != null &&
                        product.imagePath!.isNotEmpty
                        ? File(product.imagePath!)
                        : null;
                    return Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _invoiceDetails.add(
                                  InvoiceDetail(
                                    description: product.name,
                                    quantity: 1,
                                    price: product.unitPrice,
                                    invoiceId: 0,
                                  ),
                                );
                                _updateTotal();
                              });
                              if (mounted) Navigator.pop(context, true);
                            },
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  imageFile != null
                                      ? Image.file(
                                    imageFile,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return const Center(
                                          child: Icon(Icons.error));
                                    },
                                  )
                                      : const Center(child: Icon(Icons.image)),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      color: Colors.black54,
                                      child: Text(
                                        '${product.unitPrice} €',
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            product.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _invoiceRef(invoiceCount,invoiceDate){
    int currentYear = invoiceDate.year;
    return 'FaV$currentYear${(invoiceCount + 1).toString().padLeft(6, '0')}';
  }

  void _updateTotal() {
    double total = 0.0;
    for (var detail in _invoiceDetails) {
      total += detail.quantity * detail.price;
    }
    _totalController.text = total.toStringAsFixed(2);
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate() && _selectedContact != null) {
      try {
        final ref = _action == 'Sell'
            ? await InvoiceDatabase.instance.getNextSellRefInvoice()
            : await InvoiceDatabase.instance.getNextBuyRefInvoice();

        final invoice = Invoice(
          refInvoice: ref,
          date: DateTime.now(),
          total: double.tryParse(_totalController.text) ?? 0.0,
          action: _action,
          paymentMethod: _paymentMethod,
          contactId: _selectedContact!.id!,
        );

        final invoiceId = await InvoiceDatabase.instance.createInvoice(invoice);

        if (invoiceId != 0) {
          for (var detail in _invoiceDetails) {
            detail.invoiceId = invoiceId;
            await _invoiceDetailDatabase.insertInvoiceDetail(detail);
          }

          // Trigger the callback before popping
          if (widget.onInvoiceCreated != null) {
            widget.onInvoiceCreated!();
          }

          Navigator.pop(context, true); // ✅ Notify previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error saving invoice')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildActionToggle() {
    return Container(
      width: 140,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            alignment: _action == 'Sell' ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 70,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blue,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _action = 'Sell'),
                  child: Center(
                    child: Text(
                      'Sell',
                      style: TextStyle(
                        color: _action == 'Sell' ? Colors.white : Colors.grey[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _action = 'Buy'),
                  child: Center(
                    child: Text(
                      'Buy',
                      style: TextStyle(
                        color: _action == 'Buy' ? Colors.white : Colors.grey[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Section
              Column(
                children: [
                  // Row 1: Action toggle + Payment type
                  Row(
                    children: [
                      _buildActionToggle(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _paymentMethod,
                          onChanged: (value) =>
                              setState(() => _paymentMethod = value!),
                          items: ['Cash', 'Cheque', 'TPE', 'Espece'].map((e) {
                            return DropdownMenuItem(
                                value: e, child: Text(e));
                          }).toList(),
                          decoration:
                          const InputDecoration(labelText: 'Payment'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Row 2: Select client
                  DropdownButtonFormField<Contact>(
                    hint: const Text('Select Client'),
                    value: _selectedContact,
                    onChanged: (Contact? contact) {
                      setState(() => _selectedContact = contact);
                    },
                    items: _contacts.map((contact) {
                      return DropdownMenuItem(
                        value: contact,
                        child: Text(contact.name),
                      );
                    }).toList(),
                    validator: (value) =>
                    value == null ? 'Client required' : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showProductSelectionModal,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
              const SizedBox(height: 16),
              // Invoice Items Section
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _invoiceDetails.length,
                  itemBuilder: (context, index) {
                    final detail = _invoiceDetails[index];
                    final item = _invoiceDetails[index];
                    return Dismissible(
                      key: Key(item.hashCode.toString()),
                      direction: DismissDirection.endToStart,

                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          final dragDistance = details.primaryVelocity;
                          if (dragDistance != null && dragDistance > 0) {
                            setState(() {
                              detail.quantity += 5;
                              _updateTotal();
                            });
                          }else{
                            setState(() {
                              _invoiceDetails.removeAt(index);
                              _updateTotal();
                            });
                          }
                        },
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              detail.quantity += 1;
                              _updateTotal();
                            });
                          },
                          onLongPress: () {
                            setState(() {
                              detail.quantity = 0;
                              _updateTotal();
                            });
                          },
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                          title: Text(detail.description),
                          subtitle: Text('Qty: ${detail.quantity}'),
                          trailing: Text(
                            '${(detail.quantity * detail.price)
                                .toStringAsFixed(2)} €',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Section (Total and Create button)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_totalController.text} €',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _saveInvoice,
                    icon: const Icon(Icons.save),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//TODO: insted of create button change to save and add print button and share(pdf) button