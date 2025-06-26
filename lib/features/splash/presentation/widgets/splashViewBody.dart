import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants.dart';
import '../../../../core/utils/assets.dart';
import '../../../onBoarding/presentation/views/onBoard.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      Get.to(
        () => OnBoard(),
        transition: Transition.fade,
        duration: transactionDuration,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Image(image: AssetImage(AssetsDAta.logo))],
      ),
    );
  }
}
