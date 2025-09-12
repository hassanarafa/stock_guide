import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../../../../constants.dart';

class FeeOption {
  final int id;
  final int months;
  final double price;

  FeeOption({required this.id, required this.months, required this.price});

  factory FeeOption.fromJson(Map<String, dynamic> json) {
    return FeeOption(
      id: json['id'],
      months: json['noMonths'],
      price: (json['fees'] as num).toDouble(),
    );
  }
}

class MobileUser {
  final String userId;
  final int subscriptionUserId;
  final String name;
  final String mobileNo;
  final double fees;
  final int months;

  MobileUser({
    required this.userId,
    required this.subscriptionUserId,
    required this.name,
    required this.mobileNo,
    required this.fees,
    required this.months,
  });

  factory MobileUser.fromJson(Map<String, dynamic> json) {
    return MobileUser(
      userId: json['userId'] ?? '',
      subscriptionUserId: json['userSubscribtionId'] ?? 0,
      name: json['displayName'] ?? '',
      mobileNo: json['mobile'] ?? '',
      fees: (json['fees'] as num?)?.toDouble() ?? 0.0,
      months: json['noMonth'] ?? 0,
    );
  }
}

class RenewMobile extends StatefulWidget {
  final int companyId;
  final String userId;
  final String? mobileName;

  const RenewMobile({
    super.key,
    required this.companyId,
    required this.userId,
    this.mobileName,
  });

  @override
  State<RenewMobile> createState() => _RenewMobileState();
}

class _RenewMobileState extends State<RenewMobile> {
  List<MobileUser> mobiles = [];
  MobileUser? _selectedMobile;

  List<FeeOption> feeOptions = [];
  FeeOption? _selectedFee;

  bool isLoadingMobiles = true;
  bool isLoadingFees = true;

  @override
  void initState() {
    super.initState();
    fetchMobiles();
    fetchFeeOptions();
  }

  Future<void> showMessageDialog(String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(16),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.tajawal(fontSize: 16),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'حسناً',
              style: GoogleFonts.tajawal(fontSize: 16, color: Colors.lightBlue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchMobiles() async {
    try {
      final url = Uri.parse(
        "http://197.134.252.181/StockGuideAPI/User/GetAllUsersByCompanyIdInRenew?companyId=${widget.companyId}",
      );
      final response = await http.get(url);

      print(response.body);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final List<dynamic> data =
            decoded['data']?['currentUnpaidSubscription'] ?? [];

        List<MobileUser> loadedMobiles = data
            .map((e) => MobileUser.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (mounted) {
          setState(() {
            mobiles = loadedMobiles;
            isLoadingMobiles = false;

            // Pick default
            if (widget.mobileName != null && mobiles.isNotEmpty) {
              try {
                _selectedMobile = mobiles.firstWhere(
                  (m) => m.mobileNo == widget.mobileName,
                );
              } catch (_) {
                _selectedMobile = null;
              }
            } else {
              _selectedMobile = null;
            }
          });
        }
      } else {
        throw Exception(
          "فشل تحميل أرقام الموبايل (كود: ${response.statusCode})",
        );
      }
    } catch (e) {
      setState(() => isLoadingMobiles = false);
      showMessageDialog("خطأ في تحميل الموبايلات: $e");
    }
  }

  Future<void> fetchFeeOptions() async {
    try {
      final url = Uri.parse(
        "http://197.134.252.181/StockGuideAPI/User/GetSettingOfUserFeesInFirstTime",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'] as List;
        final options = data.map((e) => FeeOption.fromJson(e)).toList();

        setState(() {
          feeOptions = options;
          _selectedFee = options.isNotEmpty ? options.first : null;
          isLoadingFees = false;
        });
      } else {
        throw Exception("فشل تحميل الاشتراكات");
      }
    } catch (e) {
      setState(() => isLoadingFees = false);
      showMessageDialog("خطأ في تحميل الاشتراكات: $e");
    }
  }

  Future<void> _uploadReceipt() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      showMessageDialog("لم يتم اختيار ملف 📄");
      return;
    }

    File file = File(result.files.single.path!);
    var uri = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Files/UploadSubscriptionGroupForUsers",
    );

    var request = http.MultipartRequest("POST", uri);
    request.fields['SubscribtionUserIds'] =
        _selectedMobile?.userId ?? widget.userId;
    request.files.add(await http.MultipartFile.fromPath('File', file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      showMessageDialog("تم رفع الإيصال بنجاح ✅");
    } else {
      showMessageDialog("فشل رفع الإيصال ❌ (كود: ${response.statusCode})");
    }
  }

  Future<void> renewUser() async {
    if (_selectedMobile == null || _selectedFee == null) {
      showMessageDialog("يرجى اختيار الموبايل والباقات أولاً ⚠️");
      return;
    }

    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/User/UpdateUser",
    );

    final body = {
      "companyId": widget.companyId,
      "userId": _selectedMobile!.userId,
      "updatedByUserId": widget.userId,
      "userName": _selectedMobile!.name,
      "mobileNo": _selectedMobile!.mobileNo,
      "noMonth": _selectedFee!.months,
      "fees": _selectedFee!.price,
    };

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        showMessageDialog("تم تجديد الاشتراك بنجاح ✅");
      } else {
        showMessageDialog("فشل التجديد ❌ (كود: ${response.statusCode})");
      }
    } catch (e) {
      showMessageDialog("خطأ في الاتصال بالسيرفر ❌: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'تجديد موبايل',
            style: GoogleFonts.tajawal(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
          const SizedBox(height: 12),

          /// Dropdown or fixed text
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isLoadingMobiles
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonHideUnderline(
                    child: DropdownButton<MobileUser>(
                      hint: const Text('اختر الموبايل'),
                      value: _selectedMobile,
                      isExpanded: true,
                      onChanged: (mobile) {
                        setState(() => _selectedMobile = mobile);
                      },
                      items: mobiles.map((mobile) {
                        return DropdownMenuItem(
                          value: mobile,
                          child: Text(mobile.name),
                        );
                      }).toList(),
                    ),
                  ),
          ),

          const SizedBox(height: 20),

          /// Fee options
          isLoadingFees
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: feeOptions.map((option) {
                    final isSelected = _selectedFee?.id == option.id;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFee = option),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade50
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "${option.months} شهور",
                                style: GoogleFonts.tajawal(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                "(${option.price.toStringAsFixed(0)} جم)",
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

          const SizedBox(height: 25),

          /// Total
          Text(
            _selectedFee == null
                ? "الاجمالي: -"
                : "الاجمالي: ${_selectedFee!.price.toStringAsFixed(0)} ج.م",
            style: GoogleFonts.tajawal(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          /// Buttons
          /// Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: renewUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3, // ظل خفيف
                  ),
                  child: Text(
                    'تجديد',
                    style: GoogleFonts.tajawal(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _uploadReceipt,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'إرفاق إيصال الدفع',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
