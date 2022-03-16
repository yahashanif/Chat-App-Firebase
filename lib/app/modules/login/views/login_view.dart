import 'package:chat_app/app/shared/shared.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../controllers/auth_controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    authC.screen(context);
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(30),
        child: authC.isAuth.isFalse
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: Get.width * 0.7,
                      height: Get.width * 0.7,
                      child: Lottie.asset("assets/lottie/lottie_chat.json"),
                    ),
                    SizedBox(
                      height: height(150),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: width(20)),
                      padding:
                          EdgeInsets.symmetric(horizontal: width(width(5))),
                      child: ElevatedButton(
                        onPressed: () {
                          authC.login();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: width(40),
                                height: height(40),
                                child: Image.asset(
                                  "assets/logo/google.png",
                                )),
                            SizedBox(
                              width: width(10),
                            ),
                            Text(
                              "Google",
                              style: primaryTextStyle.copyWith(
                                  fontSize: sp(14),
                                  fontWeight: bold,
                                  color: blackColor),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: Colors.grey[50],
                          padding: EdgeInsets.symmetric(
                              vertical: height(height(15))),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(r(15)),
                              side: BorderSide(color: blackColor)),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Center(
                child: Container(
                
                child: LottieBuilder.asset("assets/lottie/loading.json"),
              )),
      )),
    );
  }
}
