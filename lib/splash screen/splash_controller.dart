
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () async {

    });

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    animation = Tween<double>(begin: .5, end: 1.2).animate(CurvedAnimation(
        parent: animationController, curve: Curves.elasticInOut));
    animationController.forward();
  }
}
