import 'package:flutter/material.dart';

import 'StopBranch.dart';
import 'StopCompany.dart';
import 'StopMobile.dart';

class StopMainLayout extends StatefulWidget {
  final String userId;
  final int companyId;
  final String companyName;
  final int companyStatus;

  const StopMainLayout({
    super.key,
    required this.userId,
    required this.companyId,
    required this.companyName,
    required this.companyStatus,
  });

  @override
  State<StopMainLayout> createState() => _StopMainLayoutState();
}

class _StopMainLayoutState extends State<StopMainLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _companyStatus;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _companyStatus = widget.companyStatus;
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
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                      Tab(child: Text("ايقاف شركة")),
                      Tab(child: Text("ايقاف فرع")),
                      Tab(child: Text("ايقاف موبايل")),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    StopCompany(
                      userId: widget.userId,
                      companyName: widget.companyName,
                      companyId: widget.companyId,
                      companyStatus: widget.companyStatus,
                    ),
                    StopBranch(
                      userId: widget.userId,
                      companyId: widget.companyId,
                    ),
                    StopMobile(
                      userId: widget.userId,
                      companyId: widget.companyId,
                    ),
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
