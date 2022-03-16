import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/loading_controller.dart';

class LoadingView extends GetView<LoadingController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: LottieBuilder.asset("assets/lottie/loading.json")),
    );
  }
}
