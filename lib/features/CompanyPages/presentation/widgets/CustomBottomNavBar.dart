import 'package:flutter/material.dart';
import 'package:stock_guide/features/Add/presentation/views/AddMainLayout.dart';
import '../../../Injuiry/presentation/viewa/InquiryMainLayout.dart';
import '../../../Renew/presentation/views/RenewMainLayout.dart';
import '../../../Restart/presentation/views/RestartMainLayout.dart';
import '../../../Stop/presentation/views/StopMainLayout.dart';

class CustomBottomNavBar extends StatefulWidget {
  const CustomBottomNavBar({super.key});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    AddMainLayout(),
    StopMainLayout(),
    RestartMainLayout(),
    RenewMainLayout(),
    InquiryMainLayout()
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
                    ? 'assets/icons/add.png'
                    : 'assets/icons/add(disable).png',
                width: 24,
                height: 24,
              ),
              label: 'اضافة',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Image.asset(
                _currentIndex == 1
                    ? 'assets/icons/stop.png'
                    : 'assets/icons/stop(disable).png',
                width: 24,
                height: 24,
              ),
              label: 'ايقاف',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Image.asset(
                _currentIndex == 2
                    ? 'assets/icons/stop.png'
                    : 'assets/icons/stop(disable).png',
                width: 24,
                height: 24,
              ),
              label: 'اعادة تشغيل',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Image.asset(
                _currentIndex == 3
                    ? 'assets/icons/renew.png'
                    : 'assets/icons/renew(disable).png',
                width: 24,
                height: 24,
              ),
              label: 'تجديد',
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.white,
              icon: Image.asset(
                _currentIndex == 4
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
