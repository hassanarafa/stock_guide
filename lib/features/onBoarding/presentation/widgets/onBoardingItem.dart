import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../constants.dart';

class OnboardingItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 35,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18),
            Text(
              description,
              style: GoogleFonts.montserrat(
                textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: secondaryTextColor,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
