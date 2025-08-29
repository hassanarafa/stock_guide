import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import 'GetBranches.dart';
import 'GetMobiles.dart';

class Company {
  final int id;
  final String name;
  final int statusId;
  final String statusName;

  Company({
    required this.id,
    required this.name,
    required this.statusId,
    required this.statusName,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['companyId'],
      name: json['companyName'],
      statusId: json['statusId'],
      statusName: json['statusName'],
    );
  }
}

class InquiryMainLayout extends StatefulWidget {
  final String userId;
  final int companyId;

  const InquiryMainLayout({
    super.key,
    required this.userId,
    required this.companyId,
  });

  @override
  State<InquiryMainLayout> createState() => _InquiryMainLayoutState();
}

class _InquiryMainLayoutState extends State<InquiryMainLayout>
    with SingleTickerProviderStateMixin {
  List<Company> companies = [];

  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    fetchCompanies();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchCompanies() async {
    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Company/GetAllByUser?userId=${widget.userId}",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data'];

        setState(() {
          companies = data
              .map((json) => Company.fromJson(json))
              .where((company) => company.statusId == 1)
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching companies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
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
                  Tab(child: Text("الفروع")),
                  Tab(child: Text("الموبايل")),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                GetBranches(companyId: widget.companyId, userId: widget.userId),
                GetMobiles(companyId: widget.companyId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
