import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';

class UserFeeSetting {
  final int id;
  final int noMonths;
  final String userId;
  final double fees;

  UserFeeSetting({
    required this.id,
    required this.userId,
    required this.noMonths,
    required this.fees,
  });

  factory UserFeeSetting.fromJson(Map<String, dynamic> json) {
    return UserFeeSetting(
      id: json['id'],
      userId: json['userId']?.toString() ?? "",
      noMonths: json['noMonths'],
      fees: json['fees'].toDouble(),
    );
  }
}

class AddMobile extends StatefulWidget {
  final String companyName;
  final int companyId;

  const AddMobile({
    super.key,
    required this.companyName,
    required this.companyId,
  });

  @override
  State<AddMobile> createState() => _AddMobileState();
}

class _AddMobileState extends State<AddMobile> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> _users = [];
  bool _isPasswordVisible = false;

  List<UserFeeSetting> _feeOptions = [];
  UserFeeSetting? _selectedFee;
  bool _isLoadingFees = true;

  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;

  bool _isEditing = false;
  String? _editingUserId;

  Future<bool> checkIfUserExists(String mobile, int companyId) async {
    if (!await _checkInternet()) {
      await showMessageDialog("⚠️ لا يوجد اتصال بالإنترنت");
      return false;
    }
    try {
      final response = await http.get(
        Uri.parse(
          "http://197.134.252.181/StockGuideAPI/User/GetAllUsersByCompanyIdInRenew?companyId=$companyId",
        ),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final data = body['data'];

        final List allUsers = [
          ...data['noSubscriptionEver'],
          ...data['currentUnpaidSubscription'],
          ...data['noActiveSubscriptionToday'],
        ];

        return allUsers.any((user) => user['mobile'] == mobile);
      } else {
        await showMessageDialog("فشل التحقق من المستخدم ❌");
        return false;
      }
    } catch (e) {
      await showMessageDialog("خطأ أثناء التحقق من المستخدم: $e");
      print(e);
      return false;
    }
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

  Future<void> fetchUnpaidUsers(int companyId) async {
    if (!await _checkInternet()) {
      await showMessageDialog("⚠️ لا يوجد اتصال بالإنترنت");
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          "http://197.134.252.181/StockGuideAPI/User/GetAllUsersByCompanyIdInRenew?companyId=$companyId",
        ),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];

        final currentUnpaid = List<Map<String, dynamic>>.from(
          data['currentUnpaidSubscription'] ?? [],
        );

        final noSub = List<Map<String, dynamic>>.from(
          data['noSubscriptionEver'] ?? [],
        );

        final noActive = List<Map<String, dynamic>>.from(
          data['noActiveSubscriptionToday'] ?? [],
        );

        final unpaidUsers = [
          ...currentUnpaid,
          ...noSub,
          ...noActive,
        ].where((b) => b['isPaid'] == false).toList();

        setState(() {
          _users.clear();
          for (var user in unpaidUsers) {
            _users.add({
              'id': user['userSubscribtionId'],
              'userId': user['userId'],
              'name': user['displayName'] ?? '',
              'mobile': user['mobile'] ?? '',
              'password': user['password'] ?? '',
              'amount': '${user['fees']} ج.م',
              'checked': false,
              'noMonth': user['noMonth'] ?? 0,
              'fees': user['fees'] ?? 0,
              'hasRightToInsertBranch': false,
              'hasRightToInsertUsers': false,
            });
          }
        });
      } else {
        await showMessageDialog("فشل تحميل المستخدمين ❌");
      }
    } catch (e) {
      await showMessageDialog("حدث خطأ أثناء تحميل المستخدمين: $e");
    }
  }

  Future<void> deleteUser(String userId, int companyId) async {
    if (!await _checkInternet()) {
      await showMessageDialog("⚠️ لا يوجد اتصال بالإنترنت");
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final deletedByUserId = prefs.getString('userId');

    if (deletedByUserId == null) {
      await showMessageDialog("⚠️ لم يتم العثور على معرف المستخدم الحالي");
      return;
    }

    try {
      final body = jsonEncode({
        "companyId": companyId,
        "userId": userId,
        "deletedByUserId": deletedByUserId,
      });

      print("📤 DeleteUser Body: $body");

      final response = await http.delete(
        Uri.parse("http://197.134.252.181/StockGuideAPI/User/DeleteUser"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        if (resBody['status'] == 1) {
          setState(() {
            _users.removeWhere((u) => u['userId'] == userId);
          });
          await showMessageDialog("✅ تم حذف المستخدم بنجاح");
        } else {
          await showMessageDialog("❌ فشل الحذف: ${resBody['message']}");
        }
      } else {
        await showMessageDialog("❌ فشل الحذف (كود: ${response.statusCode})");
      }
    } catch (e) {
      await showMessageDialog("⚠️ خطأ أثناء الحذف: $e");
    }
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  Future<void> fetchFeeSettings() async {
    if (!await _checkInternet()) {
      await showMessageDialog("⚠️ لا يوجد اتصال بالإنترنت");
      setState(() => _isLoadingFees = false);
      return;
    }
    try {
      final response = await http.get(
        Uri.parse(
          "http://197.134.252.181/StockGuideAPI/User/GetSettingOfUserFeesInFirstTime",
        ),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as List;
        _feeOptions = data.map((e) => UserFeeSetting.fromJson(e)).toList();

        setState(() {
          _isLoadingFees = false;
          _selectedFee = _feeOptions.first;
        });
      } else {
        throw Exception("Failed to load fee settings");
      }
    } catch (e) {
      setState(() => _isLoadingFees = false);
      await showMessageDialog("حدث خطأ أثناء تحميل الاشتراكات: $e");
    }
  }

  int calculateTotalFees() {
    int total = 0;
    for (var user in _users) {
      if (user['checked'] == true) {
        total += (user['fees'] as num).toInt();
      }
    }
    return total;
  }

  Future<void> _uploadReceipt() async {
    if (!await _checkInternet()) {
      await showMessageDialog("⚠️ لا يوجد اتصال بالإنترنت");
      return;
    }

    final selectedUsers = _users.where((u) => u['checked'] == true).toList();

    if (selectedUsers.isEmpty) {
      await showMessageDialog("يرجى اختيار مستخدم واحد على الأقل");
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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

    if (confirm != true) {
      return;
    }

    late Uri uri;
    var request = http.MultipartRequest("POST", Uri());

    uri = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Files/UploadSubscriptionGroupForUsers",
    );
    request = http.MultipartRequest("POST", uri);

    for (var branch in selectedUsers) {
      request.fields.putIfAbsent(
        'SubscribtionUserIds[${selectedUsers.indexOf(branch)}]',
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
        await showMessageDialog("تم رفع الإيصال بنجاح ✅");
        setState(() {
          _users.forEach((u) => u['checked'] = false);
        });
      } else {
        await showMessageDialog(
          "فشل رفع الإيصال ❌ (كود: ${response.statusCode})",
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      await showMessageDialog("حدث خطأ أثناء رفع الإيصال: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFeeSettings();
    fetchUnpaidUsers(widget.companyId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey)),
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
                await _uploadReceipt();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              label: Text(
                'ارفاق ايصال الدفع',
                style: GoogleFonts.tajawal(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoadingFees
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => fetchUnpaidUsers(widget.companyId),
              child: SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          'الموبايلات التابعة لـ: ${widget.companyName}',
                          style: GoogleFonts.tajawal(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextField(
                        controller: nameController,
                        style: GoogleFonts.tajawal(fontSize: 14),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          hintText: 'الاسم',
                          hintStyle: GoogleFonts.tajawal(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.tajawal(fontSize: 14),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          hintText: 'رقم الموبايل',
                          hintStyle: GoogleFonts.tajawal(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        style: GoogleFonts.tajawal(fontSize: 14),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          hintText: 'كلمة المرور',
                          hintStyle: GoogleFonts.tajawal(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              size: 18,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

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
                                  horizontal: 3,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blue.shade50
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade400,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      label,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 13,
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
                                        fontSize: 12,
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
                      const SizedBox(height: 18),

                      CheckboxListTile(
                        value: _agreeToTerms,
                        onChanged: (val) =>
                            setState(() => _agreeToTerms = val ?? false),
                        dense: true,
                        activeColor: Colors.blue,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'يسمح له بانشاء فرع',
                          style: GoogleFonts.tajawal(fontSize: 14),
                        ),
                      ),
                      CheckboxListTile(
                        value: _agreeToPrivacy,
                        onChanged: (val) =>
                            setState(() => _agreeToPrivacy = val ?? false),
                        dense: true,
                        activeColor: Colors.blue,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'يسمح له بانشاء موبايل',
                          style: GoogleFonts.tajawal(fontSize: 14),
                        ),
                      ),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () async {
                          if (!await _checkInternet()) {
                            await showMessageDialog(
                              "⚠️ لا يوجد اتصال بالإنترنت",
                            );
                            return;
                          }
                          final name = nameController.text.trim();
                          final mobile = phoneController.text.trim();
                          final password = passwordController.text.trim();

                          if (name.isEmpty ||
                              mobile.isEmpty ||
                              password.isEmpty) {
                            await showMessageDialog(
                              'من فضلك ادخل الاسم ورقم الموبايل وكلمة المرور',
                            );
                            return;
                          }

                          final prefs = await SharedPreferences.getInstance();
                          final currentUserId = prefs.getString('userId');

                          if (currentUserId == null || currentUserId.isEmpty) {
                            await showMessageDialog('فشل في جلب معرف المستخدم');
                            return;
                          }

                          final Map<String, dynamic> body = {
                            "companyId": widget.companyId,
                            "userId": _isEditing ? _editingUserId : "",
                            "updatedByUserId": currentUserId,
                            "userName": name,
                            "mobileNo": mobile,
                            "noMonth": _selectedFee?.noMonths ?? 0,
                            "fees": _selectedFee?.fees ?? 0,
                          };

                          try {
                            final response = await (_isEditing
                                ? http.put(
                                    Uri.parse(
                                      "http://197.134.252.181/StockGuideAPI/User/UpdateUserInRenew",
                                    ),
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                    body: jsonEncode(body),
                                  )
                                : http.post(
                                    Uri.parse(
                                      "http://197.134.252.181/StockGuideAPI/User/CreateUserForTheFirstTime",
                                    ),
                                    headers: {
                                      'Content-Type': 'application/json',
                                    },
                                    body: jsonEncode({
                                      "userName": name,
                                      "password": password,
                                      "mobileNo": mobile,
                                      "companyId": widget.companyId,
                                      "fromUserId": currentUserId,
                                      "hasRightToInsertBranch": _agreeToTerms,
                                      "hasRightToInsertUsers": _agreeToPrivacy,
                                      "noMonth": _selectedFee?.noMonths ?? 0,
                                      "fees": _selectedFee?.fees ?? 0,
                                    }),
                                  ));

                            if (response.statusCode == 200) {
                              final resBody = jsonDecode(response.body);

                              if (resBody['status'] == 1) {
                                if (_isEditing) {
                                  await showMessageDialog(
                                    "✅ تم تحديث المستخدم بنجاح",
                                  );
                                  setState(() {
                                    final index = _users.indexWhere(
                                      (u) => u['userId'] == _editingUserId,
                                    );
                                    if (index != -1) {
                                      _users[index]['name'] = name;
                                      _users[index]['mobile'] = mobile;
                                      _users[index]['noMonth'] =
                                          _selectedFee?.noMonths ?? 0;
                                      _users[index]['fees'] =
                                          _selectedFee?.fees ?? 0;
                                    }
                                    _isEditing = false;
                                    _editingUserId = null;
                                  });
                                } else {
                                  await showMessageDialog(
                                    "✅ تم إضافة المستخدم بنجاح",
                                  );
                                  setState(() {
                                    _users.add({
                                      'userId':
                                          resBody['data']?['userId'] ?? "",
                                      'name': name,
                                      'mobile': mobile,
                                      'password': password,
                                      'amount':
                                          '${_selectedFee?.fees?.toInt() ?? 0} ج.م',
                                      'checked': true,
                                      'noMonth': _selectedFee?.noMonths ?? 0,
                                      'fees': _selectedFee?.fees ?? 0,
                                      'hasRightToInsertBranch': _agreeToTerms,
                                      'hasRightToInsertUsers': _agreeToPrivacy,
                                    });
                                  });
                                }

                                phoneController.clear();
                                nameController.clear();
                                passwordController.clear();
                                _selectedFee = _feeOptions.first;
                                await fetchUnpaidUsers(widget.companyId);
                              } else {
                                await showMessageDialog(
                                  "❌ ${resBody['message']}",
                                );
                              }
                            } else {
                              await showMessageDialog(
                                'فشل العملية ❌ (كود: ${response.statusCode})',
                              );
                            }
                          } catch (e) {
                            await showMessageDialog("⚠️ حدث خطأ: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isEditing
                              ? Colors.orange
                              : Colors.blue,
                          minimumSize: const Size.fromHeight(42),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isEditing ? 'تحديث' : 'إضافة',
                          style: GoogleFonts.tajawal(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                _editingUserId = null;
                                nameController.clear();
                                phoneController.clear();
                                passwordController.clear();
                                _selectedFee = _feeOptions.isNotEmpty
                                    ? _feeOptions.first
                                    : null;
                                _agreeToTerms = false;
                                _agreeToPrivacy = false;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey.shade400),
                              minimumSize: const Size.fromHeight(40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'إنهاء التعديل',
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      Column(
                        children: [
                          ..._users.map((user) {
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: user['checked'] ?? false,
                                        activeColor: Colors.blue,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            user['checked'] = value ?? false;
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              user['name'] ?? '',
                                              style: GoogleFonts.tajawal(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600,
                                                color: primaryColor,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              user['mobile'] ?? '',
                                              style: GoogleFonts.tajawal(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Text(
                                                  '${(user['fees'] as num).toInt()} ج.م',
                                                  style: GoogleFonts.tajawal(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                if (user['noMonth'] != null)
                                                  Text(
                                                    '${user['noMonth']} شهر',
                                                    style: GoogleFonts.tajawal(
                                                      fontSize: 13,
                                                      color: Colors.grey[500],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blueAccent,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _isEditing = true;
                                            _editingUserId =
                                                user['userId']; // حفظ userId

                                            nameController.text =
                                                user['name'] ?? '';
                                            phoneController.text =
                                                user['mobile'] ?? '';
                                            passwordController.text =
                                                user['password'] ?? '';

                                            _selectedFee = _feeOptions
                                                .firstWhere(
                                                  (f) =>
                                                      f.noMonths ==
                                                      user['noMonth'],
                                                  orElse: () =>
                                                      _feeOptions.first,
                                                );

                                            _agreeToTerms =
                                                user['hasRightToInsertBranch'] ??
                                                false;
                                            _agreeToPrivacy =
                                                user['hasRightToInsertUsers'] ??
                                                false;
                                          });

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
                                          size: 22,
                                        ),
                                        onPressed: () async {
                                          bool?
                                          confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) {
                                              return AlertDialog(
                                                title: Text(
                                                  "تأكيد الحذف",
                                                  style: GoogleFonts.tajawal(),
                                                ),
                                                content: Text(
                                                  "هل تريد حذف المستخدم (${user['name']})؟",
                                                  style: GoogleFonts.tajawal(),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: Text(
                                                      "إلغاء",
                                                      style:
                                                          GoogleFonts.tajawal(
                                                            color: Colors.grey,
                                                          ),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                    child: Text(
                                                      "حذف",
                                                      style:
                                                          GoogleFonts.tajawal(
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirm == true) {
                                            await deleteUser(
                                              user['userId'],
                                              widget.companyId,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                  height: 1,
                                ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
