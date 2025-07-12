import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_guide/constants.dart';

import '../../../CompanyPages/presentation/views/MainLayout.dart';
import '../../../Stock Guide/presentation/views/LoginViewWithAdmin.dart';

class HomeWithCompanies extends StatefulWidget {
  const HomeWithCompanies({super.key});

  @override
  State<HomeWithCompanies> createState() => _HomeWithCompaniesState();
}

class _HomeWithCompaniesState extends State<HomeWithCompanies> {
  String? selectedOption1;
  String? selectedOption2;

  final List<String> options1 = ['شركة 1', 'شركة 2', 'شركة 3'];
  final List<String> options2 = ['فرع A', 'فرع B', 'فرع C'];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('اختر شركتك', style: GoogleFonts.tajawal()),
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اختر الشركة:', style: GoogleFonts.tajawal(fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedOption1,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: options1
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, style: GoogleFonts.tajawal()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedOption1 = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text('اختر القرع:', style: GoogleFonts.tajawal(fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedOption2,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: options2
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item, style: GoogleFonts.tajawal()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedOption2 = value;
                    });
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (selectedOption1 != null && selectedOption2 != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginViewWithAdmin(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'يرجى اختيار جميع القيم',
                              style: GoogleFonts.tajawal(),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'بحث',
                      style: GoogleFonts.tajawal(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (selectedOption1 != null && selectedOption2 != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainLayout(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'يرجى اختيار جميع القيم',
                              style: GoogleFonts.tajawal(),
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'انشاء شركة جديدة',
                      style: GoogleFonts.tajawal(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
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
}
