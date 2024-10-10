

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:live_location_tracker/constant/app_colors.dart';
import 'package:live_location_tracker/splash%20screnn/splash_controller.dart';


class SplashView extends GetView<SplashController> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: backgroundColor,

      body: Center(child: AnimatedBuilder(
        animation:controller.animationController,
        child: Center(child: CircularProgressIndicator()),
        builder: (BuildContext context, Widget? child) {
          return ScaleTransition(scale: controller.animation,
            child: child
            ,);
        } ,
      ),),
    );
  }
}
