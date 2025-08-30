import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants.dart';
import 'ResetPasswordView.dart';

class VerificationCodeView extends StatefulWidget {
  final String userId;
  final String code;
  final String phone;

  const VerificationCodeView({
    super.key,
    required this.code,
    required this.userId,
    required this.phone,
  });

  @override
  State<VerificationCodeView> createState() => _VerificationCodeViewState();
}

class _VerificationCodeViewState extends State<VerificationCodeView> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String getEnteredCode() {
    return controllers.map((c) => c.text.trim()).join();
  }

  String maskPhone(String phone) {
    if (phone.length < 4) return phone; // fallback for short strings
    String start = phone.substring(0, 3); // first 3 digits
    String end = phone.substring(phone.length - 2); // last 2 digits
    return "$start******$end";
  }


  void verifyCode() {
    final entered = getEnteredCode();

    if (entered.isEmpty || entered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("من فضلك أدخل الكود بالكامل")),
      );
      return;
    }

    if (entered == widget.code) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResetPasswordView(code: widget.code, userId: widget.userId),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("الكود غير صحيح")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 0,
          elevation: 0,
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                Text(
                  "ادخل الكود المرسل اليك",
                  style: GoogleFonts.tajawal(
                    textStyle: const TextStyle(
                      color: thirdTextColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
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
                          maskPhone(widget.phone),
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
                  ),
                ),

                // Code inputs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        onChanged: (val) {
                          if (val.isNotEmpty && index < 5) {
                            // ✅ last index = 5 now
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 30),

                // Verify button
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
                    onPressed: verifyCode,
                    child: Text(
                      'تحقق',
                      style: GoogleFonts.tajawal(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend code
                Center(
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("إعادة إرسال الكود...")),
                      );
                    },
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
