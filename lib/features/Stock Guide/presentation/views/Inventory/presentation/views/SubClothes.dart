import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SubClothesPage extends StatelessWidget {
  const SubClothesPage({super.key});

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
                _buildInputs(),
                const SizedBox(height: 25),
                _buildInventoryCards(),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------- Inputs Section -----------------------
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
          ),
        ],
      ),
      child: Column(
        children: [
          // المخزن
          _fullWidthDropdownWithButton(
            label: "أختر المخزن",
            icon: Icons.store,
            hint: "أختر المخزن",
            items: ["المخزن 1", "المخزن 2", "المخزن 3"],
            onChanged: (value) {},
            buttonPressed: () {},
          ),
          const SizedBox(height: 14),

          // الصنف
          _fullWidthDropdown(
            label: "أختر الصنف",
            icon: Icons.category,
            hint: "أختر الصنف",
            items: ["الصنف 1", "الصنف 2", "الصنف 3"],
            onChanged: (value) {},
          ),
          const SizedBox(height: 14),

          // كود الصنف
          _fullWidthInputWithButton(
            label: "كود الصنف",
            icon: Icons.key,
            hint: "كود الصنف",
            buttonPressed: () {},
          ),
          const SizedBox(height: 14),

          // اللون
          _fullWidthDropdownWithButton(
            label: "أختر اللون",
            icon: Icons.color_lens,
            hint: "اختر اللون",
            items: ["اللون 1", "اللون 2", "اللون 3"],
            onChanged: (value) {},
            buttonPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _fullWidthInputWithButton({
    required String label,
    required IconData icon,
    required String hint,
    required VoidCallback buttonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: _inputDecoration(hint),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.white),
                onPressed: buttonPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullWidthDropdownWithButton({
    required String label,
    required IconData icon,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    required VoidCallback buttonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: _inputDecoration(hint),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.white),
                onPressed: buttonPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullWidthDropdown({
    required String label,
    required IconData icon,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: _inputDecoration(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ----------------------- Inventory Cards -----------------------
  Widget _buildInventoryCards() {
    final rows = [
      ["المقاس", "الرصيد", "الحجز", "الباقي"], // Header
      ["L", "3", "1", "2"],
      ["XL", "2", "0", "2"],
      ["XL", "1", "0", "1"],
      ["3XL", "2", "0", "2"],
      ["M", "1", "0", "1"],
      ["XL", "2", "1", "1"],
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.blueAccent.withOpacity(.25),
      child: Column(
        children: rows.map((row) {
          bool isHeader = row == rows.first;
          int index = rows.indexOf(row);

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: isHeader
                  ? Colors.blue.shade100.withOpacity(.45)
                  : index.isEven
                  ? Colors.blue.shade50.withOpacity(.12)
                  : Colors.white,
              borderRadius: index == 0
                  ? const BorderRadius.vertical(top: Radius.circular(16))
                  : index == rows.length - 1
                  ? const BorderRadius.vertical(bottom: Radius.circular(16))
                  : BorderRadius.zero,
            ),
            child: Row(
              children: row.map((cell) {
                return Expanded(
                  child: Text(
                    cell,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: isHeader ? 15 : 14,
                      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                      color: isHeader ? Colors.blueGrey.shade800 : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.tajawal(color: Colors.grey.shade400),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
