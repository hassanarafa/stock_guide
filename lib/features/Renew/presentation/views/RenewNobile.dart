import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
  final int currentStatusId;

  MobileUser({
    required this.userId,
    required this.subscriptionUserId,
    required this.name,
    required this.mobileNo,
    required this.fees,
    required this.months,
    required this.currentStatusId,
  });

  factory MobileUser.fromJson(Map<String, dynamic> json) {
    return MobileUser(
      userId: json['userId'] ?? '',
      subscriptionUserId: json['userSubscribtionId'] ?? 0,
      name: json['displayName'] ?? '',
      mobileNo: json['mobile'] ?? '',
      fees: (json['fees'] as num).toDouble(),
      months: json['noMonth'] ?? 0,
      currentStatusId: json['currentStatusId'] ?? 0,
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
  bool _canUploadReceipt = false;

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

      print("==== Mobiles Response ====");
      print(response.body);
      print("=========================");

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        final List<dynamic> unpaidSubs =
            decoded['data']?['currentUnpaidSubscription'] ?? [];

        final List<dynamic> noActiveSubs =
            decoded['data']?['noActiveSubscriptionToday'] ?? [];

        // دمج كل المستخدمين
        final combined = [...unpaidSubs, ...noActiveSubs];

        // تحويل إلى List<MobileUser>
        List<MobileUser> loadedMobiles = combined
            .map((e) => MobileUser.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        if (mounted) {
          setState(() {
            mobiles = loadedMobiles;
            isLoadingMobiles = false;

            // اختيار موبايل تلقائياً لو جاي من صفحة سابقة
            if (widget.mobileName != null && mobiles.isNotEmpty) {
              try {
                _selectedMobile =
                    mobiles.firstWhere((m) => m.mobileNo == widget.mobileName);
              } catch (_) {
                _selectedMobile = null;
              }
            }
          });
        }
      } else {
        throw Exception("فشل تحميل الموبايلات (كود: ${response.statusCode})");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoadingMobiles = false);
      }
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

  Future<void> _uploadReceipt({required String userId}) async {
    if (_selectedMobile == null) {
      showMessageDialog("⚠️ يرجى اختيار موبايل أولاً");
      return;
    }

    File? file;

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("اختيار طريقة الرفع", style: GoogleFonts.tajawal()),
        content: Text("من فضلك اختر طريقة رفع الإيصال:", style: GoogleFonts.tajawal()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, "file"),
            child: Text("📂 من الملفات", style: GoogleFonts.tajawal()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, "camera"),
            child: Text("📸 من الكاميرا", style: GoogleFonts.tajawal()),
          ),
        ],
      ),
    );

    if (choice == null) return;

    if (choice == "file") {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) file = File(result.files.single.path!);
    } else if (choice == "camera") {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) file = File(pickedFile.path);
    }

    if (file == null) {
      showMessageDialog("لم يتم اختيار ملف 📄");
      return;
    }

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "تأكيد رفع الملف",
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("هل تريد رفع هذا الملف؟", style: GoogleFonts.tajawal()),
              const SizedBox(height: 10),
              Text(
                "📄 ${file!.path.split('/').last}",
                style: GoogleFonts.tajawal(),
              ),
              const SizedBox(height: 5),
              Text(
                "الحجم: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB",
                style: GoogleFonts.tajawal(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                "إلغاء",
                style: GoogleFonts.tajawal(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(
                "تأكيد",
                style: GoogleFonts.tajawal(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final uri = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/Files/UploadSubscriptionGroupForUsers",
    );

    var request = http.MultipartRequest("POST", uri);

    request.fields['SubscribtionUserIds[0]'] =
        _selectedMobile!.subscriptionUserId.toString();

    request.files.add(await http.MultipartFile.fromPath('File', file.path));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var response = await request.send();
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        showMessageDialog("✅ تم رفع الإيصال بنجاح");
        setState(() => _canUploadReceipt = false);
      } else {
        showMessageDialog("❌ فشل رفع الإيصال (كود: ${response.statusCode})");
      }
    } catch (e) {
      Navigator.of(context).pop();
      showMessageDialog("⚠️ خطأ أثناء الاتصال بالسيرفر: $e");
    }
  }

  Future<void> renewUser() async {
    if (_selectedMobile == null || _selectedFee == null) {
      showMessageDialog("يرجى اختيار الموبايل والباقات أولاً ⚠️");
      return;
    }

    final url = Uri.parse(
      "http://197.134.252.181/StockGuideAPI/User/UpdateUserInRenew",
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
        setState(() {
          _canUploadReceipt = true;
        });
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
                          child: Text(
                            "${mobile.name} - ${mobile.mobileNo}",
                            style: GoogleFonts.tajawal(fontSize: 16),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),

          const SizedBox(height: 20),

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
                    elevation: 3,
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
                  onPressed: _canUploadReceipt
                      ? () => _uploadReceipt(userId: widget.userId)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canUploadReceipt
                        ? Colors.green
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'ارفاق ايصال الدفع',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
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
