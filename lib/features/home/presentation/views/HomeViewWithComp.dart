import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:stock_guide/constants.dart';

import '../../../Add/presentation/views/AddCompany.dart';
import '../../../CompanyPages/presentation/views/MainLayout.dart';
import '../../../Stock Guide/presentation/views/LoginViewWithAdmin.dart';
import '../../../login/presentation/views/loginView.dart';

class HomeWithCompanies extends StatefulWidget {
  final String userId;

  const HomeWithCompanies({super.key, required this.userId});

  @override
  State<HomeWithCompanies> createState() => _HomeWithCompaniesState();
}

class _HomeWithCompaniesState extends State<HomeWithCompanies> {
  List<Map<String, dynamic>> companyList = [];
  bool isLoading = true;
  Map<int, bool> adminStatusByCompany = {}; // ✅ store admin per companyId

  @override
  void initState() {
    super.initState();
    fetchCompanies();
  }

  /// ✅ Step 1: fetch user info for a given company
  Future<void> fetchUserInfo(String userId, int companyId) async {
    try {
      final url = Uri.parse(
        "http://197.134.252.181/StockGuideAPI/User/GetUserById"
        "?userId=$userId&companyId=$companyId",
      );
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data["status"] == 1 && data["data"] != null) {
        setState(() {
          adminStatusByCompany[companyId] = data["data"]["isAdmin"] ?? false;
        });
      } else {
        setState(() {
          adminStatusByCompany[companyId] = false;
        });
      }
    } catch (e) {
      print("Error fetching user info: $e");
      setState(() {
        adminStatusByCompany[companyId] = false;
      });
    }
  }

  /// ✅ Step 2: fetch all companies first
  Future<void> fetchCompanies() async {
    setState(() => isLoading = true);

    final url = Uri.parse(
      'http://197.134.252.181/StockGuideAPI/Company/GetAllByUser?userId=${widget.userId}',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 1 && data['data'] != null) {
        final companies = List<Map<String, dynamic>>.from(data['data']);
        setState(() {
          companyList = companies;
          isLoading = false;
        });

        // ✅ fetch admin status for each company
        for (var company in companies) {
          fetchUserInfo(widget.userId, company['companyId']);
        }
      } else {
        setState(() {
          companyList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching companies: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    ).then((_) => fetchCompanies());
  }

  Future<void> toggleCompanyStatus(int companyId, int statusId) async {
    try {
      final url = Uri.parse(
        "http://197.134.252.181/StockGuideAPI/Company/EditStatus",
      );
      final body = jsonEncode({
        "companyId": companyId,
        "statusId": statusId,
        "toStatusDate": '',
      });

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تحديث حالة الشركة بنجاح ✅")),
        );
        fetchCompanies();
      } else {
        throw Exception("فشل تحديث الحالة: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F0F0),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'الشركات',
            style: GoogleFonts.tajawal(fontSize: 20, color: Colors.black),
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "تأكيد تسجيل الخروج",
                        style: GoogleFonts.tajawal(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                        style: GoogleFonts.tajawal(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          child: Text(
                            "إلغاء",
                            style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey),
                          ),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "تسجيل الخروج",
                            style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => LoginView()),
                        (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          tooltip: 'إضافة شركة',
          child: const Icon(Icons.add),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCompany()),
            );
            if (result == true) {
              fetchCompanies();
            }
          },
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : companyList.isEmpty
            ? Center(
                child: Text(
                  'لا توجد شركات لعرضها',
                  style: GoogleFonts.tajawal(fontSize: 18),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: companyList.length,
                itemBuilder: (context, index) {
                  final company = companyList[index];
                  final companyId = company['companyId'];
                  final isAdmin = adminStatusByCompany[companyId] ?? false;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.1),
                    margin: const EdgeInsets.only(bottom: 20),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              company['companyName'] ?? 'بدون اسم',
                              style: GoogleFonts.tajawal(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: secondaryColor,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade300, thickness: 1),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => navigateToPage(
                                    const LoginViewWithAdmin(),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.blue.shade100,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/icons/stock_control.jpg',
                                          width: 30,
                                          height: 30,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Stock Control',
                                          style: GoogleFonts.tajawal(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 40),
                              Expanded(
                                child: InkWell(
                                  onTap: () => navigateToPage(
                                    MainLayout(
                                      userId: widget.userId,
                                      companyName: company['companyName'],
                                      companyId: companyId,
                                      isAdmin:
                                          isAdmin, // ✅ pass per-company admin
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.green.shade100,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.business,
                                          size: 30,
                                          color: Colors.green.shade700,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'إدارة الشركة',
                                          style: GoogleFonts.tajawal(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Ink(
                                    decoration: ShapeDecoration(
                                      color:
                                          (company['statusId'] == 2 ||
                                              company['statusId'] == 3)
                                          ? Colors.grey
                                          : Colors.redAccent,
                                      shape: const CircleBorder(),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.stop,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed:
                                          (company['statusId'] == 2 ||
                                              company['statusId'] == 3)
                                          ? null
                                          : () => toggleCompanyStatus(
                                              company['companyId'],
                                              2,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "إيقاف دائم",
                                    style: GoogleFonts.tajawal(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          (company['statusId'] == 2 ||
                                              company['statusId'] == 3)
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Ink(
                                    decoration: ShapeDecoration(
                                      color: (company['statusId'] == 1)
                                          ? Colors.grey
                                          : Colors.orange,
                                      shape: const CircleBorder(),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.restart_alt,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: (company['statusId'] == 1)
                                          ? null
                                          : () => toggleCompanyStatus(
                                              company['companyId'],
                                              1,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "إعادة تشغيل",
                                    style: GoogleFonts.tajawal(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: (company['statusId'] == 1)
                                          ? Colors.grey
                                          : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
