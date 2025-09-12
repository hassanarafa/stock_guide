import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class StopCompany extends StatefulWidget {
  final String userId;
  final String companyName;
  final int companyId;
  final int companyStatus;

  const StopCompany({
    super.key,
    required this.userId,
    required this.companyName,
    required this.companyId,
    required this.companyStatus,
  });

  @override
  State<StopCompany> createState() => _StopCompanyState();
}

class _StopCompanyState extends State<StopCompany> {
  int selectedTab = 0;
  bool isTemporaryStop = true;
  TextEditingController dateController = TextEditingController();

  List<Map<String, dynamic>> companies = [];
  bool isLoading = true;
  int? currentStatusId;

  @override
  void initState() {
    super.initState();
    currentStatusId = widget.companyStatus;
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

  Future<void> showMessageDialog(String message) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'حسناً',
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  color: Colors.lightBlue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> submitCompanyStatus() async {
    if (currentStatusId == 2 || currentStatusId == 3) {
      await showMessageDialog('⚠️ هذه الشركة موقوفة بالفعل (${getStatusLabel(currentStatusId)})');
      return;
    }

    final statusId = isTemporaryStop ? 3 : 2;

    String? toStatusDate;
    if (isTemporaryStop) {
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
        currentStatusId = statusId;
        final index = companies.indexWhere((c) => c['id'] == widget.companyId);
        if (index != -1) {
          companies[index]['statusId'] = statusId;
        }
      });
      await showMessageDialog('✅ تم تغيير حالة الشركة بنجاح');
      Navigator.pop(context);
    } else {
      await showMessageDialog('❌ فشل في تغيير حالة الشركة');
    }
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
                  'إيقاف شركة',
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
                  'الحالة الحالية: ${getStatusLabel(currentStatusId)}',
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
                      buildToggleButton("إيقاف دائم", false),
                      const SizedBox(width: 10),
                      buildToggleButton("إيقاف مؤقت", true),
                    ],
                  ),
                ),

                if (isTemporaryStop)
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (currentStatusId == 2 || currentStatusId == 3)
                          ? null // 🚫 Disabled if already stopped
                          : submitCompanyStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'إيقاف',
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
    final bool isSelected = isTemporaryStop == value;
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            isTemporaryStop = value;
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
          style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
