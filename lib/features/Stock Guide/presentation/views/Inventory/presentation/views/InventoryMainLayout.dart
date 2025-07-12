import 'package:flutter/material.dart';

import 'FullClothes.dart';
import 'PartClothes.dart';
import 'SubClothes.dart';

class InventoryMainLayout extends StatefulWidget {
  const InventoryMainLayout({super.key});

  @override
  State<InventoryMainLayout> createState() => _InventoryMainLayoutState();
}

class _InventoryMainLayoutState extends State<InventoryMainLayout>
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
        appBar: AppBar(elevation: 0, backgroundColor: Colors.white),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Top Custom Styled Tabs
              Container(
                height: 60,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.white,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    indicatorPadding: const EdgeInsets.all(2),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(child: Text("طقم كامل")),
                      Tab(child: Text("ثري كامل")),
                      Tab(child: Text("قطعة محددة")),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    FullClothesPage(),
                    SubClothesPage(),
                    PartClothesPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
