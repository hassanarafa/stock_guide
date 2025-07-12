import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../constants.dart';

class PartClothesPage extends StatelessWidget {
  const PartClothesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          toolbarHeight: 0,
        ),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Text(
                    "قطعة محددة",
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
                  _buildInputs(),
                  const SizedBox(height: 20),
                  _buildInventoryCards(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputs() {
    return Column(
      children: [
        InputRow(
          label: "أختر المخزن",
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration("اختر اسم المخزن"),
            items: [
              "المخزن 1",
              "المخزن 2",
              "المخزن 3",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {},
          ),
        ),
        const SizedBox(height: 15),
        InputRow(
          label: "الباركود",
          child: TextFormField(
            decoration: _inputDecoration(
              "الباركود",
            ).copyWith(prefixIcon: const Icon(Icons.photo_camera_outlined)),
          ),
        ),
        const SizedBox(height: 15),
        InputRow(
          label: "أختر الصنف",
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration("اختر اسم الصنف"),
            items: [
              "الصنف 1",
              "الصنف 2",
              "الصنف 3",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {},
          ),
        ),
        const SizedBox(height: 15),
        InputRow(
          label: "كود الصنف",
          child: TextFormField(decoration: _inputDecoration("اكتب كود االصنف")),
        ),
        const SizedBox(height: 15),
        InputRow(
          label: "أختر اللون",
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration("اختر اسم اللون"),
            items: [
              "اللون 1",
              "اللون 2",
              "اللون 3",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {},
          ),
        ),
        const SizedBox(height: 15),
        InputRow(
          label: "أختر المقاس",
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration("اختر اسم المقاس"),
            items: [
              "المقاس 1",
              "المقاس 2",
              "المقاس 3",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (value) {},
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "بحث",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCards() {
    final rows = [
      ["أبيض", "L", "3", "1", "2"],
      ["أبيض", "XL", "2", "0", "2"],
      ["أحمر", "XL", "1", "0", "1"],
      ["أحمر", "3XL", "2", "0", "2"],
      ["أسود", "M", "1", "0", "1"],
      ["أسود", "XL", "2", "1", "1"],
    ];

    return Column(
      children: rows.map((row) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfo("اللون", row[0]),
                _buildInfo("المقاس", row[1]),
                _buildInfo("الرصيد", row[2]),
                _buildInfo("الحجز", row[3]),
                _buildInfo("الباقي", row[4]),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }
}

class InputRow extends StatelessWidget {
  final String label;
  final Widget child;

  const InputRow({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: SizedBox(height: 50, child: child)),
        ],
      ),
    );
  }
}
