import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants.dart';

class RenewMobile extends StatefulWidget {
  const RenewMobile({super.key});

  @override
  State<RenewMobile> createState() => _RenewMobileState();
}

class _RenewMobileState extends State<RenewMobile> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final List<String> _mobileOptions = ["01010101010", "01010101011", "01010101012"];
  String? _selectedBranch;

  String _branchType = '01010101010';

  bool _agreeToTerms = false;
  bool _agreeToPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'تجديد موبايل',
                style: GoogleFonts.tajawal(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
              const SizedBox(height: 12),
              // Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: const Text('اختر الموبايل'),
                    value: _selectedBranch,
                    icon: const Icon(Icons.arrow_drop_down),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBranch = newValue;
                      });
                    },
                    items: _mobileOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Duration options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  {'label': '3 شهور', 'price': '(200 جم)'},
                  {'label': '6 شهور', 'price': '(350 جم)'},
                  {'label': '12 شهر', 'price': '(600 جم)'},
                ].map((option) {
                  final isSelected = _branchType == option['label'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _branchType = option['label']!;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade50 : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey.shade400,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                option['label']!,
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                              Text(
                                option['price']!,
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  color: isSelected ? Colors.blue : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 15),

              // Checkboxes
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                        color: Colors.blue.shade50.withOpacity(0.3),
                      ),
                      child: CheckboxListTile(
                        value: _agreeToTerms,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreeToTerms = value ?? false;
                          });
                        },
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        activeColor: Colors.blue,
                        title: Text(
                          'يسمح له بانشاء فرع',
                          style: GoogleFonts.tajawal(fontSize: 18),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                        color: Colors.blue.shade50.withOpacity(0.3),
                      ),
                      child: CheckboxListTile(
                        value: _agreeToPrivacy,
                        onChanged: (bool? value) {
                          setState(() {
                            _agreeToPrivacy = value ?? false;
                          });
                        },
                        checkboxShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        activeColor: Colors.blue,
                        title: Text(
                          'يسمح له بانشاء موبايل',
                          style: GoogleFonts.tajawal(fontSize: 18),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Total
              Text(
                "الاجمالي: 400 ج.م",
                style: GoogleFonts.tajawal(
                  textStyle: const TextStyle(
                    color: primaryTextColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: (_agreeToTerms || _agreeToPrivacy)
                          ? () {
                        // Save logic
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.only(top: 20, bottom: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'تجديد',
                        style: GoogleFonts.tajawal(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Upload receipt logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 17.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'ارفاق ايصال الدفع',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

            ],
          ),
        ),
      ),
    );
  }
}
