import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';

class BranchFeeSetting {
  final int id;
  final int branchId;
  final int noMonths;
  final double fees;

  BranchFeeSetting({
    required this.id,
    required this.branchId,
    required this.noMonths,
    required this.fees,
  });

  factory BranchFeeSetting.fromJson(Map<String, dynamic> json) {
    return BranchFeeSetting(
      id: json['id'] ?? 0,
      branchId: json['branchId'] ?? 0,
      noMonths: json['noMonths'] ?? 0,
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
  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> _branches = [];

  List<BranchFeeSetting> _feeOptions = [];
  BranchFeeSetting? _selectedFee;
  bool _isLoadingFees = true;
  Map<String, dynamic>? _selectedBranch;

  Map<String, dynamic>? _editingBranch;

  @override
  void initState() {
    super.initState();
    fetchFeeSettings().then((_) {
      fetchUnpaidBranches(widget.companyId);
    });
  }

  @override
  void dispose() {
    branchController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> deleteBranch(int branchId, int companyId, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://197.134.252.181/StockGuideAPI/Branch/DeleteBranch"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "branchId": branchId,
          "companyId": companyId,
          "userId": userId,
        }),
      );

      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        print(response.body);
        if (resBody['success'] == true) {
          setState(() {
            _branches.removeWhere((branch) => branch['branchId'] == branchId);
            if (_selectedBranch != null &&
                _selectedBranch!['branchId'] == branchId) {
              _selectedBranch = null;
            }
          });
          showMessageDialog("✅ تم حذف الفرع بنجاح");
        } else {
          showMessageDialog("❌ فشل الحذف: ${resBody['message']}");
        }
      } else {
        showMessageDialog("❌ فشل الحذف (كود: ${response.statusCode})");
      }
    } catch (e) {
      showMessageDialog("⚠️ خطأ أثناء الاتصال: $e");
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

  Future<List<String>> fetchExistingBranches(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://197.134.252.181/StockGuideAPI/Branch/BranchGetAllByCompanyIdWithStatus?companyId=$companyId",
        ),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as List;

        return data
            .map((branch) => branch['branchName'].toString().toLowerCase())
            .toList();
      } else {
        throw Exception("Failed to fetch branches");
      }
    } catch (e) {
      showMessageDialog("خطأ أثناء التحقق من الفروع: $e");
      return [];
    }
  }

  Future<void> _uploadReceipt({required String userId}) async {
    final selectedBranches = _branches
        .where((b) => b['checked'] == true)
        .toList();

    if (selectedBranches.isEmpty) {
      showMessageDialog("يرجى اختيار فرع واحد على الأقل");
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
      if (result != null) {
        file = File(result.files.single.path!);
      }
    } else if (choice == "camera") {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        file = File(pickedFile.path);
      }
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

    for (var branch in selectedBranches) {
      request.fields.putIfAbsent(
        'SubscribtionBranchIds[${selectedBranches.indexOf(branch)}]',
        () => branch['id'].toString(),
      );
    }

    request.files.add(await http.MultipartFile.fromPath('File', file.path));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var response = await request.send();
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        showMessageDialog("تم رفع الإيصال بنجاح ✅");
        setState(() {
          _branches.forEach((b) => b['checked'] = false);
          _selectedBranch = null;
        });
      } else {
        showMessageDialog("فشل رفع الإيصال ❌ (كود: ${response.statusCode})");
      }
    } catch (e) {
      Navigator.of(context).pop();
      showMessageDialog("حدث خطأ أثناء رفع الإيصال: $e");
    }
  }

  Future<void> fetchUnpaidBranches(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://197.134.252.181/StockGuideAPI/Branch/GetAllBranchesByCompanyIdInRenew?companyId=$companyId",
        ),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        final currentUnpaid = List<Map<String, dynamic>>.from(
          data['currentUnpaidSubscription'] ?? [],
        );

        final noActive = List<Map<String, dynamic>>.from(
          data['noActiveSubscriptionToday'] ?? [],
        );

        final unpaidBranches = [
          ...currentUnpaid,
          ...noActive,
        ].where((b) => b['isPaid'] == false).toList();

        setState(() {
          _branches.clear();
          for (var branch in unpaidBranches) {
            _branches.add({
              'id': branch['branchSubscribtionId'],
              "branchId": branch['branchId'],
              'name': branch['branchName'],
              'amount': '${branch['fees']} ج.م',
              'checked': false,
            });
          }
        });
      } else {
        showMessageDialog("فشل في تحميل الفروع غير المدفوعة");
      }
    } catch (e) {
      showMessageDialog("حدث خطأ أثناء تحميل الفروع غير المدفوعة: $e");
    }
  }

  int calculateTotalFees() {
    int total = 0;
    for (var branch in _branches) {
      if (branch['checked'] == true) {
        final amount = branch['amount'].toString().replaceAll("ج.م", "").trim();

        total += int.tryParse(amount) ?? 0;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoadingFees
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => fetchUnpaidBranches(widget.companyId),
              child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
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

                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getString('userId');

                            if (userId == null || userId.isEmpty) {
                              showMessageDialog('فشل في جلب معرف المستخدم');
                              return;
                            }

                            if (_editingBranch != null) {
                              // ✅ تعديل فرع موجود
                              final body = {
                                "branchId": _editingBranch!['branchId'],
                                "branchName": name,
                                "companyId": widget.companyId,
                                "userId": userId,
                                "noMonth": _selectedFee?.noMonths ?? 0,
                                "fees": _selectedFee?.fees ?? 0,
                              };

                              try {
                                final response = await http.put(
                                  Uri.parse(
                                    "http://197.134.252.181/StockGuideAPI/Branch/UpdateBranchInRenew",
                                  ),
                                  headers: {"Content-Type": "application/json"},
                                  body: jsonEncode(body),
                                );

                                print(body);

                                if (response.statusCode == 200) {
                                  setState(() {
                                    _editingBranch!['name'] = name;
                                    _editingBranch!['amount'] =
                                        '${_selectedFee?.fees.toInt() ?? 0} ج.م';
                                  });

                                  _editingBranch = null;
                                  branchController.clear();
                                  _selectedFee = _feeOptions.first;

                                  showMessageDialog('تم تعديل الفرع بنجاح ✅');
                                } else {
                                  showMessageDialog(
                                    'فشل تعديل الفرع ❌ (كود: ${response.statusCode})',
                                  );
                                }
                              } catch (e) {
                                showMessageDialog(
                                  'حدث خطأ أثناء تعديل الفرع: $e',
                                );
                              }

                              return;
                            }

                            // ✅ إضافة فرع جديد (الكود القديم لإنشاء فرع)
                            final existingBranches =
                                await fetchExistingBranches(widget.companyId);

                            if (existingBranches.contains(name.toLowerCase())) {
                              showMessageDialog(
                                'هذا الفرع موجود بالفعل في قاعدة البيانات ❌',
                              );
                              return;
                            }

                            bool alreadyExistsLocally = _branches.any(
                              (branch) =>
                                  branch['name'].toString().toLowerCase() ==
                                  name.toLowerCase(),
                            );

                            if (alreadyExistsLocally) {
                              showMessageDialog(
                                'هذا الفرع موجود بالفعل محليًا ❌',
                              );
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
                                  "http://197.134.252.181/StockGuideAPI/Branch/CreateBranchForTheFirstTime",
                                ),
                                headers: {"Content-Type": "application/json"},
                                body: jsonEncode(body),
                              );

                              print(response.body);

                              if (response.statusCode == 200 ||
                                  response.statusCode == 201) {
                                final responseData = jsonDecode(response.body);

                                if (responseData['status'] == 1 &&
                                    responseData['data'] != null) {
                                  final branchId =
                                      responseData['data']['branchSubscribtionId'];

                                  setState(() {
                                    _branches.add({
                                      'id': branchId,
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
                                    "❌ فشل الإضافة: ${responseData['message'] ?? "حدث خطأ"}",
                                  );
                                }
                              } else {
                                showMessageDialog(
                                  'فشل في إضافة الفرع ❌ (كود: ${response.statusCode})',
                                );
                              }
                            } catch (e) {
                              print(e);
                              showMessageDialog(
                                'حدث خطأ أثناء إضافة الفرع: $e',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: const Size.fromHeight(55),
                            padding: const EdgeInsets.symmetric(vertical: 17.5),
                          ),
                          child: Text(
                            'اضافة',
                            style: GoogleFonts.tajawal(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

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
                                  onPressed: () {
                                    setState(() {
                                      _editingBranch = branch;
                                      branchController.text = branch['name'];

                                      // اختار الاشتراك اللي يطابق الفرع
                                      _selectedFee = _feeOptions.firstWhere(
                                        (fee) =>
                                            '${fee.fees.toInt()} ج.م' ==
                                            branch['amount'],
                                        orElse: () => _feeOptions.first,
                                      );
                                    });

                                    // ✅ يعمل scroll to top
                                    _scrollController.animateTo(
                                      0,
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final userId = prefs.getString('userId');
                                    final companyId = widget.companyId;

                                    if (userId == null) {
                                      showMessageDialog(
                                        '⚠️ فشل في جلب بيانات المستخدم',
                                      );
                                      return;
                                    }

                                    bool? confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) {
                                        return AlertDialog(
                                          title: Text(
                                            "تأكيد الحذف",
                                            style: GoogleFonts.tajawal(),
                                          ),
                                          content: Text(
                                            "هل تريد حذف الفرع (${branch['name']})؟",
                                            style: GoogleFonts.tajawal(),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child: Text(
                                                "إلغاء",
                                                style: GoogleFonts.tajawal(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: Text(
                                                "حذف",
                                                style: GoogleFonts.tajawal(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      print(branch['branchId']);
                                      print(companyId);
                                      print(userId);

                                      await deleteBranch(
                                        branch['branchId'],
                                        companyId,
                                        userId,
                                      );
                                    }
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
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString('userId');

                if (userId == null || userId.isEmpty) {
                  showMessageDialog('فشل في جلب معرف المستخدم');
                  return;
                }

                await _uploadReceipt(userId: userId);
              },
              label: Text(
                'ارفاق ايصال الدفع',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
