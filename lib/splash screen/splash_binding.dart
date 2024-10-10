import 'package:get/get.dart';
import 'package:live_location_tracker/splash%20screnn/splash_controller.dart';

class SplashBinding extends Bindings{
  @override
  void dependencies() {
   Get.put<SplashController>(SplashController());
  }

}