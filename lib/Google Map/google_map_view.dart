import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:live_location_tracker/Google%20Map/my_google_map_controller.dart';

class GoogleMapView extends GetView<MyGoogleMapController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geofencing with Firebase"),
      ),
      body: Obx(() {
        return GoogleMap(
          polygons: controller.polygons.toSet(),
          onMapCreated: controller.onMapCreated,
          initialCameraPosition: CameraPosition(
            target: controller.currentLocationMarker.value.position,
            zoom: 10.0,
          ),
          markers: {controller.currentLocationMarker.value},
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        );
      }),
    );
  }
}
