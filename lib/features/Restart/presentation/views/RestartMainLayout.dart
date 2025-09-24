import 'package:flutter/material.dart';

import 'RestartBranch.dart';
import 'RestartCompany.dart';
import 'RestartMobile.dart';

class RestartMainLayout extends StatefulWidget {
  final String userId;
  final int companyId;
  final String companyName;
  final int companyStatus;

  const RestartMainLayout({
    super.key,
    required this.userId,
    required this.companyId,
    required this.companyName,
    required this.companyStatus,
  });

  @override
  State<RestartMainLayout> createState() => _RestartMainLayoutState();
}

class _RestartMainLayoutState extends State<RestartMainLayout>
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
                padding: const EdgeInsets.only(top: 10, right: 5),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                      size: 28,
                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      Tab(child: Text("شركة")),
                      Tab(child: Text("فرع")),
                      Tab(child: Text("موبايل")),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    RestartCompany(
                      userId: widget.userId,
                      companyId: widget.companyId,
                      companyName: widget.companyName,
                      companyStatus: widget.companyStatus,
                    ),
                    RestartBranch(
                      userId: widget.userId,
                      companyId: widget.companyId,
                    ),
                    RestartMobile(
                      companyId: widget.companyId,
                      userId: widget.userId,
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
