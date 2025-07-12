import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';
import '../../../../core/utils/assets.dart';
import '../../../home/presentation/views/HomeViewWithComp.dart';
import '../../../signup/presentation/views/signup.dart';
import 'forgetPassword.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordView(),
                          ),
                        );
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

                        if (phone.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('الرجاء إدخال رقم الموبايل وكلمة المرور'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final Uri url = Uri.parse('http://197.134.252.181/StockGuideAPI/User/login');
                        final Map<String, dynamic> body = {
                          "userName": phone,
                          "password": password,
                        };

                        try {
                          final response = await http.post(
                            url,
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode(body),
                          );

                          final jsonResponse = jsonDecode(response.body);
                          print("Login Response: $jsonResponse");

                          if (jsonResponse['status'] == 1) {
                            final String userId = jsonResponse['data']['userId'];

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('userId', userId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(jsonResponse['message'] ?? 'تم تسجيل الدخول'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const HomeWithCompanies()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(jsonResponse['returnMessage'] ?? 'فشل تسجيل الدخول'),
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
    );
  }
}
