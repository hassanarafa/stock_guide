import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants.dart';
import '../../../../core/utils/assets.dart';
import '../../../login/presentation/views/loginView.dart';
import '../widgets/onBoardingItem.dart';

class OnBoardingBody extends StatefulWidget {
  const OnBoardingBody({super.key});

  @override
  State<OnBoardingBody> createState() => _OnBoardingBodyState();
}

class _OnBoardingBodyState extends State<OnBoardingBody> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _pages = const [
    OnboardingItem(
      imagePath: AssetsDAta.onBoarding1,
      title: "أضف شركتك",
      description: "من خلال هذا التطبيق يمكنك اضافة شركتك بكافة تفاصيلها",
    ),
    OnboardingItem(
      imagePath: AssetsDAta.onBoarding2,
      title: "إضافة فروع",
      description: "يمكنك اضافة فروع شركتك وتفاصيلها",
    ),
    OnboardingItem(
      imagePath: AssetsDAta.onBoarding3,
      title: "استعلم عن شركتك",
      description: "يمكنك الاستفسار عن شركتك",
    ),
  ];

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.offAll(
            () => LoginView(),
        transition: Transition.fade,
        duration: transactionDuration,
      );
    }
  }

  void _goToPrevious() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    Get.offAll(
          () => LoginView(),
      transition: Transition.fade,
      duration: transactionDuration,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) => _pages[index],
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: _goToPrevious,
                    child: const Text("السابق"),
                  )
                else
                  const SizedBox(width: 80), // Placeholder for alignment

                if (_currentPage < _pages.length - 1)
                  TextButton(onPressed: _skip, child: const Text("تخطي"))
                else
                  const SizedBox(width: 80),

                ElevatedButton(
                  onPressed: _goToNext,
                  child: Text(
                    _currentPage == _pages.length - 1 ? "ابدأ" : "التالي",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


