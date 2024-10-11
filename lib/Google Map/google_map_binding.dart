import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_location_tracker/Google%20Map/my_google_map_controller.dart';

class GoogleMapBinding extends Bindings {
  @override
  void dependencies() {
Get.put<MyGoogleMapController>(MyGoogleMapController()) ;
  }

}