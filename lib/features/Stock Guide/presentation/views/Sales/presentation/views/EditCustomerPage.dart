import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditCustomerPage extends StatelessWidget {
  const EditCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: _buildEditCard(context),
        ),
      ),
    );
  }

  Widget _buildEditCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          InputRow(
            label: "الكود:",
            icon: Icons.qr_code_2,
            child: TextFormField(
              readOnly: true,
              initialValue: "845",
              decoration: _inputDecoration("الكود"),
              style: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "الاسم:",
            icon: Icons.person,
            child: TextFormField(
              initialValue: "محلات سكرين",
              decoration: _inputDecoration("اسم العميل"),
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "الموبايل:",
            icon: Icons.phone_android,
            child: TextFormField(
              keyboardType: TextInputType.phone,
              initialValue: "01033100144",
              decoration: _inputDecoration("رقم الموبايل"),
            ),
          ),
          const SizedBox(height: 14),
          InputRow(
            label: "العنوان:",
            icon: Icons.location_on,
            child: TextFormField(
              initialValue: "عمارات رامو خلف سيتي ستارز",
              decoration: _inputDecoration("العنوان"),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "تم حفظ التعديلات بنجاح ✅",
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
              label: Text(
                "حفظ التعديلات",
                style: GoogleFonts.tajawal(fontSize: 18, color: Colors.white),
              ),
            ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class InputRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget child;

  const InputRow({
    super.key,
    required this.label,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.blueAccent),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        Expanded(child: SizedBox(height: 48, child: child)),
      ],
    );
  }
}
