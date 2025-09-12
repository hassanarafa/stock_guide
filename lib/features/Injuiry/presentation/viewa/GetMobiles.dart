import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../../../Renew/presentation/views/RenewNobile.dart';

class UserModel {
  final String userId;
  final String mobile;
  final String name;
  final bool isPaid;

  UserModel({
    required this.userId,
    required this.mobile,
    required this.name,
    required this.isPaid,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      mobile: json['mobile'] ?? "",
      name: json['displayName'] ?? "",
      isPaid: json['isActive'] ?? false,
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

  Future<void> fetchUsers() async {
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

        setState(() {
          users = allUsers.map((json) => UserModel.fromJson(json)).toList();
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
    int months,
    double fees,
  ) async {
    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/User/UpdateUser",
    );

    final body = {
      "companyId": widget.companyId,
      "userId": user.userId,
      "updatedByUserId": "admin", // استبدلها بالـ userId الفعلي
      "userName": name,
      "mobileNo": mobile,
      "noMonth": months,
      "fees": fees,
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
      } else {
        print("Update failed: ${response.body}");
      }
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  void showEditDialog(UserModel user) async {
    final settings = await fetchUserFeeSettings();

    final nameController = TextEditingController(text: user.name);
    final mobileController = TextEditingController(text: user.mobile);

    Map<String, dynamic>? selectedSetting = settings.isNotEmpty
        ? settings.first
        : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text(
                "تعديل بيانات المستخدم",
                style: GoogleFonts.tajawal(),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "الاسم"),
                    ),
                    TextField(
                      controller: mobileController,
                      decoration: const InputDecoration(
                        labelText: "رقم الموبايل",
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Map<String, dynamic>>(
                      decoration: const InputDecoration(labelText: "الخطة"),
                      value: selectedSetting,
                      items: settings.map((setting) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: setting,
                          child: Text(
                            "${setting['noMonths']} شهر - ${setting['fees']} ج.م",
                            style: GoogleFonts.tajawal(),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedSetting = val;
                        });
                      },
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
                    if (selectedSetting == null) return;
                    final name = nameController.text.trim();
                    final mobile = mobileController.text.trim();
                    final months = selectedSetting!['noMonths'];
                    final fees = selectedSetting!['fees'].toDouble();

                    updateUser(user, name, mobile, months, fees);
                  },
                ),
              ],
            );
          },
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
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
