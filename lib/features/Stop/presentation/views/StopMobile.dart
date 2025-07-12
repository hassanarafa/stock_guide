import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StopMobile extends StatefulWidget {
  const StopMobile({super.key});

  @override
  State<StopMobile> createState() => _StopMobileState();
}

class _StopMobileState extends State<StopMobile> {
  int selectedTab = 0;
  String? selectedMobile = "01010101010";
  bool isTemporaryStop = true;
  TextEditingController dateController = TextEditingController();

  final List<String> mobiles = ["01010101010", "01010101011", "01010101012"];

  String? _selectedMobile;

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
                  'إيقاف هاتف',
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
                        child: DropdownButton<String>(
                          hint: const Text('اختر الهاتف'),
                          value: _selectedMobile,
                          icon: const Icon(Icons.arrow_drop_down),
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedMobile = newValue;
                            });
                          },
                          items: mobiles.map<DropdownMenuItem<String>>((
                              String value,
                              ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Stop type toggle buttons
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
                // Date input (only if temporary stop)
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
                      onPressed: () {
                        // Handle stop logic
                      },
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

  Widget buildTabButton(String title, int index) {
    final bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : Colors.grey,
              ),
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
          side: BorderSide(color: Colors.lightBlue),
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
