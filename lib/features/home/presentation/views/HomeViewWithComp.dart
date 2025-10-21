import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:stock_guide/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../Add/presentation/views/AddCompany.dart';
import '../../../CompanyPages/presentation/views/MainLayout.dart';
import '../../../Stock Guide/presentation/views/LoginViewWithAdmin.dart';
import '../../../login/presentation/views/loginView.dart';

class HomeWithCompanies extends StatefulWidget {
  final String userId;
  final bool userCurrentSubIsPaid;

  const HomeWithCompanies({super.key, required this.userId, required this.userCurrentSubIsPaid});

  @override
  State<HomeWithCompanies> createState() => _HomeWithCompaniesState();
}

class _HomeWithCompaniesState extends State<HomeWithCompanies> {
  List<Map<String, dynamic>> companyList = [];
  bool isLoading = true;
  Map<int, bool> adminStatusByCompany = {};
  Map<int, bool> canInsertBranchByCompany = {};
  Map<int, bool> canInsertUserByCompany = {};
  String? errorMessage;
  StreamSubscription? _subscription;
  Map<int, bool> canDeleteCompany = {};

  @override
  void initState() {
    super.initState();
    _subscription = Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        if (await _checkInternet()) {
          fetchCompanies();
        }
      }
    });
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

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
          canInsertBranchByCompany[companyId] =
              data['data']['hasRightToInsertBranch'] ?? false;
          canInsertUserByCompany[companyId] =
              data['data']['hasRightToInsertUsers'] ?? false;
        });
      } else {
        setState(() {
          adminStatusByCompany[companyId] = false;
          canInsertBranchByCompany[companyId] = false;
          canInsertUserByCompany[companyId] = false;
        });
      }
    } on SocketException {
      setState(() {
        errorMessage = "لا يوجد اتصال بالإنترنت، حاول مرة أخرى.";
      });
    } catch (e) {
      print("Error fetching user info: $e");
      setState(() {
        adminStatusByCompany[companyId] = false;
        canInsertBranchByCompany[companyId] = false;
        canInsertUserByCompany[companyId] = false;
      });
    }
  }

  Future<void> _showBranchesBeforeNavigate(int companyId) async {
    try {
      final url = Uri.parse(
        "http://197.134.252.181/StockGuideAPI/Branch/GetAllBranchesByCompanyIdInRenew?companyId=$companyId",
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 1 && decoded['data'] != null) {
          final data = decoded['data'];
          List<Map<String, dynamic>> allBranches = [];
          if (data['noSubscriptionEver'] is List) {
            allBranches.addAll(
              List<Map<String, dynamic>>.from(data['noSubscriptionEver']),
            );
          }
          if (data['currentUnpaidSubscription'] is List) {
            allBranches.addAll(
              List<Map<String, dynamic>>.from(
                data['currentUnpaidSubscription'],
              ),
            );
          }
          if (data['noActiveSubscriptionToday'] is List) {
            allBranches.addAll(
              List<Map<String, dynamic>>.from(
                data['noActiveSubscriptionToday'],
              ),
            );
          }
          List<Map<String, dynamic>> paidBranches = allBranches
              .where((branch) => branch['isPaid'] == true)
              .toList();
          await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "اختر الفرع",
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: paidBranches.isEmpty
                      ? Center(
                          child: Text(
                            "لا توجد فروع مدفوعة لهذه الشركة",
                            style: GoogleFonts.tajawal(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: paidBranches.length,
                          itemBuilder: (context, index) {
                            final branch = paidBranches[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(
                                  branch['branchName'] ?? 'بدون اسم',
                                  style: GoogleFonts.tajawal(fontSize: 16),
                                ),
                                leading: const Icon(
                                  Icons.store,
                                  color: Colors.green,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LoginViewWithAdmin(
                                        companyId: companyId,
                                        branchId: branch['branchId'],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "إلغاء",
                      style: GoogleFonts.tajawal(fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("لا توجد فروع متاحة لهذه الشركة")),
          );
        }
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء تحميل الفروع: $e")));
    }
  }

  Future<void> deleteCompany(int companyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "تأكيد الحذف",
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            "هل أنت متأكد أنك تريد حذف هذه الشركة؟",
            style: GoogleFonts.tajawal(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              child: Text(
                "إلغاء",
                style: GoogleFonts.tajawal(fontSize: 16, color: Colors.grey),
              ),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "حذف",
                style: GoogleFonts.tajawal(fontSize: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      final url = Uri.parse(
        "http://197.134.252.181/StockGuideAPI/Company/DeleteCompany"
        "?userId=${widget.userId}&companyId=$companyId",
      );
      final response = await http.post(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["status"] == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تم حذف الشركة بنجاح 🗑️")),
          );
          fetchCompanies();
        } else {
          throw Exception(data["message"] ?? "فشل في حذف الشركة");
        }
      } else {
        throw Exception("HTTP ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ أثناء الحذف: $e")));
    }
  }

  Future<bool> hasBranches(int companyId) async {
    try {
      final url = Uri.parse(
        "http://197.134.252.181/StockGuideAPI/Branch/GetAllBranchesByCompanyIdInRenew?companyId=$companyId",
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 1 && decoded['data'] != null) {
          final data = decoded['data'];
          final allBranches = [
            ...(data['noSubscriptionEver'] ?? []),
            ...(data['currentUnpaidSubscription'] ?? []),
            ...(data['noActiveSubscriptionToday'] ?? []),
          ];
          return allBranches.isNotEmpty;
        }
      }
      return false;
    } catch (e) {
      print("Error checking branches: $e");
      return false;
    }
  }

  Future<bool> hasUsers(int companyId) async {
    try {
      final url = Uri.parse(
        "http://197.134.252.181/StockGuideAPI/User/GetAllUsersByCompanyIdInRenew?companyId=$companyId",
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['status'] == 1 && decoded['data'] != null) {
          final data = decoded['data'];
          final allUsers = [
            ...(data['noSubscriptionEver'] ?? []),
            ...(data['currentUnpaidSubscription'] ?? []),
            ...(data['noActiveSubscriptionToday'] ?? []),
          ];
          return allUsers.isNotEmpty;
        }
      }
      return false;
    } catch (e) {
      print("Error checking users: $e");
      return false;
    }
  }

  Future<void> fetchCompanies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
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
        for (var company in companies) {
          fetchUserInfo(widget.userId, company['companyId']);
        }
        for (var company in companies) {
          final companyId = company['companyId'];
          final hasBranch = await hasBranches(companyId);
          final hasUser = await hasUsers(companyId);
          setState(() {
            canDeleteCompany[companyId] = !(hasBranch || hasUser);
          });
        }
      } else {
        setState(() {
          companyList = [];
          isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        errorMessage =
            "لا يوجد اتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.";
        isLoading = false;
      });
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
                        style: GoogleFonts.tajawal(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      content: Text(
                        "هل أنت متأكد أنك تريد تسجيل الخروج؟",
                        style: GoogleFonts.tajawal(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        TextButton(
                          child: Text(
                            "إلغاء",
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
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
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              color: Colors.white,
                            ),
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
            : errorMessage != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.red, size: 60),
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (await _checkInternet()) {
                          fetchCompanies();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "⚠️ ما زال لا يوجد اتصال بالإنترنت",
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text("إعادة المحاولة"),
                    ),
                  ],
                ),
              )
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
                  final statusId = company['companyStatusId'];
                  final companyStatusName = company['companyStatusName'] ?? '';
                  final userStatusId = company['userStatusId'] ?? 1;
                  final userStatusName = company['userStatusName'] ?? '';
                  final isAdmin = adminStatusByCompany[companyId] ?? false;
                  final hasRightToInsertBranch =
                      canInsertBranchByCompany[companyId] ?? false;
                  final hasRightToInsertUsers =
                      canInsertUserByCompany[companyId] ?? false;
                  final isDisabled =
                      (statusId == 2 ||
                      statusId == 3 ||
                      userStatusId == 2 ||
                      userStatusId == 3);
                  return Card(
                    color: Colors.white,
                    elevation: 8,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Centered Title
                              Center(
                                child: Text(
                                  company['companyName'] ?? '',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.tajawal(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: secondaryColor,
                                  ),
                                ),
                              ),

                              if (canDeleteCompany[companyId] == true)
                                Positioned(
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                      size: 26,
                                    ),
                                    tooltip: "حذف الشركة",
                                    onPressed: () => deleteCompany(companyId),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "حالة الشركة: $companyStatusName\nحالة المستخدم: $userStatusName",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey.shade300, thickness: 1),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: !isAdmin && (isDisabled || widget.userCurrentSubIsPaid == false)
                                      ? null
                                      : () => _showBranchesBeforeNavigate(
                                          companyId,
                                        ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isAdmin && (isDisabled || widget.userCurrentSubIsPaid == false)
                                          ? Colors.grey.shade300
                                          : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: !isAdmin && (isDisabled || widget.userCurrentSubIsPaid == false)
                                            ? Colors.grey
                                            : Colors.blue.shade100,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/icons/stock_control.jpg',
                                          width: 30,
                                          height: 30,
                                          color: !isAdmin && (isDisabled || widget.userCurrentSubIsPaid == false)
                                              ? Colors.grey
                                              : null,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Stock Control',
                                          style: GoogleFonts.tajawal(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: !isAdmin && (isDisabled || widget.userCurrentSubIsPaid == false)
                                                ? Colors.grey
                                                : Colors.blue.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (isAdmin ||
                                  (!isAdmin &&
                                      (hasRightToInsertBranch ||
                                          hasRightToInsertUsers)))
                                const SizedBox(width: 40),
                              if (isAdmin ||
                                  (!isAdmin &&
                                      (hasRightToInsertBranch ||
                                          hasRightToInsertUsers)))
                                Expanded(
                                  child: InkWell(
                                    onTap: isDisabled
                                        ? null
                                        : () => navigateToPage(
                                            MainLayout(
                                              userId: widget.userId,
                                              companyName:
                                                  company['companyName'],
                                              companyId: companyId,
                                              isAdmin: isAdmin,
                                              companyStatus: statusId,
                                              hasRightToInsertBranch:
                                                  hasRightToInsertBranch,
                                              hasRightToInsertUsers:
                                                  hasRightToInsertUsers,
                                            ),
                                          ),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDisabled
                                            ? Colors.grey.shade300
                                            : Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isDisabled
                                              ? Colors.grey
                                              : Colors.green.shade100,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.business,
                                            size: 30,
                                            color: isDisabled
                                                ? Colors.grey
                                                : Colors.green.shade700,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'إدارة الشركة',
                                            style: GoogleFonts.tajawal(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: isDisabled
                                                  ? Colors.grey
                                                  : Colors.green.shade800,
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
                          if (isAdmin)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Ink(
                                      decoration: ShapeDecoration(
                                        color: (statusId == 2 || statusId == 3)
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
                                            (statusId == 2 || statusId == 3)
                                            ? null
                                            : () => toggleCompanyStatus(
                                                companyId,
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
                                        color: (statusId == 2 || statusId == 3)
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
                                        color: (statusId == 1)
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
                                        onPressed: (statusId == 1)
                                            ? null
                                            : () => toggleCompanyStatus(
                                                companyId,
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
                                        color: (statusId == 1)
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
