import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants.dart';

class AddBranch extends StatefulWidget {
  const AddBranch({super.key});

  @override
  State<AddBranch> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  final TextEditingController phoneController = TextEditingController();

  final List<String> _branchOptions = [
    'فرع القاهرة',
    'فرع الإسكندرية',
    'فرع الجيزة',
  ];
  String? _selectedBranch;

  String _branchType = '3 شهور';

  final List<Map<String, dynamic>> _branches = [
    {'name': 'سموحة', 'amount': '400 ج.م'},
    {'name': 'ميامي', 'amount': '210 ج.م'},
    {'name': 'دمنهور', 'amount': '420 ج.م'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: const Text('اختر الشركة'),
                  value: _selectedBranch,
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBranch = newValue;
                    });
                  },
                  items: _branchOptions
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Branch name
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'اسم الفرع',
                hintStyle: GoogleFonts.tajawal(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

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
                                fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
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

            const SizedBox(height: 25),

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
                    onPressed: () {
                      // Save logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.only(top: 20, bottom: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'أضافة',
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

            // Added branches list
            ..._branches.map((branch) {
              return Column(
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Column(
                        children: [
                          Text(branch['name']!, style: GoogleFonts.tajawal(fontSize: 25,color: primaryColor)),
                          Text(branch['amount']!, style: GoogleFonts.tajawal(fontSize: 16)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          // Edit logic here
                        },
                        icon: const Icon(Icons.edit, color: Colors.blue),
                      ),
                      IconButton(
                        onPressed: () {
                          // Delete logic here
                        },
                        icon: const Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // 👈 spacing between each branch row
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}