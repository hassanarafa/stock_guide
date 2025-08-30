import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import 'loginView.dart';

class ResetPasswordView extends StatefulWidget {
  final String code;
  final String userId;

  const ResetPasswordView({
    super.key,
    required this.code,
    required this.userId,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool isLoading = false;

  Future<void> resetPassword() async {
    final newPassword = passwordController.text.trim();
    final confirmPassword = confirmController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك أدخل كلمة المرور")),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("كلمة المرور غير متطابقة")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse("http://197.134.252.181/StockGuideAPI/User/ResetPasswordWithCode");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "senderCodeInForgetPass": widget.code,
          "newPassword": newPassword,
          "userId": widget.userId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["status"] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "تم تغيير كلمة المرور بنجاح")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "فشل تغيير كلمة المرور")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e")),
      );
    } finally {
      setState(() => isLoading = false);
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
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      "اعد ادخال كلمة المرور",
                      style: GoogleFonts.tajawal(
                        textStyle: const TextStyle(
                          color: thirdTextColor,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // New password
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور الجديدة',
                      hintStyle: GoogleFonts.tajawal(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Confirm password
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'تأكيد كلمة المرور',
                      hintStyle: GoogleFonts.tajawal(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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
                      onPressed: isLoading ? null : resetPassword,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'حفظ',
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
