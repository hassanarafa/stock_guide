import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import 'VerificationCodeView.dart';

class ForgotPasswordView extends StatefulWidget {
  final String userId;
  const ForgotPasswordView({super.key, required this.userId});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController phoneController = TextEditingController();
  bool isLoading = false;

  Future<void> sendCode() async {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك أدخل رقم الموبايل")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
        'http://197.134.252.181/StockGuideAPI/User/SendCodeInForgetPass?MobileNoOrUserName=${phoneController.text.trim()}',
      );

      final response = await http.get(url);

      print("🔵 API URL: $url");
      print("🔵 Status: ${response.statusCode}");
      print("🔵 Response: ${response.body}");

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body["status"] == 1) {
          final data = body["data"];
          print(data["code"]);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationCodeView(
                code: data["code"],
                userId: widget.userId,
                phone: phoneController.text.trim(),
              ),
            ),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body["message"] ?? "تم إرسال الكود بنجاح")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body["message"] ?? "فشل إرسال الكود")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ في الاتصال: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("❌ Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الاتصال بالخادم: $e")),
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
                      "نسيت كلمة المرور ؟؟",
                      style: GoogleFonts.tajawal(
                        textStyle: const TextStyle(
                          color: primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Text(
                      "سيتم ارسال كود الي رقم الموبايل الخاص بك",
                      style: GoogleFonts.tajawal(
                        textStyle: const TextStyle(
                          color: thirdTextColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

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
                      onPressed: isLoading ? null : sendCode,
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'إرسال',
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
