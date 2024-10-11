
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:live_location_tracker/routes/routes.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> animation;
  final Location location = Location();


  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    animation = Tween<double>(begin: .5, end: 1.2).animate(CurvedAnimation(
        parent: animationController, curve: Curves.elasticInOut));
    animationController.forward();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await location.serviceEnabled();

    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Retry until the service is enabled
        getCurrentLocation();
        return;
      }
    }
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showSettingsRedirectDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showSettingsRedirectDialog();
      return;
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // If permission is granted, navigate to HomeScreen
      Get.toNamed(Routes.googleMap); // Replaces the current route with HomeScreen
    }
  }

  void showSettingsRedirectDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text(
            "This app requires location permission. Please enable it in the app settings."),
        actions: [
          TextButton(
            onPressed: () async {
              bool opened = await Geolocator.openAppSettings();
              if (opened) {
                Get.back(); // Close the dialog
                await Future.delayed(const Duration(seconds: 1));
                checkLocationPermission(); // Recheck after returning from settings
              } else {
                Get.snackbar("Error", "Unable to open settings",
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
              checkLocationPermission(); // Retry permission check
            },
            child: const Text("Retry"),
          ),
        ],
      ),
      barrierDismissible: false, // Prevent dismissing the dialog
    );
  }
}