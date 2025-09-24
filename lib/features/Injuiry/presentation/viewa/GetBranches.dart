import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../Renew/presentation/views/RenewBranch.dart';

class Branch {
  final int branchId;
  final String branchName;
  final bool isPaid;
  int? noMonths;
  int? fees;
  String? currentSubscribtion;   // 👈 جديد

  Branch({
    required this.branchId,
    required this.branchName,
    required this.isPaid,
    this.noMonths,
    this.fees,
    this.currentSubscribtion,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      branchId: json['branchId'],
      branchName: json['branchName'],
      isPaid: json['isPaid'] ?? false,
      noMonths: json['noMonths'] ?? json['noMonth'], // 👈 بعض الـ API يرجعها noMonth
      fees: (json['fees'] != null)
          ? int.tryParse(json['fees'].toString())
          : null,
      currentSubscribtion: json['currentSubscribtion']?.toString(), // 👈 جديد
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

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }


  Future<List<Map<String, dynamic>>> fetchBranchFeeSettings(
    int branchId,
  ) async {
    if (!await _checkInternet()) {
      await showMessageDialog("⚠️ لا يوجد اتصال بالإنترنت");
      return [];
    }

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
    if (!await _checkInternet()) {
      await showMessageDialog("⚠️ لا يوجد اتصال بالإنترنت");
      setState(() => isLoading = false);
      return;
    }


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

        List<Branch> loadedBranches =
        allBranches.map((json) => Branch.fromJson(json)).toList();

        for (var branch in loadedBranches) {
          final settings = await fetchBranchFeeSettings(branch.branchId);
          if (settings.isNotEmpty) {
            branch.noMonths = settings.first['noMonths'];
            final feeValue = settings.first['fees'];
            if (feeValue != null) {
              if (feeValue is double) {
                branch.fees = feeValue.toInt();
              } else if (feeValue is int) {
                branch.fees = feeValue;
              } else {
                branch.fees = int.tryParse(feeValue.toString());
              }
            }
          }
        }

        setState(() {
          branches = loadedBranches;
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

  Future<void> showMessageDialog(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'حسناً',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  color: Colors.lightBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(Branch branch) async {
    final TextEditingController nameController = TextEditingController(
      text: branch.branchName,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("تعديل اسم الفرع", style: GoogleFonts.tajawal()),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "اسم الفرع"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("إلغاء", style: GoogleFonts.tajawal()),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();

                if (newName.isEmpty) {
                  await showMessageDialog("⚠️ يجب إدخال اسم الفرع");
                  return;
                }

                // ✅ تحقق من وجود اسم مكرر عند فرع آخر
                final duplicate = branches.any((b) =>
                b.branchId != branch.branchId &&
                    b.branchName == newName);

                if (duplicate) {
                  await showMessageDialog("⚠️ اسم الفرع مستخدم بالفعل");
                  return;
                }

                if (!await _checkInternet()) {
                  await showMessageDialog("⚠️ لا يوجد اتصال بالإنترنت");
                  return;
                }

                Navigator.pop(ctx);

                final url = Uri.parse(
                  "http://197.134.252.181/StockGuideAPI/Branch/UpdateBranchInRenew",
                );

                final body = {
                  "branchId": branch.branchId,
                  "branchName": newName,
                  "companyId": widget.companyId,
                  "userId": widget.userId,
                };

                try {
                  final response = await http.put(
                    url,
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(body),
                  );

                  if (response.statusCode == 200) {
                    await showMessageDialog("تم تعديل اسم الفرع بنجاح ✅");
                    fetchBranches(); // refresh list
                  } else {
                    await showMessageDialog("فشل التعديل ❌");
                  }
                } catch (e) {
                  print("Error updating branch: $e");
                  await showMessageDialog("حدث خطأ أثناء التعديل ❌");
                }
              },
              child: Text("حفظ", style: GoogleFonts.tajawal()),
            ),
          ],
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
            if (branch.noMonths != null && branch.fees != null) ...[
              Text(
                "📅 عدد الشهور: ${branch.noMonths}",
                style: GoogleFonts.tajawal(fontSize: 16, color: Colors.black87),
              ),
              Text(
                "💰 الرسوم: ${branch.fees} ج.م",
                style: GoogleFonts.tajawal(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 12),
            ],
            if (branch.currentSubscribtion != null && branch.currentSubscribtion!.isNotEmpty) ...[
              Text(
                "📝 ${branch.currentSubscribtion}",
                style: GoogleFonts.tajawal(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 12),
            ],
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
