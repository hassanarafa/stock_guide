import 'package:flutter/material.dart';

import '../widgets/CustomNavBar.dart';

class StockGuideMainLayout extends StatefulWidget {
  const StockGuideMainLayout({super.key});

  @override
  State<StockGuideMainLayout> createState() => _StockGuideMainLayoutState();
}

class _StockGuideMainLayoutState extends State<StockGuideMainLayout>
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
        body: Column(children: []),
        bottomNavigationBar: const CustomNavBar(),
      ),
    );
  }
}
