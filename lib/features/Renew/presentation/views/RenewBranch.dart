import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';


class BranchFeeSetting {
  final int id;
  final int noMonths;
  final double fees;

  BranchFeeSetting({
    required this.id,
    required this.noMonths,
    required this.fees,
  });

  factory BranchFeeSetting.fromJson(Map<String, dynamic> json) {
    return BranchFeeSetting(
      id: json['id'],
      noMonths: json['noMonths'],
      fees: json['fees'].toDouble(),
    );
  }
}

class BranchModel {
  final int subscriptionId;
  final int id;
  final String name;
  final double fees;
  final int noMonth;
  final bool isPaid;
  final bool isBackageIsExpire;

  BranchModel({
    required this.subscriptionId,
    required this.id,
    required this.name,
    required this.fees,
    required this.noMonth,
    required this.isPaid,
    required this.isBackageIsExpire,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      subscriptionId: json['branchSubscribtionId'],
      id: json['branchId'],
      name: json['branchName'],
      fees: (json['fees'] as num).toDouble(),
      noMonth: json['noMonth'],
      isPaid: json['isPaid'],
      isBackageIsExpire: json['isBackageIsExpire'],
    );
  }
}

class RenewBranch extends StatefulWidget {
  final int companyId;
  final String userId;
  const RenewBranch({super.key, required this.companyId, required this.userId});

  @override
  State<RenewBranch> createState() => _RenewBranchState();
}

class _RenewBranchState extends State<RenewBranch> {
  final TextEditingController phoneController = TextEditingController();
  List<BranchModel> branches = [];
  BranchModel? _selectedBranch;

  bool isLoadingBranches = true;
  bool isLoadingFees = true;

  List<BranchFeeSetting> feeOptions = [];
  BranchFeeSetting? _selectedFee;

  @override
  void initState() {
    super.initState();
    fetchBranches();
    fetchFeeSettings();
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

  Future<void> fetchBranches() async {
    try {
      final url = Uri.parse(
        'http://197.134.252.181/StockGuideAPI/Branch/GetAllBranchesByCompanyIdInRenew?companyId=${widget.companyId}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];
        print(data.map((e) => BranchModel.fromJson(e)).toList());
        if (mounted) {
          setState(() {
              branches = data.map((e) => BranchModel.fromJson(e)).toList();
              isLoadingBranches = false;
          });
        }
      } else {
        throw Exception("Failed to fetch branches");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingBranches = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ في تحميل الفروع: $e")),
      );
    }
  }

  Future<void> fetchFeeSettings() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://197.134.252.181/StockGuideAPI/Branch/GetSettingOfBranchFeesInFirstTime",
        ),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as List;
        final options =
        data.map((e) => BranchFeeSetting.fromJson(e)).toList();

        setState(() {
          feeOptions = options;
          _selectedFee = options.isNotEmpty ? options.first : null;
          isLoadingFees = false;
        });
      } else {
        throw Exception("Failed to load fee settings");
      }
    } catch (e) {
      setState(() => isLoadingFees = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء تحميل الاشتراكات: $e")),
      );
    }
  }

  Future<void> _uploadReceipt() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      var uri = Uri.parse(
          "http://197.134.252.181/StockGuideAPI/Files/UploadSubscriptionFile");

      var request = http.MultipartRequest("POST", uri);
      request.fields['SubscriptionBranchId'] =
          _selectedBranch?.subscriptionId.toString() ?? "0";
      request.fields['SubscriptionUserId'] = "123";
      request.files.add(await http.MultipartFile.fromPath('File', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        await showMessageDialog("تم رفع الإيصال بنجاح ✅");
      } else {
        await showMessageDialog(
            "فشل رفع الإيصال ❌ (كود: ${response.statusCode})");
      }
    } else {
      await showMessageDialog("لم يتم اختيار ملف 📄");
    }
  }

  Future<void> renewBranch() async {
    if (_selectedBranch == null || _selectedFee == null) {
      await showMessageDialog("يرجى اختيار الفرع والباقات أولاً ⚠️");
      return;
    }

    final url =
    Uri.parse("http://197.134.252.181/StockGuideAPI/Branch/UpdateBranch");

    final body = {
      "branchId": _selectedBranch!.id,
      "branchName": _selectedBranch!.name,
      "companyId": widget.companyId,
      "userId": widget.userId,
      "noMonth": _selectedFee!.noMonths,
      "fees": _selectedFee!.fees,
    };

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      print("/*/*");
      print(response.body);
      print("/*/*");

      if (response.statusCode == 200) {
        await showMessageDialog("تم تجديد الاشتراك بنجاح ✅");
      } else {
        await showMessageDialog(
            "فشل التجديد ❌ (كود: ${response.statusCode})");
      }
    } catch (e) {
      await showMessageDialog("خطأ في الاتصال بالسيرفر ❌: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'تجديد فرع',
            style: GoogleFonts.tajawal(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoadingBranches
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonHideUnderline(
              child: DropdownButton<BranchModel>(
                hint: const Text('اختر الفرع'),
                value: _selectedBranch,
                isExpanded: true,
                onChanged: (branch) {
                  setState(() => _selectedBranch = branch);
                },
                items: branches.map((branch) {
                  return DropdownMenuItem(
                    value: branch,
                    child: Text(branch.name),
                  );
                }).toList(),
              )
            ),
          ),

          const SizedBox(height: 20),

          isLoadingFees
              ? const Center(child: CircularProgressIndicator())
              : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: feeOptions.map((option) {
              final isSelected = _selectedFee?.id == option.id;
              return Expanded(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _selectedFee = option),
                  child: Container(
                    margin:
                    const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade50
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${option.noMonths} شهور",
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                        Text(
                          "(${option.fees.toStringAsFixed(0)} جم)",
                          style: GoogleFonts.tajawal(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 25),

          /// Total
          Text(
            _selectedFee == null
                ? "الاجمالي: -"
                : "الاجمالي: ${_selectedFee!.fees.toStringAsFixed(0)} ج.م",
            style: GoogleFonts.tajawal(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          /// Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: renewBranch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'تجديد',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _uploadReceipt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    'ارفاق ايصال الدفع',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
