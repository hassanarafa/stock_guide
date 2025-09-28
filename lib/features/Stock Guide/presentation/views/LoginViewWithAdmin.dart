import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import 'StockGuideMainLayout.dart';

class LoginViewWithAdmin extends StatefulWidget {
  final int companyId;
  const LoginViewWithAdmin({super.key, required this.companyId});

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
          "http://197.134.252.181/StockGuideAPI/User/GetAllUsersByCompanyIdInRenew?companyId=${widget.companyId}",
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          users = jsonResponse['data']?['currentUnpaidSubscription'] ?? [];
        });
        print("Fetched users: $users");
      } else {
        print("Error fetching users: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception while fetching users: $e");
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Image.asset(
                    "assets/images/stock control logo.jpg",
                    height: 100,
                    width: 100,
                  ),

                  const SizedBox(height: 20),

                  // Instruction
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

                  // Dropdown بدل الموبايل
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: selectedUser,
                    items: users.map<DropdownMenuItem<Map<String, dynamic>>>((user) {
                      return DropdownMenuItem(
                        value: user,
                        child: Text(
                          "${user['displayName']} - ${user['mobile']}",
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

                  // Password TextField
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

                  // Login Button
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

                        print("Selected userId: ${selectedUser!['userId']}");
                        print("Selected mobile: ${selectedUser!['mobileNo']}");
                        print("Password: ${passwordController.text}");

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
      ),
    );
  }
}
