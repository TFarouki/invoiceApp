import 'package:flutter/material.dart';
import '../database/invoice_database.dart';
import '../database/contact_database.dart';
import '../models/invoice.dart';
import 'new_invoices.dart';
import 'package:intl/intl.dart';



class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});


  @override
  InvoicesPageState createState() => InvoicesPageState();

}

class InvoicesPageState extends State<InvoicesPage> {
  final InvoiceDatabase _invoiceDatabase = InvoiceDatabase.instance;
  late Future<List<Invoice>> _invoices;
  late Future<Map<int, String>> _contactsMap;

  @override
  void initState() {
    super.initState();
    _invoices = _invoiceDatabase.getAllInvoices();
    _contactsMap = _loadContactsMap();
  }

  Future<Map<int, String>> _loadContactsMap() async {
    final contacts = await ContactDatabase().getAllContacts(); // You need to have ContactDatabase
    return { for (var contact in contacts) contact.id!: contact.name };
  }

  String formatInvoiceRef(int refInvoice, bool action) {
    final actionCode = action ? 'V' : 'A';
    final formattedNumber = refInvoice.toString().padLeft(6, '0');
    return 'Fa$actionCode$formattedNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoices'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([_invoices, _contactsMap]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else if (!snapshot.hasData || snapshot.data![0].isEmpty) {
            return Center(child: Text('No invoices found.'));
          } else {
            final invoices = snapshot.data![0] as List<Invoice>;
            final contactsMap = snapshot.data![1] as Map<int, String>;

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                final bool isSell = invoice.action == 'Sell';
                final clientName = contactsMap[invoice.contactId] ?? 'Unknown Client';

                return _buildInvoiceCard(
                  refInvoice: invoice.refInvoice,
                  clientName: clientName,
                  date: invoice.date,
                  paymentMethod: invoice.paymentMethod,
                  totalAmount: invoice.total,
                  isSell: isSell,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewInvoicesPage(
                onInvoiceCreated: () {
                  // Refresh invoices list after new one is added
                  setState(() {
                    _invoices = _invoiceDatabase.getAllInvoices();
                  });
                },
              ),
            ),
          );

          if (result == true) {
            // Optionally reload invoices if the callback isn't enough
            setState(() {
              _invoices = _invoiceDatabase.getAllInvoices();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInvoiceCard({
    required String clientName,
    required int refInvoice,
    required DateTime date,
    required String paymentMethod,
    required double totalAmount,
    required bool isSell,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 100,
            color: isSell ? Colors.green : Colors.red,
          ),
          Expanded(
            child: ListTile(
              title:
              Text(formatInvoiceRef(refInvoice, isSell),style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(clientName, style: TextStyle(color: Colors.grey)),
                  Text(DateFormat('dd-MM-yyyy HH:mm').format(date), style: TextStyle(color: Colors.grey)),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   SizedBox(width: 8),
                   Text(
                         '${totalAmount.toStringAsFixed(2)} €',
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                   ),
                  _buildPaymentIcon(paymentMethod),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String paymentMethod) {
    IconData icon;
    switch (paymentMethod) {
      case 'Cash':
        icon = Icons.money;
        break;
      case 'Cheque':
        icon = Icons.receipt_long;
        break;
      case 'TPE':
        icon = Icons.credit_card;
        break;
      case 'Gift':
        icon = Icons.loyalty;
        break;
      default:
        icon = Icons.attach_money;
    }
    return Icon(icon, color: Colors.blue);
  }
}

//TODO: dismsable invoice
//TODO: tap invoice to open (update or print)
//TODO: tree and filters and search options
