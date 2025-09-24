import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../constants.dart';
import '../../../home/presentation/views/HomeViewWithComp.dart';

class AddCompany extends StatelessWidget {
  const AddCompany({super.key});

  Future<void> createCompany(BuildContext context, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User ID not found')));
      return;
    }

    final Uri url = Uri.parse(
      'http://197.134.252.181/StockGuideAPI/Company/Create',
    );
    final Map<String, dynamic> body = {"name": name, "insertedUserId": userId};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final jsonResponse = jsonDecode(response.body);
      print("Create Response: $jsonResponse");

      if (jsonResponse['status'] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(jsonResponse['message'] ?? 'تمت الإضافة بنجاح'),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => HomeWithCompanies(userId: userId)),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(jsonResponse['message'] ?? 'فشل الإضافة')),
        );
      }
    } catch (e) {
      print('Create Company Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ أثناء الاتصال بالخادم')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController companyController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'اضف شركة',
          style: GoogleFonts.tajawal(
            fontSize: 20,
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      controller: companyController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'اسم الشركة',
                        hintStyle: GoogleFonts.tajawal(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          final companyName = companyController.text.trim();
                          if (companyName.isNotEmpty) {
                            createCompany(context, companyName);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('ادخل اسم الشركة')),
                            );
                          }
                        },
                        child: Text(
                          'اضافة',
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
              const SizedBox(height: 88),
            ],
          ),
        ),
      ),
    );
  }
}
