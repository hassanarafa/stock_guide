import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../../core/utils/assets.dart';
import '../../../login/presentation/views/loginView.dart';
import 'SignupVerification.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  bool _isPasswordVisible = false;
  bool _isPasswordVisibleRepeat = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Subtitle
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        "إنشاء حساب جديد",
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
                        "قم بملء البيانات لإنشاء حسابك",
                        style: GoogleFonts.tajawal(
                          textStyle: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // Image
                    Center(
                      child: Image.asset(
                        AssetsDAta.signup,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Instruction
                    Center(
                      child: Text(
                        "انضم الينا بإستخدام رقم الموبايل",
                        style: GoogleFonts.tajawal(
                          textStyle: const TextStyle(
                            color: primaryTextColor,
                            fontSize: 25,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Username
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'اسم المستخدم',
                        hintStyle: GoogleFonts.tajawal(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Phone
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

                    // Password
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          hintText: 'كلمة السر',
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
                    ),

                    // Confirm Password
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        controller: confirmPasswordController,
                        obscureText: !_isPasswordVisibleRepeat,
                        decoration: InputDecoration(
                          hintText: 'إعادة كتابة كلمة السر',
                          hintStyle: GoogleFonts.tajawal(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisibleRepeat
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisibleRepeat = !_isPasswordVisibleRepeat;
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    // Register Button
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
                          final String name = nameController.text.trim();
                          final String phone = phoneController.text.trim();
                          final String password = passwordController.text;
                          final String confirmPassword =
                              confirmPasswordController.text;

                          if (name.isEmpty ||
                              phone.isEmpty ||
                              password.isEmpty ||
                              confirmPassword.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('الرجاء ملء جميع الحقول'),
                              ),
                            );
                            return;
                          }

                          if (password != confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('كلمتا المرور غير متطابقتين'),
                              ),
                            );
                            return;
                          }

                          final Uri url = Uri.parse(
                            'http://197.134.252.181/StockGuideAPI/User/Register',
                          );

                          final Map<String, dynamic> body = {
                            "userName": name,
                            "password": password,
                            "mobileNo": phone,
                            "confirmPassword": confirmPassword,
                          };

                          try {
                            final response = await http.post(
                              url,
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode(body),
                            );

                            final jsonResponse = jsonDecode(response.body);

                            print('Response: $jsonResponse');
                            print(jsonResponse['data']['userId']);
                            final String userId =
                                jsonResponse['data']['userId'];

                            if (jsonResponse['saveIndicator'] == 1) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    jsonResponse['returnMessage'] ??
                                        'تم التسجيل بنجاح',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignUpVerificationView(
                                    userId: userId,
                                    phoneNumber: phone,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    jsonResponse['returnMessage'] ??
                                        'فشل في التسجيل',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            print('Error: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('حدث خطأ أثناء الاتصال بالخادم'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'تسجيل حساب',
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

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟',
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
                                builder: (context) => const LoginView(),
                              ),
                            );
                          },
                          child: Text(
                            'تسجيل الدخول',
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
