import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';
import '../../../login/presentation/views/loginView.dart';

class SignUpVerificationView extends StatefulWidget {
  final String userId;
  final String phoneNumber;

  const SignUpVerificationView({
    super.key,
    required this.userId,
    required this.phoneNumber,
  });

  @override
  State<SignUpVerificationView> createState() => _SignUpVerificationViewState();
}

class _SignUpVerificationViewState extends State<SignUpVerificationView> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  Future<void> _verifyCode() async {
    final code = controllers.map((c) => c.text.trim()).join();

    if (code.length != 6 || code.contains(RegExp(r'[^0-9]'))) {
      _showMessage("برجاء إدخال رمز تحقق صحيح مكون من 6 أرقام");
      return;
    }

    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/User/verifyCode",
    );

    print(widget.userId);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userId": widget.userId, "verifyCode": code}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _showMessage("تم التحقق بنجاح", success: true);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
      } else {
        _showMessage(data['message'] ?? "فشل التحقق من الكود");
      }
    } catch (e) {
      _showMessage("حدث خطأ أثناء الاتصال بالخادم");
    }
  }

  void _showMessage(String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? "نجاح" : "خطأ"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(toolbarHeight: 0, elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildTitle(),
              const SizedBox(height: 20),
              _buildSubtitle(),
              const SizedBox(height: 10),
              _buildOtpFields(),
              const SizedBox(height: 30),
              _buildVerifyButton(),
              const SizedBox(height: 16),
              _buildResendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      "ادخل الكود المرسل اليك",
      style: GoogleFonts.tajawal(
        textStyle: const TextStyle(
          color: thirdTextColor,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "تم إرسال رمز التحقق إلى الرقم",
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(
            textStyle: const TextStyle(
              color: secondaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            maskPhoneNumber(widget.phoneNumber),

            style: GoogleFonts.tajawal(
              textStyle: const TextStyle(
                color: secondaryTextColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 40,
          child: TextField(
            controller: controllers[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (val) {
              if (val.isNotEmpty && index < 5) {
                FocusScope.of(context).nextFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _verifyCode,
        child: Text(
          'تحقق',
          style: GoogleFonts.tajawal(
            textStyle: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text(
          'لم يصلك الرمز؟ أعد الإرسال',
          style: GoogleFonts.tajawal(
            textStyle: const TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

String maskPhoneNumber(String phone) {
  if (phone.length >= 9) {
    return "${phone.substring(0, 3)}******${phone.substring(phone.length - 2)}";
  }
  return phone;
}
