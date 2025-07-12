import 'package:flutter/material.dart';
import '../views/Inquiry/presentation/views/StockInquiryMainLayout.dart';
import '../views/Inventory/presentation/views/InventoryMainLayout.dart';
import '../views/Sales/presentation/views/SalesMainLayout.dart';

class CustomNavBar extends StatefulWidget {
  const CustomNavBar({super.key});

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    SalesMainLayout(),
    InventoryMainLayout(),
    StockInquiryMainLayout()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.black,
          type: BottomNavigationBarType.shifting,
          onTap: (index) => setState(() => _currentIndex = index),
          items: [
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Image.asset(
                _currentIndex == 0
                    ? 'assets/icons/stop.png'
                    : 'assets/icons/stop(disable).png',
                width: 24,
                height: 24,
              ),
              label: 'مبيعات',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Image.asset(
                _currentIndex == 1
                    ? 'assets/icons/renew.png'
                    : 'assets/icons/renew(disable).png',
                width: 24,
                height: 24,
              ),
              label: 'جرد',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Image.asset(
                _currentIndex == 2
                    ? 'assets/icons/inquiry.png'
                    : 'assets/icons/inquiry(disable).png',
                width: 24,
                height: 24,
              ),
              label: 'استعلام',
            ),
          ],
        ),
      ),
    );
  }
}
