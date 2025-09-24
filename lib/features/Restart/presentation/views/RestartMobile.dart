import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class RestartMobile extends StatefulWidget {
  final int companyId;
  final String userId;
  const RestartMobile({super.key, required this.companyId, required this.userId});

  @override
  State<RestartMobile> createState() => _RestartMobileState();
}

class _RestartMobileState extends State<RestartMobile> {
  int selectedTab = 0;
  bool isTemporaryStop = true;
  TextEditingController dateController = TextEditingController();

  List<Map<String, dynamic>> mobiles = [];
  String? _selectedMobile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMobiles();
  }

  Future<void> fetchMobiles() async {
    final url = Uri.parse(
        'http://197.134.252.181/StockGuideAPI/User/UserGetAllByCompanyIdWithStatus?companyId=${widget.companyId}');

    final response = await http.get(url);

    print(response.body);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        final List<dynamic> data = decoded['data'];

        setState(() {
          mobiles = data
              .where((item) => item['statusId'] == 2 || item['statusId'] == 3)
              .map<Map<String, dynamic>>((item) {
            return {
              'id': item['userId'],
              'name': item['mobileNO'],
              'statusId': item['statusId'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to fetch branches');
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


  Future<void> editUserStatus() async {
    if (_selectedMobile == null) {
      await showMessageDialog("برجاء اختيار رقم الموبايل");
      return;
    }

    final newStatusId = 1;

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

    final selectedUser = mobiles.firstWhere(
          (m) => m["name"] == _selectedMobile,
      orElse: () => {},
    );

    print("/*/*");
    print(selectedUser);
    final String selectedUserId = selectedUser["id"].toString();

    final body = json.encode({
      "userId": selectedUserId,
      "companyId": widget.companyId,
      "newStatusId": newStatusId,
      "toStatusDate": toStatusDate ?? "",
      "fromUserId": widget.userId,
    });

    final response = await http.post(
      Uri.parse('http://197.134.252.181/StockGuideAPI/User/EditUserStatus'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      await showMessageDialog('✅ تم تغيير حالة الموبايل بنجاح');
    } else {
      await showMessageDialog('❌ فشل في تغيير حالة الموبايل');
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
                  'اعادة تشغيل موبايل',
                  style: GoogleFonts.tajawal(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                const SizedBox(height: 20),

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
                        child: DropdownButton<String>(
                          hint: const Text('اختر الموبايل'),
                          value: _selectedMobile,
                          icon: const Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMobile = newValue;
                            });
                          },
                          items: mobiles.map<DropdownMenuItem<String>>((mobile) {
                            final String name = mobile["name"]?.toString() ?? "";
                            print(name);
                            return DropdownMenuItem<String>(
                              value: name,
                              child: Text(name.isNotEmpty ? name : "غير معروف"),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: buildToggleButton("اعادة تشغيل دائم", false),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: buildToggleButton("اعادة تشغيل مؤقت", true),
                      ),
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
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: Colors.lightBlue,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue),
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
                      onPressed: () {
                        if (_selectedMobile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("من فضلك اختر الموبايل")),
                          );
                          return;
                        }
                        editUserStatus();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'اعادة تشغيل',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          title,
          style: GoogleFonts.tajawal(fontSize: 12, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
        ),
      ),
    );
  }
}
