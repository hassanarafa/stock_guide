import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';

class UserFeeSetting {
  final int id;
  final int noMonths;
  final double fees;

  UserFeeSetting({
    required this.id,
    required this.noMonths,
    required this.fees,
  });

  factory UserFeeSetting.fromJson(Map<String, dynamic> json) {
    return UserFeeSetting(
      id: json['id'],
      noMonths: json['noMonths'],
      fees: json['fees'].toDouble(),
    );
  }
}

class AddMobile extends StatefulWidget {
  final String companyName;
  final int companyId;
  const AddMobile({super.key,required this.companyName, required this.companyId});

  @override
  State<AddMobile> createState() => _AddMobileState();
}

class _AddMobileState extends State<AddMobile> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late List<Map<String, dynamic>> _users = [];

  List<UserFeeSetting> _feeOptions = [];
  UserFeeSetting? _selectedFee;
  bool _isLoadingFees = true;
  List<Map<String, dynamic>> _companies = [];

  Map<String, dynamic>? _selectedCompany;

  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;

  Future<void> fetchFeeSettings() async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء تحميل الاشتراكات: $e")),
      );
    }
  }


  Future<void> fetchCompanies() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في جلب معرف المستخدم')),
        );
      }
      return;
    }

    final url = Uri.parse(
      'http://197.134.252.181/StockGuideAPI/Company/GetAllByUser?userId=$userId',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _companies = (data['data'] as List)
              .map(
                (company) => {
              'companyId': company['companyId'],
              'companyName': company['companyName'],
            },
          )
              .toList();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('فشل في تحميل الشركات')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء جلب الشركات: $e')),
        );
      }
    }
  }

  int calculateTotalFees() {
    int total = 0;
    for (var user in _users) {
      if (user['checked'] == true) {
        final amountString =
        user['amount'].toString().replaceAll(' ج.م', '').trim();
        final amount = int.tryParse(amountString) ?? 0;
        total += amount;
      }
    }
    return total;
  }

  Future<void> _uploadReceipt() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("لم يتم اختيار ملف 📄")),
          );
        }
        return;
      }

      File file = File(result.files.single.path!);

      var uri = Uri.parse(
          "http://197.134.252.181/StockGuideAPI/Files/UploadSubscriptionFile");

      var request = http.MultipartRequest("POST", uri);
      request.fields['SubscriptionBranchId'] =
          _selectedFee?.id.toString() ?? "0"; // ✅ كنت حاطط _selectedFee?['id'] وهذي غلط لأنها Object مش Map
      request.fields['SubscriptionUserId'] = "123"; // يفضل تجيب userId من SharedPreferences بدل ما تثبتها
      request.files.add(await http.MultipartFile.fromPath('File', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم رفع الإيصال بنجاح ✅")),
          );
        }

        // ✅ نفرغ المستخدمين والإجمالي مباشرة بعد الرفع
        setState(() {
          _users = [];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("فشل رفع الإيصال ❌ (كود: ${response.statusCode})"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } on SocketException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("لا يوجد اتصال بالإنترنت ❌"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on HttpException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("حدث خطأ في السيرفر ❌"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FormatException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("خطأ في صيغة البيانات المستلمة ❌"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("حدث خطأ غير متوقع: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompanies();
    fetchFeeSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Colors.grey)),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoadingFees
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 70, left: 16,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dropdown
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

              // Name field
              TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'الاسم',
                  hintStyle: GoogleFonts.tajawal(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Phone field
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'رقم الهاتف',
                  hintStyle: GoogleFonts.tajawal(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'كلمة المرور',
                  hintStyle: GoogleFonts.tajawal(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: const Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 20),

              // Duration options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _feeOptions.map((option) {
                  final label = '${option.noMonths} شهور';
                  final price = '(${option.fees.toStringAsFixed(0)} جم)';
                  final isSelected = _selectedFee?.id == option.id;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFee = option);
                      },
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
                              label,
                              style: GoogleFonts.tajawal(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                            Text(
                              price,
                              style: GoogleFonts.tajawal(
                                fontSize: 14,
                                color: isSelected ? Colors.blue : Colors.black,
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

              // Checkboxes
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                        color: Colors.blue.shade50.withOpacity(0.3),
                      ),
                      child: CheckboxListTile(
                        value: _agreeToTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        activeColor: Colors.blue,
                        title: Text(
                          'يسمح له بانشاء فرع',
                          style: GoogleFonts.tajawal(fontSize: 18),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                        color: Colors.blue.shade50.withOpacity(0.3),
                      ),
                      child: CheckboxListTile(
                        value: _agreeToPrivacy,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreeToPrivacy = value ?? false;
                          });
                        },
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        activeColor: Colors.blue,
                        title: Text(
                          'يسمح له بانشاء موبايل',
                          style: GoogleFonts.tajawal(fontSize: 18),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Add Button
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = prefs.getString('userId');
                  final name = nameController.text.trim();
                  final mobile = phoneController.text.trim();

                  if (userId == null || userId.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('فشل في جلب معرف المستخدم')),
                      );
                    }
                    return;
                  }

                  // ✅ Prevent duplicate mobiles
                  bool alreadyExists = _users.any((u) => u['mobile'] == mobile);
                  if (alreadyExists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('هذا الرقم تمت إضافته بالفعل'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final String url =
                      'http://197.134.252.181/StockGuideAPI/User/CreateUserForTheFirstTime';

                  final Map<String, dynamic> body = {
                    "userName": nameController.text,
                    "password": passwordController.text,
                    "mobileNo": mobile,
                    "companyId": widget.companyId,
                    "fromUserId": userId,
                    "hasRightToInsertBranch": _agreeToTerms,
                    "hasRightToInsertUsers": _agreeToPrivacy,
                    "noMonth": _selectedFee?.noMonths ?? 0,
                    "fees": _selectedFee?.fees ?? 0,
                  };

                  try {
                    final response = await http.post(
                      Uri.parse(url),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode(body),
                    );

                    print(response.body);

                    if (response.statusCode == 200) {
                      setState(() {
                        _users.add({
                          'name': name,
                          'mobile': mobile, // ✅ Save mobile for duplicate check
                          'amount': '${_selectedFee?.fees?.toInt() ?? 0} ج.م',
                          'checked': true,
                        });
                        phoneController.clear();
                        _selectedFee = _feeOptions.first;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إضافة المستخدم بنجاح'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('فشل في الإضافة: ${response.statusCode}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('حدث خطأ: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.only(top: 20, bottom: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size.fromHeight(55),
                ),
                child: Text(
                  'أضافة',
                  style: GoogleFonts.tajawal(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Added mobiles
              ..._users.map((branch) {
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
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              _users.remove(branch);
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
    );
  }
}
