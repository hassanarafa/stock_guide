import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../home/presentation/views/HomeViewWithComp.dart';

class Company {
  final int id;
  final String name;
  final int statusId;
  final String statusName;

  Company({
    required this.id,
    required this.name,
    required this.statusId,
    required this.statusName,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['companyId'],
      name: json['companyName'],
      statusId: json['statusId'],
      statusName: json['statusName'],
    );
  }
}

class RestartCompany extends StatefulWidget {
  final String userId;
  final int companyStatus;
  final int companyId;
  final String companyName;

  const RestartCompany({
    super.key,
    required this.userId,
    required this.companyStatus,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<RestartCompany> createState() => _RestartCompanyState();
}

class _RestartCompanyState extends State<RestartCompany> {
  bool isTemporaryRestart = true;
  TextEditingController dateController = TextEditingController();

  List<Company> companies = [];
  late int _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.companyStatus;
  }

  String getStatusLabel(int? statusId) {
    switch (statusId) {
      case 1:
        return 'نشطة';
      case 3:
        return 'إيقاف مؤقت';
      case 2:
        return 'إيقاف دائم';
      default:
        return 'غير معروف';
    }
  }

  Future<void> submitCompanyStatus() async {
    if (_currentStatus == 1) {
      await showMessageDialog(
        '⚠️ هذه الشركة نشطة بالفعل (${getStatusLabel(_currentStatus)})',
      );
      return;
    }

    String? toStatusDate;
    if (isTemporaryRestart) {
      if (dateController.text.isEmpty) {
        await showMessageDialog('يرجى تحديد التاريخ');
        return;
      }
      try {
        final parts = dateController.text.split('/');
        final pickedDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        toStatusDate = pickedDate.toIso8601String();
      } catch (e) {
        await showMessageDialog('تاريخ غير صالح');
        return;
      }
    }

    final body = json.encode({
      'companyId': widget.companyId,
      'statusId': 1,
      'toStatusDate': toStatusDate ?? '',
    });

    final response = await http.post(
      Uri.parse('http://197.134.252.181/StockGuideAPI/Company/EditStatus'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      setState(() {
        _currentStatus = 1;
        final index = companies.indexWhere((c) => c.id == widget.companyId);
        if (index != -1) {
          companies[index] = Company(
            id: companies[index].id,
            name: companies[index].name,
            statusId: 1,
            statusName: "نشط",
          );
        }
      });
      await showMessageDialog('✅ تم اعادة تشغيل الشركة بنجاح');
      Navigator.pop(context);
    } else {
      await showMessageDialog('❌ فشل في اعادة تشغيل الشركة');
    }
  }

  Future<void> showMessageDialog(String message) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(message, style: GoogleFonts.tajawal()),
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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'إعادة تشغيل شركة',
                  style: GoogleFonts.tajawal(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),

                  child: Text(
                    widget.companyName,
                    style: GoogleFonts.tajawal(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  'الحالة الحالية: ${getStatusLabel(_currentStatus)}',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildToggleButton("تشغيل دائم", false),
                      const SizedBox(width: 10),
                      buildToggleButton("تشغيل مؤقت", true),
                    ],
                  ),
                ),

                // Date input (only if temporary restart)
                if (isTemporaryRestart)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "حتى تاريخ:",
                          style: GoogleFonts.tajawal(fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: dateController,
                          decoration: InputDecoration(
                            hintText: "ادخل التاريخ",
                            hintStyle: GoogleFonts.tajawal(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.calendar_today,
                              color: Colors.lightBlue,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                dateController.text =
                                    "${picked.day}/${picked.month}/${picked.year}";
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 15),

                // Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_currentStatus == 1)
                          ? null
                          : submitCompanyStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'إعادة تشغيل',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontSize: 18,
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

  Widget buildToggleButton(String title, bool value) {
    final bool isSelected = isTemporaryRestart == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isTemporaryRestart = value;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.lightBlue : Colors.white,
          side: const BorderSide(color: Colors.lightBlue),
          foregroundColor: isSelected ? Colors.white : Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}
