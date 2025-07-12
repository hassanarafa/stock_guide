import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants.dart';
import 'GetBranches.dart';
import 'GetMobiles.dart';

class InquiryMainLayout extends StatefulWidget {
  const InquiryMainLayout({super.key});

  @override
  State<InquiryMainLayout> createState() => _InquiryMainLayoutState();
}

class _InquiryMainLayoutState extends State<InquiryMainLayout> with SingleTickerProviderStateMixin{
  final List<String> _branchOptions = [
    'فرع القاهرة',
    'فرع الإسكندرية',
    'فرع الجيزة',
  ];
  String? _selectedBranch;

  bool _showBranches = false;

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, elevation: 0, backgroundColor: Colors.white),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: _showBranches
              ? _buildBranchesView() // Show branches view
              : _buildSelectionView(), // Show initial selection form
        ),
      ),
    );
  }

  Widget _buildSelectionView() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "اختر شركة",
            style: GoogleFonts.tajawal(
              textStyle: const TextStyle(
                color: primaryTextColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text('اختر الشركة'),
                value: _selectedBranch,
                icon: const Icon(Icons.arrow_drop_down),
                isExpanded: true,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBranch = newValue;
                  });
                },
                items: _branchOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  _showBranches = true;
                });
              },
              child: Text(
                'بحث',
                style: GoogleFonts.tajawal(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchesView() {
    return Column(
      children: [
        // Add TabBar here
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
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
              Tab(child: Text("الفروع")),
              Tab(child: Text("الموبايل")),
            ],
          ),
        ),

        // Show content below
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              GetBranches(),
              GetMobiles(),
            ],
          ),
        ),
      ],
    );
  }
}
