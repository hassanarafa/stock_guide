import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../Renew/presentation/views/RenewBranch.dart';

class Branch {
  final int branchId;
  final String branchName;
  final bool isPaid;

  Branch({
    required this.branchId,
    required this.branchName,
    required this.isPaid,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchId: json['branchId'],
      branchName: json['branchName'],
      isPaid: json['isPaid'] ?? false,
    );
  }
}

class GetBranches extends StatefulWidget {
  final String userId;
  final int companyId;
  const GetBranches({super.key, required this.companyId, required this.userId});

  @override
  State<GetBranches> createState() => _GetBranchesState();
}

class _GetBranchesState extends State<GetBranches> {
  List<Branch> branches = [];
  bool isLoading = true;

  bool showRenewPage = false;
  int? selectedBranchId;


  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Branch/GetAllBranchesByCompanyIdInRenew?companyId=${widget.companyId}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data'];

        setState(() {
          branches = data.map((json) => Branch.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load branches");
      }
    } catch (e) {
      print("Error fetching branches: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> renewBranch(int branchId) async {
    setState(() {
      selectedBranchId = branchId;
      showRenewPage = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم الضغط على تجديد للفرع رقم $branchId")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: showRenewPage
            ? RenewBranch(
          companyId: widget.companyId,
          userId: widget.userId, // ⚡ pass the real userId
        )
            : SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : branches.isEmpty
              ? const Center(child: Text("لا توجد فروع"))
              : Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.branchName,
                            style: GoogleFonts.tajawal(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: branch.isPaid
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              branch.isPaid
                                  ? Icons.check
                                  : Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () =>
                                renewBranch(branch.branchId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "تجديد",
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
