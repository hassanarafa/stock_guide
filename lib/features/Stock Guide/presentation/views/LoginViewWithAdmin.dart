import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import 'StockGuideMainLayout.dart';

class LoginViewWithAdmin extends StatefulWidget {
  final int companyId;
  final int branchId;
  const LoginViewWithAdmin({
    super.key,
    required this.companyId,
    required this.branchId,
  });

  @override
  State<LoginViewWithAdmin> createState() => _LoginViewWithAdminState();
}

class _LoginViewWithAdminState extends State<LoginViewWithAdmin> {
  final TextEditingController passwordController = TextEditingController();

  List<dynamic> users = [];
  Map<String, dynamic>? selectedUser;

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
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 🔹 Back Arrow Button (Top Right)
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 5),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.blue, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Image.asset(
                  "assets/images/stock control logo.jpg",
                  height: 200,
                  width: 200,
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    "من فضلك اختر المستخدم وأدخل كلمة المرور",
                    style: GoogleFonts.tajawal(
                      textStyle: const TextStyle(
                        color: primaryTextColor,
                        fontSize: 22,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<Map<String, dynamic>>(
                  value: selectedUser,
                  items:
                  users.map<DropdownMenuItem<Map<String, dynamic>>>((user) {
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

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'كلمة المرور',
                    hintStyle: GoogleFonts.tajawal(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
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
                    onPressed: () {
                      if (selectedUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("من فضلك اختر مستخدم")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StockGuideMainLayout(),
                        ),
                      );
                    },
                    child: Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
