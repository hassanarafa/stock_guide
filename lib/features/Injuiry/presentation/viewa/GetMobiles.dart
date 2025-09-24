import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../Renew/presentation/views/RenewNobile.dart';

class UserModel {
  final String userId;
  final String mobile;
  final String name;
  final bool isPaid;
  final String? currentSubscribtion;
  int? noMonths;
  int? fees;

  UserModel({
    required this.userId,
    required this.mobile,
    required this.name,
    required this.isPaid,
    this.currentSubscribtion,
    this.noMonths,
    this.fees,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      mobile: json['mobile'] ?? "",
      name: json['displayName'] ?? "",
      isPaid: json['isPaid'] ?? false,
      currentSubscribtion: json['currentSubscribtion'],
    );
  }
}

class GetMobiles extends StatefulWidget {
  final int companyId;

  const GetMobiles({super.key, required this.companyId});

  @override
  State<GetMobiles> createState() => _GetMobilesState();
}

class _GetMobilesState extends State<GetMobiles> {
  List<UserModel> users = [];
  bool isLoading = true;
  bool showRenewPage = false;
  UserModel? selectedUser;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  Future<void> fetchUsers() async {
    if (!await _checkInternet()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ لا يوجد اتصال بالإنترنت")),
      );
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/User/GetAllUsersByCompanyIdInRenew?companyId=${widget.companyId}",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = json.decode(response.body);

        final data = body['data'] as Map<String, dynamic>;
        final List<dynamic> currentUnpaid =
            data['currentUnpaidSubscription'] ?? [];
        final List<dynamic> noActive = data['noActiveSubscriptionToday'] ?? [];

        final allUsers = [...currentUnpaid, ...noActive];

        List<UserModel> loadedUsers = allUsers.map((json) => UserModel.fromJson(json)).toList();

        final settings = await fetchUserFeeSettings();
        for (var user in loadedUsers) {
          if (settings.isNotEmpty) {
            user.noMonths = settings.first['noMonths'];
            final feeValue = settings.first['fees'];
            if (feeValue != null) {
              if (feeValue is double) {
                user.fees = feeValue.toInt();
              } else if (feeValue is int) {
                user.fees = feeValue;
              } else {
                user.fees = int.tryParse(feeValue.toString());
              }
            }
          }
        }

        setState(() {
          users = loadedUsers;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserFeeSettings() async {
    if (!await _checkInternet()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ لا يوجد اتصال بالإنترنت")),
      );
      return [];
    }

    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/User/GetSettingOfUserFeesInFirstTime",
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print("Error fetching user fee settings: $e");
    }
    return [];
  }

  Future<void> updateUser(
      UserModel user,
      String name,
      String mobile,
      ) async {
    if (!await _checkInternet()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ لا يوجد اتصال بالإنترنت")),
      );
      return;
    }

    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/User/UpdateUser",
    );

    final body = {
      "companyId": widget.companyId,
      "userId": user.userId,
      "updatedByUserId": "admin",
      "userName": name,
      "mobileNo": mobile,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        fetchUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ تم تعديل بيانات المستخدم بنجاح")),
        );
      } else {
        print("Update failed: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ فشل التعديل")),
        );
      }
    } catch (e) {
      print("Error updating user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ حدث خطأ أثناء التعديل")),
      );
    }
  }

  void showEditDialog(UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final mobileController = TextEditingController(text: user.mobile);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text("تعديل بيانات المستخدم", style: GoogleFonts.tajawal()),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "الاسم"),
                ),
                TextField(
                  controller: mobileController,
                  decoration: const InputDecoration(labelText: "رقم الموبايل"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text("حفظ"),
              onPressed: () {
                final name = nameController.text.trim();
                final mobile = mobileController.text.trim();

                if (name.isEmpty || mobile.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("⚠️ يجب ملء جميع الحقول")),
                  );
                  return;
                }

                final duplicate = users.any((u) =>
                u.userId != user.userId && (u.name == name || u.mobile == mobile));

                if (duplicate) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ الاسم أو رقم الموبايل مستخدم بالفعل"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                updateUser(user, name, mobile);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: showRenewPage
              ? RenewMobile(
            companyId: widget.companyId,
            userId: selectedUser!.userId,
            mobileName: selectedUser!.mobile,
          )
              : isLoading
              ? const Center(child: CircularProgressIndicator())
              : users.isEmpty
              ? const Center(child: Text("لا يوجد مستخدمون"))
              : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: RefreshIndicator(
              onRefresh: () async => await fetchUsers(),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.mobile,
                                      style: GoogleFonts.tajawal(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    if (user.noMonths != null && user.fees != null) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        "📅 عدد الشهور: ${user.noMonths}",
                                        style: GoogleFonts.tajawal(fontSize: 16, color: Colors.black87),
                                      ),
                                      Text(
                                        "💰 الرسوم: ${user.fees} ج.م",
                                        style: GoogleFonts.tajawal(fontSize: 16, color: Colors.black87),
                                      ),
                                    ],
                                    if (user.currentSubscribtion != null) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        user.currentSubscribtion!,
                                        style: GoogleFonts.tajawal(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: user.isPaid
                                    ? Colors.green
                                    : Colors.orange,
                                child: Icon(
                                  user.isPaid
                                      ? Icons.check
                                      : Icons
                                      .warning_amber_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                tooltip: "تعديل",
                                onPressed: () =>
                                    showEditDialog(user),
                              ),
                              if (!user.isPaid) ...[
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      selectedUser = user;
                                      showRenewPage = true;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(12),
                                    ),
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'تجديد',
                                    style: GoogleFonts.tajawal(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
