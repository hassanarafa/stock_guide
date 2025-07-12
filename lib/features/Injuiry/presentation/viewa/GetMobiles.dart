import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GetMobiles extends StatefulWidget {
  const GetMobiles({super.key});

  @override
  State<GetMobiles> createState() => _GetMobilesState();
}

class _GetMobilesState extends State<GetMobiles> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> subscriptions = [
    {
      'branch': '01010101010',
      'startDate': '11/11/2024',
      'endDate': '11/11/2025',
      'isActive': true,
    },
    {
      'branch': '01010101011',
      'startDate': '10/5/2024',
      'endDate': '30/12/2024',
      'isActive': false,
    },
    {
      'branch': '01010101013',
      'startDate': '11/11/2024',
      'endDate': '11/11/2025',
      'isActive': true,
    },
    {
      'branch': '01010101014',
      'startDate': '10/5/2024',
      'endDate': '30/12/2024',
      'isActive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) {
                      final item = subscriptions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Text Info
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['branch'],
                                    style: GoogleFonts.tajawal(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'بداية الاشتراك: ${item['startDate']}',
                                    style: GoogleFonts.tajawal(fontSize: 14),
                                  ),
                                  Text(
                                    'نهاية الاشتراك: ${item['endDate']}',
                                    style: GoogleFonts.tajawal(fontSize: 14),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 16),
                              // Space between text and icon

                              // Status Icon
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: item['isActive']
                                        ? Colors.green
                                        : Colors.red,
                                    child: Icon(
                                      item['isActive']
                                          ? Icons.check
                                          : Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),

                                  if (!item['isActive']) ...[
                                    const SizedBox(height: 12),
                                    // Space between icon and button
                                    ElevatedButton(
                                      onPressed: () {
                                        // handle renew
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                      ),
                                      child: Text(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
