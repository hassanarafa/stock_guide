import 'package:flutter/material.dart';
import 'AddBranch.dart';
import 'AddMobile.dart';

class AddMainLayout extends StatefulWidget {
  final int companyId;
  final String companyName;
  final bool isAdmin;
  final bool hasRightToInsertBranch;
  final bool hasRightToInsertUsers;

  const AddMainLayout({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.isAdmin,
    required this.hasRightToInsertBranch,
    required this.hasRightToInsertUsers,
  });

  @override
  State<AddMainLayout> createState() => _AddMainLayoutState();
}

class _AddMainLayoutState extends State<AddMainLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Tab> _tabs;
  late List<Widget> _tabViews;

  @override
  void initState() {
    super.initState();

    _tabs = [];
    _tabViews = [];

    if (widget.isAdmin) {
      _tabs = [
        const Tab(child: Text("فرع")),
        const Tab(child: Text("موبايل")),
      ];
      _tabViews = [
        AddBranch(
          companyId: widget.companyId,
          companyName: widget.companyName,
        ),
        AddMobile(
          companyName: widget.companyName,
          companyId: widget.companyId,
        ),
      ];
    } else {
      if (widget.hasRightToInsertBranch) {
        _tabs.add(const Tab(child: Text("فرع")));
        _tabViews.add(AddBranch(
          companyId: widget.companyId,
          companyName: widget.companyName,
        ));
      }
      if (widget.hasRightToInsertUsers) {
        _tabs.add(const Tab(child: Text("موبايل")));
        _tabViews.add(AddMobile(
          companyName: widget.companyName,
          companyId: widget.companyId,
        ));
      }
    }

    _tabController = TabController(length: _tabs.length, vsync: this);
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
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.blue, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              if (_tabs.isNotEmpty)
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
                      labelStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                      indicatorPadding: const EdgeInsets.all(2),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: _tabs,
                    ),
                  ),
                ),

              if (_tabViews.isNotEmpty)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabViews,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
