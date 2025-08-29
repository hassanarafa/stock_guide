import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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

  const RestartCompany({super.key, required this.userId});

  @override
  State<RestartCompany> createState() => _RestartCompanyState();
}

class _RestartCompanyState extends State<RestartCompany> {
  bool isTemporaryRestart = true;
  TextEditingController dateController = TextEditingController();

  List<Company> companies = [];
  Company? _selectedCompany;

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  Future<void> fetchCompanies() async {
    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Company/GetAllByUser?userId=${widget.userId}",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> data = body['data'];
        print("/*/*");
        print(data);

        setState(() {
          companies = data
              .map((json) => Company.fromJson(json))
              .where(
                (company) => company.statusId == 2 || company.statusId == 3,
              )
              .toList();
        });
      }
    } catch (e) {
      print("Error fetching companies: $e");
    }
  }

  Future<void> submitCompanyStatus() async {
    if (_selectedCompany == null) {
      await showMessageDialog("برجاء اختيار شركة");
      return;
    }

    final companyId = _selectedCompany!.id;
    final statusId = 1;

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
      'companyId': companyId,
      'statusId': statusId,
      'toStatusDate': toStatusDate ?? '',
    });

    final response = await http.post(
      Uri.parse('http://197.134.252.181/StockGuideAPI/Company/EditStatus'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      setState(() {
        final index = companies.indexWhere((c) => c.id == companyId);
        if (index != -1) {
          companies[index] = Company(
            id: companies[index].id,
            name: companies[index].name,
            statusId: statusId,
            statusName: "نشط",
          );
        }
      });
      await showMessageDialog('✅ تم اعادة تشغيل الشركة بنجاح');
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

                // Dropdown for companies
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButton<int>(
                          value: _selectedCompany?.id,
                          hint: const Text('اختر الشركة'),
                          isExpanded: true,
                          onChanged: (int? newId) {
                            setState(() {
                              _selectedCompany = companies.firstWhere(
                                (c) => c.id == newId,
                              );
                            });
                          },
                          items: companies.map((company) {
                            return DropdownMenuItem<int>(
                              value: company.id,
                              child: Text(company.name),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Restart type toggle buttons
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
                              firstDate: DateTime(2020),
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
                      onPressed: submitCompanyStatus,
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
