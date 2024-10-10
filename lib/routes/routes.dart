




import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:live_location_tracker/splash%20screnn/splash_binding.dart';
import 'package:live_location_tracker/splash%20screnn/splash_view.dart';

class Routes {
  static const splash = "/splash";
  static const googleMap="/googleMap";

  static final routes = [
    GetPage(name: splash, page: () => SplashView(), binding: SplashBinding()),


  ];

}
