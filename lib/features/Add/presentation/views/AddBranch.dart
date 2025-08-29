import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

class AddBranch extends StatefulWidget {
  final int companyId;
  final String companyName;

  const AddBranch({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<AddBranch> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  final TextEditingController branchController = TextEditingController();

  late List<Map<String, dynamic>> _branches = [];

  List<BranchFeeSetting> _feeOptions = [];
  BranchFeeSetting? _selectedFee;
  bool _isLoadingFees = true;
  Map<String, dynamic>? _selectedBranch;

  @override
  void initState() {
    super.initState();
    fetchFeeSettings();
  }

  /// ✅ Dialog function instead of SnackBars
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
        _feeOptions = data.map((e) => BranchFeeSetting.fromJson(e)).toList();

        setState(() {
          _isLoadingFees = false;
          _selectedFee = _feeOptions.first;
        });
      } else {
        throw Exception("Failed to load fee settings");
      }
    } catch (e) {
      setState(() => _isLoadingFees = false);
      showMessageDialog("حدث خطأ أثناء تحميل الاشتراكات: $e");
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
          _selectedBranch?['id'].toString() ?? "0";
      request.fields['SubscriptionUserId'] = "123";
      request.files.add(await http.MultipartFile.fromPath('File', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        showMessageDialog("تم رفع الإيصال بنجاح ✅");
        setState(() {
          _branches.clear();
          _selectedBranch = null;
        });
      } else {
        showMessageDialog("فشل رفع الإيصال ❌ (كود: ${response.statusCode})");
      }
    } else {
      showMessageDialog("لم يتم اختيار ملف 📄");
    }
  }

  int calculateTotalFees() {
    int total = 0;
    for (var branch in _branches) {
      if (branch['checked'] == true) {
        final amountString =
        branch['amount'].toString().replaceAll(' ج.م', '').trim();
        final amount = int.tryParse(amountString) ?? 0;
        total += amount;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoadingFees
          ? const Center(child: CircularProgressIndicator())
          : Container(
        height: double.infinity,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'الفروع التابعة لـ: ${widget.companyName}',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: branchController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: 'اسم الفرع',
                    hintStyle: GoogleFonts.tajawal(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _feeOptions.map((option) {
                    final label = '${option.noMonths} شهور';
                    final price =
                        '(${option.fees.toStringAsFixed(0)} جم)';
                    final isSelected = _selectedFee?.id == option.id;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedFee = option);
                        },
                        child: Container(
                          margin:
                          const EdgeInsets.symmetric(horizontal: 4),
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
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
                                label,
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
                                price,
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

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = branchController.text.trim();

                      if (name.isEmpty) {
                        showMessageDialog('يرجى إدخال اسم الفرع');
                        return;
                      }

                      // ✅ Prevent duplicate branch names
                      bool alreadyExists = _branches.any((branch) =>
                      branch['name']
                          .toString()
                          .toLowerCase() ==
                          name.toLowerCase());

                      if (alreadyExists) {
                        showMessageDialog('هذا الفرع موجود بالفعل');
                        return;
                      }

                      final prefs =
                      await SharedPreferences.getInstance();
                      final userId = prefs.getString('userId');

                      if (userId == null || userId.isEmpty) {
                        showMessageDialog('فشل في جلب معرف المستخدم');
                        return;
                      }

                      final body = {
                        "branchName": name,
                        "companyId": widget.companyId,
                        "userId": userId,
                        "noMonth": _selectedFee?.noMonths ?? 0,
                        "fees": _selectedFee?.fees ?? 0,
                      };

                      try {
                        final response = await http.post(
                          Uri.parse(
                              "http://197.134.252.181/StockGuideAPI/Branch/CreateBranchForTheFirstTime"),
                          headers: {"Content-Type": "application/json"},
                          body: jsonEncode(body),
                        );

                        if (response.statusCode == 200 ||
                            response.statusCode == 201) {
                          setState(() {
                            _branches.add({
                              'id': DateTime.now()
                                  .millisecondsSinceEpoch,
                              'name': name,
                              'amount':
                              '${_selectedFee?.fees?.toInt() ?? 0} ج.م',
                              'checked': true,
                            });
                            _selectedBranch = _branches.last;
                            branchController.clear();
                            _selectedFee = _feeOptions.first;
                          });

                          showMessageDialog('تمت إضافة الفرع بنجاح ✅');
                        } else {
                          showMessageDialog(
                              'فشل في إضافة الفرع: ${response.statusCode}');
                        }
                      } catch (e) {
                        showMessageDialog('حدث خطأ: $e');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                      const EdgeInsets.symmetric(vertical: 17.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'اضافة',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                ..._branches.map((branch) {
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 10,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: branch['checked'] ?? false,
                            activeColor: Colors.blue,
                            onChanged: (bool? value) {
                              setState(() {
                                branch['checked'] = value ?? false;
                                _selectedBranch = branch;
                              });
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch['name']!,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  branch['amount']!,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _branches.remove(branch);
                                if (_selectedBranch == branch) {
                                  _selectedBranch = null;
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'الاجمالي: ${calculateTotalFees()} ج.م',
                style: GoogleFonts.tajawal(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _uploadReceipt,
              label: Text(
                'ارفاق ايصال الدفع',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
