import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddInvoicePage extends StatelessWidget {
  const AddInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildInvoiceForm(),
              const SizedBox(height: 25),
              _buildInvoiceTable(),
              // const SizedBox(height: 25),
              // _buildSummarySection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          InputRow(
            label: "تاريخ ورقم الفاتورة:",
            icon: Icons.calendar_today,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: "2025 / 5 / 15",
                    decoration: _inputDecoration("تاريخ الفاتورة"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: "8754",
                    decoration: _inputDecoration("رقم الفاتورة"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "كود وموبايل العميل:",
            icon: Icons.person,
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: "20",
                    decoration: _inputDecoration("كود العميل"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    initialValue: "01228759432",
                    decoration: _inputDecoration("موبايل العميل"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "اسم العميل:",
            icon: Icons.remove_red_eye_outlined,
            child: TextFormField(
              readOnly: true,
              initialValue: "أحمد إبراهيم",
              decoration: _inputDecoration("اسم العميل"),
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "الباركود:",
            icon: Icons.camera_alt,
            child: TextFormField(
              initialValue: "K10",
              decoration: _inputDecoration("الباركود"),
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "اختر الصنف:",
            icon: Icons.category,
            child: DropdownButtonFormField<String>(
              decoration: _inputDecoration("اختر الصنف"),
              value: "قميص",
              items: ["قميص", "بنطال", "جاكيت"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "كود الصنف:",
            icon: Icons.qr_code,
            child: TextFormField(
              initialValue: "K10",
              decoration: _inputDecoration("كود الصنف"),
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "اختر اللون:",
            icon: Icons.color_lens,
            child: DropdownButtonFormField<String>(
              decoration: _inputDecoration("اختر اللون"),
              value: "أحمر",
              items: ["أحمر", "أزرق", "أسود"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "اختر المقاس:",
            icon: Icons.straighten,
            child: DropdownButtonFormField<String>(
              decoration: _inputDecoration("اختر المقاس"),
              value: "3XL",
              items: ["S", "M", "L", "XL", "3XL"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceTable() {
    final rows = [
      ["السعر قبل الخصم", "قيمة الخصم", "السعر بعد الخصم", "الكمية", "الإجمالي"],
      ["600", "120", "480", "2", "960"],
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      shadowColor: Colors.blueAccent.withOpacity(.15),
      child: Column(
        children: rows.map((row) {
          bool isHeader = row == rows.first;
          return Container(
            decoration: BoxDecoration(
              color: isHeader ? Colors.blue.shade100 : Colors.white,
              borderRadius: isHeader
                  ? const BorderRadius.vertical(top: Radius.circular(14))
                  : const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: row.map((cell) {
                return Expanded(
                  child: Text(
                    cell,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                      color: isHeader
                          ? Colors.blueGrey.shade800
                          : Colors.black87,
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

  Widget _buildSummarySection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("إجمالي الأصناف: 1",
                style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w600, fontSize: 16, color: Colors.red)),
            Text("إجمالي الكمية: 2",
                style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.w600, fontSize: 16, color: Colors.red)),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.yellow.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "إجمالي الفاتورة: 960 ج",
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 55,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: const CircleBorder(),
              elevation: 5,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "تم حفظ الفاتورة بنجاح ✅",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.tajawal(fontSize: 16),
                  ),
                  backgroundColor: Colors.green.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Icon(Icons.save, size: 28, color: Colors.white),
          ),
        ),
      ],
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
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}

class InputRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const InputRow({super.key, required this.label, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.blueAccent),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: Text(label,
              style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w600, fontSize: 15)),
        ),
        Expanded(child: SizedBox(height: 48, child: child)),
      ],
    );
  }
}

class DottedInputRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const DottedInputRow({super.key, required this.label, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, style: BorderStyle.solid, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(6),
      child: InputRow(label: label, icon: icon, child: child),
    );
  }
}
