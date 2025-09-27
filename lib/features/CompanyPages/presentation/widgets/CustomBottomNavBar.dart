import 'package:flutter/material.dart';
import 'package:stock_guide/features/Add/presentation/views/AddMainLayout.dart';

import '../../../Injuiry/presentation/viewa/InquiryMainLayout.dart';
import '../../../Renew/presentation/views/RenewMainLayout.dart';
import '../../../Restart/presentation/views/RestartMainLayout.dart';
import '../../../Stop/presentation/views/StopMainLayout.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int companyId;
  final String companyName;
  final String userId;
  final bool isAdmin;
  final int companyStatus;
  final bool hasRightToInsertBranch;
  final bool hasRightToInsertUsers;

  const CustomBottomNavBar({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.userId,
    required this.isAdmin,
    required this.companyStatus,
    required this.hasRightToInsertBranch,
    required this.hasRightToInsertUsers,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  int _currentIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    print(widget.isAdmin);
    print("/*/*/**/");
    print(widget.hasRightToInsertUsers);
    print("/*/*/**/");
    print(widget.hasRightToInsertBranch);

    if (!widget.isAdmin &&
        (!widget.hasRightToInsertBranch || !widget.hasRightToInsertUsers)) {
      _pages = [
        AddMainLayout(
          companyId: widget.companyId,
          companyName: widget.companyName,
          isAdmin: widget.isAdmin,
          hasRightToInsertBranch: widget.hasRightToInsertBranch,
          hasRightToInsertUsers: widget.hasRightToInsertUsers,
        ),
      ];
    } else {
      _pages = [
        AddMainLayout(
          companyId: widget.companyId,
          companyName: widget.companyName,
          isAdmin: widget.isAdmin,
          hasRightToInsertBranch: widget.hasRightToInsertBranch,
          hasRightToInsertUsers: widget.hasRightToInsertUsers,
        ),
        StopMainLayout(
          userId: widget.userId,
          companyId: widget.companyId,
          companyName: widget.companyName,
          companyStatus: widget.companyStatus,
        ),
        RestartMainLayout(
          userId: widget.userId,
          companyId: widget.companyId,
          companyName: widget.companyName,
          companyStatus: widget.companyStatus,
        ),
        RenewMainLayout(companyId: widget.companyId, userId: widget.userId),
        InquiryMainLayout(userId: widget.userId, companyId: widget.companyId),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool singlePage =
        !widget.isAdmin &&
        (!widget.hasRightToInsertBranch || !widget.hasRightToInsertUsers);

    if (singlePage) {
      return Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: AddMainLayout(
            companyId: widget.companyId,
            companyName: widget.companyName,
            isAdmin: widget.isAdmin,
            hasRightToInsertBranch: widget.hasRightToInsertBranch,
            hasRightToInsertUsers: widget.hasRightToInsertUsers,
          ),
        ),
      );
    }
    return Scaffold(
      body: Container(color: Colors.white, child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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
                  ? 'assets/icons/restart.png'
                  : 'assets/icons/restart(disable).png',
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
    );
  }
}
