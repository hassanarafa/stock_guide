import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorBalancePage extends StatelessWidget {
  const VendorBalancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 25),
                _buildInputs(),
                const SizedBox(height: 30),
                _buildBalanceTableCard(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          DropdownButtonFormField<String>(
            decoration: _inputDecoration("اختر المورد"),
            items: ["محلات سكريم", "المخزن الرئيسي", "فرع فيصل"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {},
          ),
          const SizedBox(height: 18),

          TextFormField(
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration("الموبايل"),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _inputDecoration("كود المورد"),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildBalanceTableCard() {
    final rows = [
      ["الرصيد", "157,550 ج"],
      ["قيمة آخر دفعة", "15,500 ج"],
      ["تاريخ الدفعة", "2025-5-22"],
      ["ملاحظة الدفعة", "نهائي شتاء 2025"],
      ["ملاحظة المورد", "ملتزم في المواعيد"],
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.blueAccent.withOpacity(.2),
      child: Column(
        children: rows.asMap().entries.map((entry) {
          int index = entry.key;
          var row = entry.value;

          return Container(
            padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              color: index.isEven
                  ? Colors.blue.shade50.withOpacity(.15)
                  : Colors.white,
              borderRadius: index == 0
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : index == rows.length - 1
                  ? const BorderRadius.vertical(
                  bottom: Radius.circular(16))
                  : BorderRadius.zero,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row[0],
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row[1],
                    textAlign: TextAlign.left,
                    style: GoogleFonts.tajawal(fontSize: 16),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
