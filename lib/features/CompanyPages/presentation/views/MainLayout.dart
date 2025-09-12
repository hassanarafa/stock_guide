import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/CustomBottomNavBar.dart';

class MainLayout extends StatefulWidget {
  final int companyId;
  final String companyName;
  final String userId;
  final bool isAdmin;
  final int companyStatus;

  const MainLayout({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.userId,
    required this.isAdmin,
    required this.companyStatus,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int _companyStatus; // 👈 متغير داخلي بيتغير

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _companyStatus = widget.companyStatus; // البداية
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void updateCompanyStatus(int newStatus) {
    setState(() {
      _companyStatus = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: CustomBottomNavBar(
          userId: widget.userId,
          companyId: widget.companyId,
          companyName: widget.companyName,
          isAdmin: widget.isAdmin,
          companyStatus: _companyStatus, // 👈 استخدم النسخة اللي بتتغير
        ),
      ),
    );
  }
}
