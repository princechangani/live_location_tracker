
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:live_location_tracker/routes/routes.dart';
import 'package:live_location_tracker/splash%20screnn/splash_binding.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
  GetStorage.init();
  runApp(MyApp());
}

final GetStorage  getStorage = GetStorage();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return
          GetMaterialApp(
            debugShowCheckedModeBanner: false,

            title: 'Flutter Demo',
            getPages:Routes.routes,
            initialRoute: Routes.splash,
            initialBinding: SplashBinding(),
          );
      },

    );
  }
}
