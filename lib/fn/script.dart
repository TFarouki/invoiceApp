import 'dart:io';
import 'package:flutter/material.dart';
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
  final _totalController = TextEditingController(text: '0.00');

  List<Contact> _contacts = [];
  List<Product> _products = [];
  List<InvoiceDetail> _invoiceDetails = [];
  Contact? _selectedContact;

  String _paymentMethod = 'TPE';
  String _action = 'Sell';

  final _contactDatabase = ContactDatabase();
  final _productDatabase = ProductDatabase();
  final _invoiceDetailDatabase = InvoiceDetailDatabase();

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
      if (_contacts.isNotEmpty) _selectedContact = _contacts.first;
    });
  }

  Future<void> _loadProducts() async {
    final products = await _productDatabase.getAllProducts();
    setState(() => _products = products);
  }

  void _updateTotal() {
    final total = _invoiceDetails.fold<double>(
      0.0,
          (sum, item) => sum + item.price * item.quantity,
    );
    _totalController.text = total.toStringAsFixed(2);
  }

  void _showProductSelectionModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
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
            final imageFile = product.imagePath?.isNotEmpty == true ? File(product.imagePath!) : null;
            return Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _invoiceDetails.add(InvoiceDetail(
                          description: product.name,
                          quantity: 1,
                          price: product.unitPrice,
                          invoiceId: 0,
                        ));
                        _updateTotal();
                      });
                      Navigator.pop(context);
                    },
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          imageFile != null
                              ? Image.file(imageFile, fit: BoxFit.cover)
                              : const Center(child: Icon(Icons.image)),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black54,
                              padding: const EdgeInsets.all(8),
                              child: Text('${product.unitPrice} €', style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(product.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate() && _selectedContact != null) {
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
        if (widget.onInvoiceCreated != null) {
          widget.onInvoiceCreated!();
        }
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving invoice')),
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
            children: ['Sell', 'Buy'].map((label) {
              final isSelected = _action == label;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _action = label),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _buildActionToggle(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      onChanged: (value) => setState(() => _paymentMethod = value!),
                      items: ['Cash', 'Cheque', 'TPE', 'Espece'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      decoration: const InputDecoration(labelText: 'Payment'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Contact>(
                value: _selectedContact,
                hint: const Text('Select Client'),
                onChanged: (value) => setState(() => _selectedContact = value),
                items: _contacts.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                validator: (value) => value == null ? 'Client required' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _showProductSelectionModal,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _invoiceDetails.length,
                  itemBuilder: (context, index) {
                    final detail = _invoiceDetails[index];
                    return Dismissible(
                      key: Key(detail.hashCode.toString()),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          _invoiceDetails.removeAt(index);
                          _updateTotal();
                        });
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        onTap: () => setState(() {
                          detail.quantity += 1;
                          _updateTotal();
                        }),
                        onLongPress: () => setState(() {
                          detail.quantity = 0;
                          _updateTotal();
                        }),
                        title: Text(detail.description),
                        subtitle: Text('Qty: ${detail.quantity}'),
                        trailing: Text('${(detail.price * detail.quantity).toStringAsFixed(2)} €'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${_totalController.text} €',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _saveInvoice,
                    icon: const Icon(Icons.save),
                    label: const Text('Create'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
