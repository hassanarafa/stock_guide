import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
  final int branchSubscribtionId;
  final int id;
  final String name;
  final double fees;
  final int noMonth;
  final bool isPaid;
  final bool isBackageIsExpire;
  final int currentStatusId;

  BranchModel({
    required this.branchSubscribtionId,
    required this.id,
    required this.name,
    required this.fees,
    required this.noMonth,
    required this.isPaid,
    required this.isBackageIsExpire,
    required this.currentStatusId,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      branchSubscribtionId: json['branchSubscribtionId'] ?? 0,
      id: json['branchId'],
      name: json['branchName'],
      fees: (json['fees'] as num).toDouble(),
      noMonth: json['noMonth'],
      isPaid: json['isPaid'],
      isBackageIsExpire: json['isBackageIsExpire'],
      currentStatusId: json['currentStatusId'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'BranchModel('
        'branchSubscribtionId: $branchSubscribtionId, '
        'id: $id, '
        'name: $name, '
        'fees: $fees, '
        'noMonth: $noMonth, '
        'isPaid: $isPaid, '
        'isBackageIsExpire: $isBackageIsExpire, '
        'currentStatusId: $currentStatusId'
        ')';
  }
}

class RenewBranch extends StatefulWidget {
  final int companyId;
  final String userId;
  final String? branchName;
  final int? branchId;

  const RenewBranch({
    super.key,
    required this.companyId,
    required this.userId,
    this.branchName,
    this.branchId,
  });

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
  bool canUploadReceipt = false;

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

      print("/*/*/*/*/*");
      print(response.body);
      print("/*/*/*/*/*");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final List<dynamic> data =
            decoded['data']?['noActiveSubscriptionToday'] ?? [];

        final filtered = data.where((e) => e['isPaid'] == true).toList();

        if (mounted) {
          setState(() {
            branches = filtered.map((e) => BranchModel.fromJson(e)).toList();
            print("=/=/=/=/=/=/=/");
            print(branches);
            print("=/=/=/=/=/=/=/");
            isLoadingBranches = false;

            if (widget.branchId != null) {
              try {
                _selectedBranch = branches.firstWhere(
                      (b) => b.id == widget.branchId,
                );
              } catch (e) {
                _selectedBranch = branches.isNotEmpty ? branches.first : null;
              }
            } else {
              _selectedBranch = null;
            }
          });
        }

        if (branches.isEmpty) {
          await showMessageDialog("لا يوجد فروع مدفوعة ✅");
        }
      } else {
        throw Exception("فشل تحميل الفروع (كود: ${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingBranches = false);
      }
      await showMessageDialog("خطأ في تحميل الفروع ❌: $e");
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
        final options = data.map((e) => BranchFeeSetting.fromJson(e)).toList();

        setState(() {
          feeOptions = options;
          _selectedFee = options.isNotEmpty ? options.first : null;
          isLoadingFees = false;
        });
      } else {
        throw Exception("فشل تحميل الاشتراكات (كود: ${response.statusCode})");
      }
    } catch (e) {
      setState(() => isLoadingFees = false);
      await showMessageDialog("حدث خطأ أثناء تحميل الاشتراكات ❌: $e");
    }
  }

  Future<void> _uploadReceipt({required String userId}) async {
    if (_selectedBranch == null) {
      showMessageDialog("⚠️ يرجى اختيار فرع أولاً");
      return;
    }

    File? file;

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("اختيار طريقة الرفع", style: GoogleFonts.tajawal()),
          content: Text("من فضلك اختر الطريقة:", style: GoogleFonts.tajawal()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, "file"),
              child: Text("📂 من الملفات", style: GoogleFonts.tajawal()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, "camera"),
              child: Text("📸 من الكاميرا", style: GoogleFonts.tajawal()),
            ),
          ],
        );
      },
    );

    if (choice == null) return;

    if (choice == "file") {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) file = File(result.files.single.path!);
    } else if (choice == "camera") {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) file = File(pickedFile.path);
    }

    if (file == null) {
      showMessageDialog("لم يتم اختيار ملف 📄");
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "تأكيد رفع الملف",
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("هل تريد رفع هذا الملف؟", style: GoogleFonts.tajawal()),
              const SizedBox(height: 10),
              Text(
                "📄 ${file!.path.split('/').last}",
                style: GoogleFonts.tajawal(),
              ),
              const SizedBox(height: 5),
              Text(
                "الحجم: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB",
                style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                "إلغاء",
                style: GoogleFonts.tajawal(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                "تأكيد",
                style: GoogleFonts.tajawal(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final uri = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Files/UploadSubscriptionGroup",
    );

    var request = http.MultipartRequest("POST", uri);

    print("///////////////////////////////");
    print(_selectedBranch!.branchSubscribtionId);
    print("///////////////////////////////");

    request.fields['SubscribtionBranchIds[0]'] = _selectedBranch!.branchSubscribtionId
        .toString();

    request.files.add(await http.MultipartFile.fromPath('File', file.path));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var response = await request.send();
      Navigator.of(context).pop(); // إغلاق الـ Loader

      if (response.statusCode == 200) {
        showMessageDialog("✅ تم رفع الإيصال بنجاح");
        setState(() {
          _selectedBranch = null;
          canUploadReceipt = false;
        });
      } else {
        showMessageDialog("❌ فشل رفع الإيصال (كود: ${response.statusCode})");
      }
    } catch (e) {
      Navigator.of(context).pop();
      showMessageDialog("⚠️ خطأ أثناء الاتصال بالسيرفر: $e");
    }
  }

  Future<void> renewBranch() async {
    if (_selectedBranch == null || _selectedFee == null) {
      await showMessageDialog("يرجى اختيار الفرع والباقات أولاً ⚠️");
      return;
    }

    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Branch/UpdateBranchInRenew",
    );

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

      print(response.statusCode);

      if (response.statusCode == 200) {
        setState(() {
          canUploadReceipt = true;
        });
        await showMessageDialog("تم تجديد الاشتراك بنجاح ✅");
      } else {
        await showMessageDialog("فشل التجديد ❌ (كود: ${response.statusCode})");
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
                    ),
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
                        onTap: () => setState(() => _selectedFee = option),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
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

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: renewBranch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // 🔵 زوايا أنعم
                    ),
                  ),
                  child: Text(
                    'تجديد',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: canUploadReceipt
                      ? () => _uploadReceipt(userId: widget.userId)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canUploadReceipt
                        ? Colors.green
                        : Colors.grey,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'ارفاق ايصال الدفع',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
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
