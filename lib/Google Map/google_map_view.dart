import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_location_tracker/Google%20Map/my_google_map_controller.dart';

class GoogleMapView extends GetView<MyGoogleMapController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps in Flutter'),
      ),
      body: Obx(
            () => controller.currentPosition.value == null
            ? Center(child: CircularProgressIndicator()) // Show loading until location is fetched
            : GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              controller.currentPosition.value!.latitude,
              controller.currentPosition.value!.longitude,
            ),
            zoom: 10, // Adjust the zoom level as needed
          ),
          markers: controller.markers.toSet(),
          polylines: controller.polylines.toSet(),
          onMapCreated: (GoogleMapController mapController) {
            controller.mapController = mapController;
            controller.mapController!.animateCamera(
              CameraUpdate.newLatLng(
                LatLng(
                  controller.currentPosition.value!.latitude,
                  controller.currentPosition.value!.longitude,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
