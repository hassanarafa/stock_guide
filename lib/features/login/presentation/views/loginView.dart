import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';
import '../../../../core/utils/assets.dart';
import '../../../home/presentation/views/HomeView.dart';
import '../../../home/presentation/views/HomeViewWithComp.dart';
import '../../../signup/presentation/views/signup.dart';
import 'forgetPassword.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        "تسجيل الدخول",
                        style: GoogleFonts.tajawal(
                          textStyle: const TextStyle(
                            color: thirdTextColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: Text(
                        "مرحبا بعودتك مرة أخرى ،،،",
                        style: GoogleFonts.tajawal(
                          textStyle: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Image
                    Center(
                      child: Image.asset(
                        AssetsDAta.login,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Instruction
                    Center(
                      child: Text(
                        "من فضلك قم بإدخال رقم الموبايل وكلمة المرور",
                        style: GoogleFonts.tajawal(
                          textStyle: const TextStyle(
                            color: primaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Phone TextField
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'رقم الموبايل',
                        hintStyle: GoogleFonts.tajawal(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Password TextField with Eye
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور',
                        hintStyle: GoogleFonts.tajawal(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Forgot Password
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        onPressed: () async {
                          final String phone = phoneController.text.trim();
                          final String password = passwordController.text;

                          if (phone.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الرجاء إدخال رقم الموبايل وكلمة المرور'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // ✅ تحقق من الإنترنت قبل أي حاجة
                          if (!await _checkInternet()) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ لا يوجد اتصال بالإنترنت'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final Uri loginUrl = Uri.parse(
                            'http://197.134.252.181/StockGuideAPI/User/login',
                          );
                          final Map<String, dynamic> loginBody = {
                            "userName": phone,
                            "password": password,
                          };

                          try {
                            final loginResponse = await http.post(
                              loginUrl,
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode(loginBody),
                            );

                            final loginJson = jsonDecode(loginResponse.body);
                            print("Login Response: $loginJson");

                            if (loginJson['status'] == 1) {
                              final String userId = loginJson['data']['userId'];

                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('userId', userId);

                              if (!await _checkInternet()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚠️ انقطع الاتصال أثناء تحميل الشركات'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final companyUrl = Uri.parse(
                                'http://197.134.252.181/StockGuideAPI/Company/GetAllByUser?userId=$userId',
                              );

                              final companyResponse = await http.get(companyUrl);
                              final companyJson = jsonDecode(companyResponse.body);

                              print("Company Response: $companyJson");

                              if (companyJson['status'] == 1 &&
                                  companyJson['data'] != null &&
                                  companyJson['data'].isNotEmpty) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomeWithCompanies(userId: userId),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeView(),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    loginJson['returnMessage'] ?? 'فشل تسجيل الدخول',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            print("Login Error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء الاتصال بقاعدة البيانات'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'نسيت كلمة السر؟',
                          style: GoogleFonts.tajawal(
                            textStyle: const TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

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
                        onPressed: () async {
                          final String phone = phoneController.text.trim();
                          final String password = passwordController.text;

                          // ✅ تحقق من الحقول الفارغة
                          if (phone.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('الرجاء إدخال رقم الموبايل وكلمة المرور'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final arabicRegex = RegExp(r'[\u0600-\u06FF\u0660-\u0669]');

                          if (arabicRegex.hasMatch(password)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('كلمة المرور يجب أن تحتوي على أحرف وأرقام إنجليزية فقط ❌'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final Uri loginUrl = Uri.parse(
                            'http://197.134.252.181/StockGuideAPI/User/login',
                          );
                          final Map<String, dynamic> loginBody = {
                            "userName": phone,
                            "password": password,
                          };

                          try {
                            final loginResponse = await http.post(
                              loginUrl,
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode(loginBody),
                            );

                            final loginJson = jsonDecode(loginResponse.body);
                            print("Login Response: $loginJson");

                            if (loginJson['status'] == 1) {
                              final String userId = loginJson['data']['userId'];

                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('userId', userId);

                              // ✅ Fetch companies
                              final companyUrl = Uri.parse(
                                'http://197.134.252.181/StockGuideAPI/Company/GetAllByUser?userId=$userId',
                              );

                              final companyResponse = await http.get(companyUrl);
                              final companyJson = jsonDecode(companyResponse.body);

                              print("Company Response: $companyJson");

                              if (companyJson['status'] == 1 &&
                                  companyJson['data'] != null &&
                                  companyJson['data'].isNotEmpty) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HomeWithCompanies(userId: userId),
                                  ),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeView(),
                                  ),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    loginJson['returnMessage'] ?? 'فشل تسجيل الدخول',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            print("Login Error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء الاتصال بالخادم'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
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

                    const SizedBox(height: 12),

                    // Register Prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟',
                          style: GoogleFonts.tajawal(
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpView(),
                              ),
                            );
                          },
                          child: Text(
                            'سجل الآن',
                            style: GoogleFonts.tajawal(
                              textStyle: const TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
