import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemBalancePage extends StatefulWidget {
  const ItemBalancePage({super.key});

  @override
  State<ItemBalancePage> createState() => _ItemBalancePageState();
}

class _ItemBalancePageState extends State<ItemBalancePage> {
  bool showSpecificWarehouse = false;
  bool showAllWarehouses = false;
  bool showOneWarehouses = false;
  bool showItemType = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.white,
          title: Text(
            showSpecificWarehouse
                ? "مخزن محدد"
                : showAllWarehouses
                ? "جميع المخازن"
                : showOneWarehouses
                ? "جميع المخازن (لكل مخزن)"
                : showItemType
                ? "نوع الصنف"
                : "دليل المخزون",
            style: GoogleFonts.tajawal(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.blueGrey.shade700,
            ),
          ),
          leading:
              (showSpecificWarehouse || showAllWarehouses || showOneWarehouses || showItemType)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
                  onPressed: () {
                    setState(() {
                      showSpecificWarehouse = false;
                      showAllWarehouses = false;
                      showOneWarehouses = false;
                      showItemType = false;
                    });
                  },
                )
              : null,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: showSpecificWarehouse
              ? const _StockSpecificWarehouseView()
              : showAllWarehouses
              ? const _StockAllWarehousesView()
              : showOneWarehouses
              ? const StockAllWarehousesPage()
              : showItemType
              ? const _StockItemTypeView()
              : _buildMainOptions(),
        ),
      ),
    );
  }

  Widget _buildMainOptions() {
    final List<Map<String, dynamic>> options = [
      {'text': 'مخزن محدد', 'icon': Icons.store_mall_directory},
      {'text': 'جميع المخازن حسب اللون والمقاس', 'icon': Icons.color_lens},
      {'text': 'جميع المخازن بناءًا على كل مخزن', 'icon': Icons.warehouse},
      {'text': 'نوع الصنف', 'icon': Icons.category},
    ];

    return ListView.builder(
      key: const ValueKey("options"),
      padding: const EdgeInsets.all(20),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (options[index]['text'] == 'مخزن محدد') {
              setState(() => showSpecificWarehouse = true);
            } else if (options[index]['text'] ==
                'جميع المخازن حسب اللون والمقاس') {
              setState(() => showAllWarehouses = true);
            } else if (options[index]['text'] ==
                'جميع المخازن بناءًا على كل مخزن') {
              setState(() => showOneWarehouses = true);
            } else if (options[index]['text'] == 'نوع الصنف') {
              setState(() => showItemType = true);
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(.07),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    options[index]['icon'],
                    color: Colors.blueAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    options[index]['text'],
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StockSpecificWarehouseView extends StatelessWidget {
  const _StockSpecificWarehouseView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey("specificWarehouse"),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: [
          _buildInputs(),
          const SizedBox(height: 25),
          _buildInfoCard(),
          const SizedBox(height: 25),
          _buildTableCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // المخزن
          _fullWidthDropdownWithButton(
            label: "أختر المخزن",
            icon: Icons.store,
            hint: "أختر المخزن",
            items: ["المخزن 1", "المخزن 2", "المخزن 3"],
            onChanged: (value) {},
            buttonPressed: () {},
          ),
          const SizedBox(height: 14),

          // الباركود
          _fullWidthInputWithButton(
            label: "الباركود",
            icon: Icons.key,
            hint: "الباركود",
            buttonPressed: () {},
          ),

          const SizedBox(height: 14),

          // الصنف
          _fullWidthDropdown(
            label: "أختر الصنف",
            icon: Icons.category,
            hint: "أختر الصنف",
            items: ["الصنف 1", "الصنف 2", "الصنف 3"],
            onChanged: (value) {},
          ),
          const SizedBox(height: 14),

          // كود الصنف
          _fullWidthInputWithButton(
            label: "كود الصنف",
            icon: Icons.key,
            hint: "كود الصنف",
            buttonPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _fullWidthInputWithButton({
    required String label,
    required IconData icon,
    required String hint,
    required VoidCallback buttonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: _inputDecoration(hint),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.white),
                onPressed: buttonPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullWidthDropdownWithButton({
    required String label,
    required IconData icon,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
    required VoidCallback buttonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: _inputDecoration(hint),
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.white),
                onPressed: buttonPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullWidthDropdown({
    required String label,
    required IconData icon,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: _inputDecoration(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  static Widget _inputRow(String label, IconData icon, List<String> items) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration("اختر $label"),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }

  static Widget _textRow(String label, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            initialValue: value,
            decoration: _inputDecoration(""),
          ),
        ),
      ],
    );
  }

  static InputDecoration _inputDecoration(String hint) {
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

  static Widget _buildInfoCard() {
    final info = [
      ["السعر قبل الخصم", "600 ج"],
      ["السعر بعد الخصم", "480 ج"],
      ["نسبة الخصم", "20%"],
      ["قيمة الخصم", "120 ج"],
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.blueAccent.withOpacity(.2),
      child: Column(
        children: info.map((row) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row[0],
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(row[1], style: GoogleFonts.tajawal(fontSize: 16)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  static Widget _buildTableCard() {
    final headers = ["اللون", "المقاس", "الرصيد", "الحجز", "الباقي"];
    final data = [
      ["أبيض", "L", "3", "1", "2"],
      ["أحمر", "XL", "1", "0", "1"],
      ["أسود", "M", "2", "1", "1"],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Colors.black12),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(.1)),
            children: headers.map((h) => _tableCell(h, bold: true)).toList(),
          ),
          ...data.map(
            (row) => TableRow(children: row.map((c) => _tableCell(c)).toList()),
          ),
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(.3),
            ),
            children: [
              _tableCell("إجمالي", bold: true),
              _tableCell(""),
              _tableCell("6"),
              _tableCell("2"),
              _tableCell("4"),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _tableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.tajawal(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _StockAllWarehousesView extends StatelessWidget {
  const _StockAllWarehousesView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey("allWarehouses"),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: [
          _buildInputs(),
          const SizedBox(height: 25),
          _buildInfoCard(),
          const SizedBox(height: 25),
          _buildTableCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // الباركود
          _fullWidthInputWithButton(
            label: "الباركود",
            icon: Icons.key,
            hint: "الباركود",
            buttonPressed: () {},
          ),

          const SizedBox(height: 14),

          // الصنف
          _fullWidthDropdown(
            label: "أختر الصنف",
            icon: Icons.category,
            hint: "أختر الصنف",
            items: ["الصنف 1", "الصنف 2", "الصنف 3"],
            onChanged: (value) {},
          ),
          const SizedBox(height: 14),

          // كود الصنف
          _fullWidthInputWithButton(
            label: "كود الصنف",
            icon: Icons.key,
            hint: "كود الصنف",
            buttonPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _fullWidthInputWithButton({
    required String label,
    required IconData icon,
    required String hint,
    required VoidCallback buttonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: _inputDecoration(hint),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.white),
                onPressed: buttonPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullWidthDropdown({
    required String label,
    required IconData icon,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: _inputDecoration(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }


  static InputDecoration _inputDecoration(String hint) {
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

  // -------------------------------------------------------------
  // 2️⃣ PRODUCT PRICE INFO
  // -------------------------------------------------------------
  static Widget _buildInfoCard() {
    final info = [
      ["السعر قبل الخصم", "600 ج"],
      ["السعر بعد الخصم", "480 ج"],
      ["نسبة الخصم", "20%"],
      ["قيمة الخصم", "120 ج"],
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.blueAccent.withOpacity(.2),
      child: Column(
        children: info.map((row) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    row[0],
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(row[1], style: GoogleFonts.tajawal(fontSize: 16)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------------------
  // 3️⃣ TABLE OF STOCK
  // -------------------------------------------------------------
  static Widget _buildTableCard() {
    final headers = ["اللون", "المقاس", "الرصيد", "الحجز", "الباقي"];
    final data = [
      ["أبيض", "L", "3", "1", "2"],
      ["أبيض", "XL", "2", "0", "2"],
      ["أحمر", "XL", "1", "0", "1"],
      ["أحمر", "3XL", "0", "1", "1"],
      ["أسود", "XL", "1", "1", "2"],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Colors.black12),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(.1)),
            children: headers.map((h) => _tableCell(h, bold: true)).toList(),
          ),
          ...data.map(
            (row) => TableRow(children: row.map((c) => _tableCell(c)).toList()),
          ),
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(.3),
            ),
            children: [
              _tableCell("إجمالي", bold: true),
              _tableCell(""),
              _tableCell("7"),
              _tableCell("4"),
              _tableCell("11"),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _tableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.tajawal(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class StockAllWarehousesPage extends StatelessWidget {
  const StockAllWarehousesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey("oneWarehouseView"),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: [
          _buildInputs(),
          const SizedBox(height: 25),
          _buildTableCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _fullWidthInputWithButton(
            label: "الباركود",
            icon: Icons.key,
            hint: "الباركود",
            buttonPressed: () {},
          ),

          const SizedBox(height: 14),

          _fullWidthDropdown(
            label: "أختر الصنف",
            icon: Icons.category,
            hint: "أختر الصنف",
            items: ["الصنف 1", "الصنف 2", "الصنف 3"],
            onChanged: (value) {},
          ),
          const SizedBox(height: 14),

          _fullWidthInputWithButton(
            label: "كود الصنف",
            icon: Icons.key,
            hint: "كود الصنف",
            buttonPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _fullWidthInputWithButton({
    required String label,
    required IconData icon,
    required String hint,
    required VoidCallback buttonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: _inputDecoration(hint),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.white),
                onPressed: buttonPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullWidthDropdown({
    required String label,
    required IconData icon,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: _inputDecoration(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }


  static InputDecoration _inputDecoration(String hint) {
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

  static Widget _buildTableCard() {
    final headers = ["المخزن", "الرصيد", "الحجز", "الباقي"];
    final data = [
      ["رامو", "10", "3", "7"],
      ["النزهة", "0", "2", "-2"],
      ["فخري", "5", "0", "5"],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Colors.black12),
        ),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(.1)),
            children: headers.map((h) => _tableCell(h, bold: true)).toList(),
          ),

          // Rows
          ...data.map(
            (row) => TableRow(children: row.map((c) => _tableCell(c)).toList()),
          ),

          // Footer
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(.3),
            ),
            children: [
              _tableCell("إجمالي", bold: true),
              _tableCell("15"),
              _tableCell("5"),
              _tableCell("10"),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _tableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.tajawal(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _StockItemTypeView extends StatelessWidget {
  const _StockItemTypeView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey("itemTypeView"),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: [
          _buildInputs(),
          const SizedBox(height: 25),
          _buildTableCard(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _fullWidthDropdown(
            label: "أختر الصنف",
            icon: Icons.category,
            hint: "أختر الصنف",
            items: ["الصنف 1", "الصنف 2", "الصنف 3"],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _fullWidthInputWithButton({
    required String label,
    required IconData icon,
    required String hint,
    required VoidCallback buttonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: _inputDecoration(hint),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.white),
                onPressed: buttonPressed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fullWidthDropdown({
    required String label,
    required IconData icon,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: _inputDecoration(hint),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  static Widget _inputRow(String label, IconData icon, List<String> items) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueAccent),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.tajawal(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: _inputDecoration("اختر $label"),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (_) {},
          ),
        ),
      ],
    );
  }

  static InputDecoration _inputDecoration(String hint) {
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

  static Widget _buildTableCard() {
    final headers = ["المخزن", "الرصيد", "الحجز", "الباقي"];
    final data = [
      ["رامو", "10", "3", "7"],
      ["النزهة", "0", "2", "-2"],
      ["فخري", "5", "0", "5"],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: const BorderSide(color: Colors.black12),
        ),
        children: [
          // Header
          TableRow(
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(.1)),
            children: headers.map((h) => _tableCell(h, bold: true)).toList(),
          ),

          // Rows
          ...data.map(
                (row) => TableRow(children: row.map((c) => _tableCell(c)).toList()),
          ),

          // Footer
          TableRow(
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withOpacity(.3),
            ),
            children: [
              _tableCell("إجمالي", bold: true),
              _tableCell("15"),
              _tableCell("5"),
              _tableCell("10"),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _tableCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.tajawal(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
