import 'package:flutter/material.dart';

import 'CustomerBalance.dart';
import 'VendorBalance.dart';
import 'ItemBalance.dart';

class StockInquiryMainLayout extends StatefulWidget {
  const StockInquiryMainLayout({super.key});

  @override
  State<StockInquiryMainLayout> createState() => _StockInquiryMainLayoutState();
}

class _StockInquiryMainLayoutState extends State<StockInquiryMainLayout>
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
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10,right: 5),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Container(
                height: 60,
                margin: const EdgeInsets.all(4),
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
                      Tab(child: Text("رصيد صنف")),
                      Tab(child: Text("رصيد عميل")),
                      Tab(child: Text("رصيد مورد")),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    ItemBalancePage(),
                    CustomerBalancePage(),
                    VendorBalancePage()
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
