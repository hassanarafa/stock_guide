import 'package:flutter/material.dart';

import '../widgets/CustomBottomNavBar.dart';

class MainLayout extends StatefulWidget {
  final int companyId;
  final String companyName;
  final String userId;
  final bool isAdmin; // ✅ Added isAdmin

  const MainLayout({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.userId,
    required this.isAdmin, // ✅ Required
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Container(
          color: Colors.white,
          child: Column(children: const []),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          userId: widget.userId,
          companyId: widget.companyId,
          companyName: widget.companyName,
          isAdmin: widget.isAdmin, // ✅ Fixed: get from widget
        ),
      ),
    );
  }
}
