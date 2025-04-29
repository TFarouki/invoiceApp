import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/contacts.dart';
import 'screens/products.dart';
import 'screens/invoices.dart';
import 'screens/companys.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Nav Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> _getPages() {
    return [
      HomePage(onTabSelected: _onTap),
      ContactsPage(),
      ProductsPage(),
      InvoicesPage(),
      CompanysPage(),
    ];
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPages()[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.request_page),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Company',
          ),
        ],
      ),
    );
  }
}
