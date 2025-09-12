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
  String? selectedBranchName;

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  Future<List<Map<String, dynamic>>> fetchBranchFeeSettings(
    int branchId,
  ) async {
    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Branch/GetSettingOfBranchFeesInFirstTime?branchId=$branchId",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print("Error fetching branch fee settings: $e");
    }
    return [];
  }

  Future<void> fetchBranches() async {
    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Branch/GetAllBranchesByCompanyIdInRenew?companyId=${widget.companyId}",
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        final data = body['data'] as Map<String, dynamic>;

        final List<dynamic> currentUnpaid =
            data['currentUnpaidSubscription'] ?? [];
        final List<dynamic> noActive = data['noActiveSubscriptionToday'] ?? [];

        final allBranches = [...currentUnpaid, ...noActive];

        setState(() {
          branches = allBranches.map((json) => Branch.fromJson(json)).toList();
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

  Future<void> renewBranch(String branchName, int branchId) async {
    setState(() {
      selectedBranchId = branchId;
      selectedBranchName = branchName;
      showRenewPage = true;
    });
  }

  void showEditDialog(Branch branch) async {
    final settings = await fetchBranchFeeSettings(branch.branchId);

    final TextEditingController nameController = TextEditingController(
      text: branch.branchName,
    );

    Map<String, dynamic>? selectedSetting = settings.isNotEmpty
        ? settings.first
        : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text("تعديل الفرع", style: GoogleFonts.tajawal()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "اسم الفرع"),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Map<String, dynamic>>(
                    decoration: const InputDecoration(labelText: "الخطة"),
                    value: selectedSetting,
                    items: settings.map((setting) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: setting,
                        child: Text(
                          "${setting['noMonths']} شهر - ${setting['fees']} ج.م",
                          style: GoogleFonts.tajawal(),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        selectedSetting = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text("إلغاء", style: GoogleFonts.tajawal()),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedSetting == null) return;
                    Navigator.pop(ctx);

                    final url = Uri.parse(
                      "http://197.134.252.181/StockGuideAPI/Branch/UpdateBranchInRenew",
                    );

                    final body = {
                      "branchId": branch.branchId,
                      "branchName": nameController.text,
                      "companyId": widget.companyId,
                      "userId": widget.userId,
                      "noMonth": selectedSetting!['noMonths'],
                      "fees": selectedSetting!['fees'],
                    };

                    try {
                      final response = await http.put(
                        url,
                        headers: {"Content-Type": "application/json"},
                        body: jsonEncode(body),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "تم تعديل ${branch.branchName} بنجاح ✅",
                              style: GoogleFonts.tajawal(),
                            ),
                          ),
                        );
                        fetchBranches(); // refresh list
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "فشل التعديل ❌",
                              style: GoogleFonts.tajawal(),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      print("Error updating branch: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "حدث خطأ أثناء التعديل ❌",
                            style: GoogleFonts.tajawal(),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text("حفظ", style: GoogleFonts.tajawal()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildBranchCard(Branch branch) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  branch.branchName,
                  style: GoogleFonts.tajawal(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: branch.isPaid ? Colors.green : Colors.orange,
                  child: Icon(
                    branch.isPaid ? Icons.check : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: "تعديل",
                  onPressed: () => showEditDialog(branch),
                ),
                if (!branch.isPaid) ...[
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        renewBranch(branch.branchName, branch.branchId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'تجديد',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
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
          userId: widget.userId,
          branchName: selectedBranchName!,
          branchId: selectedBranchId,
        )
            : SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : branches.isEmpty
              ? const Center(child: Text("لا توجد فروع"))
              : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: RefreshIndicator(
              onRefresh: () async => await fetchBranches(),
              child: ListView.builder(
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  return buildBranchCard(branches[index]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
