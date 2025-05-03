import 'package:flutter/material.dart';
import 'contacts.dart';
import 'products.dart';
import '../database/contact_database.dart';
import '../database/product_database.dart';
import '../database/invoice_database.dart';
import 'new_invoices.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onTabSelected;

  const HomePage({Key? key, required this.onTabSelected}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  int _totalContacts = 0;
  int _totalProducts = 0;
  int _totalInvoices = 0;
  double _totalRevenue = 0.00;

  final ContactDatabase _contactDatabase = ContactDatabase();
  final ProductDatabase _productDatabase = ProductDatabase();
  final InvoiceDatabase _invoiceDatabase = InvoiceDatabase();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    await _loadContactCount();
    await _loadProductCount();
    await _loadInvoiceCount();
    await _loadTotalRevenue();
  }

  Future<void> _loadContactCount() async {
    final contacts = await _contactDatabase.getAllContacts();
    setState(() {
      _totalContacts = contacts.length;
    });
  }

  Future<void> _loadProductCount() async {
    final products = await _productDatabase.getAllProducts();
    setState(() {
      _totalProducts = products.length;
    });
  }

  Future<void> _loadInvoiceCount() async {
    final invoices = await _invoiceDatabase.getAllInvoices();
    setState(() {
      _totalInvoices = invoices.length;
    });
  }

  Future<void> _loadTotalRevenue() async {
    // TODO: Implement logic to calculate total revenue
    setState(() {
      _totalRevenue = 0.00;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice Manager'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manage your invoices, clients, and products all in one place. Create professional invoices in seconds.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildOverviewCard('Total Contacts', '$_totalContacts')),
                SizedBox(width: 10),
                Expanded(child: _buildOverviewCard('Total Products', '$_totalProducts')),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildOverviewCard('Total Invoices', '$_totalInvoices')),
                SizedBox(width: 10),
                Expanded(child: _buildOverviewCard('Last 30 Days', '-')),
              ],
            ),
            SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Revenue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$$_totalRevenue', style: TextStyle(fontSize: 24, color: Colors.green[600], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildQuickActionItem(
              title: 'Create New Invoice',
              icon: Icons.receipt_long_outlined,
              onTap: () {
                _buildQuickActionItem(
                  title: 'Create New Invoice',
                  icon: Icons.receipt_long_outlined,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NewInvoicesPage()),
                    );
                  },
                );
              },
            ),
            _buildQuickActionItem(
              title: 'Add New Contact',
              icon: Icons.person_add_outlined,
              onTap: ()  {
                widget.onTabSelected(1);
              },
            ),
            _buildQuickActionItem(
              title: 'Add New Product',
              icon: Icons.add_box_outlined,
              onTap: ()  {
                widget.onTabSelected(2);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem({required String title, required IconData icon, required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: onTap,
      ),
    );
  }
}

//TODO: Total invoices counter for sell and buy
