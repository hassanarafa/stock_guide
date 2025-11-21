import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import 'StockGuideMainLayout.dart';

class LoginViewWithAdmin extends StatefulWidget {
  final int companyId;
  final int branchId;
  final String companyName;
  final String branchName;

  const LoginViewWithAdmin({
    super.key,
    required this.companyId,
    required this.branchId,
    required this.companyName,
    required this.branchName,
  });

  @override
  State<LoginViewWithAdmin> createState() => _LoginViewWithAdminState();
}

class _LoginViewWithAdminState extends State<LoginViewWithAdmin> {
  final TextEditingController passwordController = TextEditingController();

  List<dynamic> users = [];
  Map<String, dynamic>? selectedUser;
  bool isLoading = false;
  bool _isObscured = true; // 👁️ password visibility control

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://197.134.252.181/StockGuideAPI/StockControlUsers/returnBranchStockUsers?branchId=${widget.branchId}",
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          users = jsonResponse;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل في تحميل المستخدمين: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء تحميل المستخدمين: $e")),
      );
    }
  }

  Future<void> validateUser() async {
    if (selectedUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك اختر مستخدم")),
      );
      return;
    }

    if (passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك أدخل كلمة المرور")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
          "http://197.134.252.181/StockGuideAPI/StockControlUsers/validateBranchUser",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "branchId": widget.branchId,
          "secId": selectedUser!['id'],
          "password": passwordController.text.trim(),
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['isValid'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StockGuideMainLayout(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("كلمة المرور غير صحيحة ❌"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل تسجيل الدخول")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ أثناء تسجيل الدخول: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: Container(
          height: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.blue, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Display Company and Branch Names
                  Text(
                    'الشركة: ${widget.companyName}',
                    style: GoogleFonts.tajawal(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الفرع: ${widget.branchName}',
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Image.asset(
                    "assets/images/stock control logo.jpg",
                    height: 150,
                    width: 150,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "من فضلك اختر المستخدم وأدخل كلمة المرور",
                    style: GoogleFonts.tajawal(
                      textStyle: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 22,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: selectedUser,
                    items: users
                        .map<DropdownMenuItem<Map<String, dynamic>>>((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(
                          user['name'] ?? '',
                          style: GoogleFonts.tajawal(),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUser = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "اختر المستخدم",
                      hintStyle: GoogleFonts.tajawal(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 🔒 Password Field with Eye Icon
                  TextField(
                    controller: passwordController,
                    obscureText: _isObscured,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور',
                      hintStyle: GoogleFonts.tajawal(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscured = !_isObscured;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoading ? null : validateUser,
                      child: isLoading
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        'تسجيل الدخول',
                        style: GoogleFonts.tajawal(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
