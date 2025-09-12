import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class StopBranch extends StatefulWidget {
  final int companyId;
  final String userId;

  const StopBranch({super.key, required this.companyId, required this.userId});

  @override
  State<StopBranch> createState() => _StopBranchState();
}

class _StopBranchState extends State<StopBranch> {
  int selectedTab = 0;
  bool isTemporaryStop = true;
  TextEditingController dateController = TextEditingController();

  List<Map<String, dynamic>> branches = [];
  String? _selectedBranch;
  bool isLoading = true;
  int? currentStatusId;
  

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    final url = Uri.parse(
        'http://197.134.252.181/StockGuideAPI/Branch/BranchGetAllByCompanyIdWithStatus?companyId=${widget.companyId}');

    final response = await http.get(url);
    
    print(response.body);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        final List<dynamic> data = decoded['data'];

        setState(() {
          branches = data
              .where((item) => item['statusId'] == 1)
              .map<Map<String, dynamic>>((item) {
            return {
              'id': item['branchId'],
              'name': item['branchName'],
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

  Future<void> editBranchStatus() async {
    if (_selectedBranch == null) {
      await showMessageDialog("برجاء اختيار فرع");
      return;
    }

    final selected = branches.firstWhere((c) => c['name'] == _selectedBranch);
    final branchId = selected['id'];
    final newStatusId = isTemporaryStop ? 3 : 2;

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
      "branchId": branchId,
      "newStatusId": newStatusId,
      "toStatusDate": toStatusDate ?? "",
      "userId": widget.userId
    });

    final response = await http.post(
      Uri.parse('http://197.134.252.181/StockGuideAPI/Branch/EditStatus'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      setState(() {
        currentStatusId = newStatusId;
        final index = branches.indexWhere((c) => c['id'] == branchId);
        if (index != -1) {
          branches[index]['statusId'] = newStatusId;
        }
      });

      await showMessageDialog('✅ تم تغيير حالة الفرع بنجاح');
    } else {
      await showMessageDialog('❌ فشل في تغيير حالة الفرع');
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
                  'إيقاف فرع',
                  style: GoogleFonts.tajawal(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.lightBlue,
                  ),
                ),
                const SizedBox(height: 20),

                // Branch Dropdown
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
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButton<String>(
                          hint: const Text('اختر الفرع'),
                          value: _selectedBranch,
                          icon: const Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedBranch = newValue;
                            });
                          },
                          items: branches.map<DropdownMenuItem<String>>((branch) {
                            return DropdownMenuItem<String>(
                              value: branch['name'],
                              child: Text(branch['name']),
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
                      buildToggleButton("إيقاف دائم", false),
                      const SizedBox(width: 10),
                      buildToggleButton("إيقاف مؤقت", true),
                    ],
                  ),
                ),

                if (isTemporaryStop)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("حتى تاريخ:", style: GoogleFonts.tajawal(fontSize: 16)),
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
                      onPressed: editBranchStatus,
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
