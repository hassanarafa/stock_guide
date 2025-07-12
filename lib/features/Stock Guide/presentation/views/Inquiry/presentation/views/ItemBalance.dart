import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemBalancePage extends StatefulWidget {
  const ItemBalancePage({super.key});

  @override
  State<ItemBalancePage> createState() => _ItemBalancePageState();
}

class _ItemBalancePageState extends State<ItemBalancePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2); // default to "رصيد صنف"
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> options = [
      'مخزن محدد',
      'جميع المخازن بناءًا على الوزن والمقاس',
      'جميع المخازن بناءًا على كل مخزن',
      'نوع الصنف',
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            options[index],
            style: GoogleFonts.tajawal(fontSize: 16),
          ),
        );
      },
    );
  }
}
