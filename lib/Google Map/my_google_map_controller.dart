import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_location_tracker/Google%20Map/Repo.dart';

class MyGoogleMapController extends GetxController {
  GoogleMapController? mapController;
  final Set<Marker> markers = <Marker>{}.obs;
  Rxn<Position> currentPosition = Rxn<Position>();
  Rx<LatLng> destinationPosition = LatLng(22.7749, 70.4194).obs;
  final Set<Polyline> polylines = <Polyline>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchCurrentPosition();
  }

  Future<void> _fetchCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(

      );

      currentPosition.value = position;
      _addMarkers();
      _fetchRoute();

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(currentPosition.value!.latitude, currentPosition.value!.longitude),
          ),
        );
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  void _addMarkers() {
    if (currentPosition.value != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentPosition'),
          position: LatLng(currentPosition.value!.latitude, currentPosition.value!.longitude),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('destinationPosition'),
          position: destinationPosition.value,
        ),
      );
    }
  }

  Future<void> _fetchRoute() async {
    if (currentPosition.value != null && destinationPosition.value != null) {
      try {
        PolylineResult? result = await Repo.getRouteBetweenTwoPoints(
          start: LatLng(currentPosition!.value!.latitude, currentPosition!.value!.longitude),
          end: destinationPosition.value,
          color: Colors.blue,
        );

        if (result != null && result.points.isNotEmpty) {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: result.points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
              color: Colors.blue,
              width: 5,
            ),
          );
        } else {
          throw Exception('No route found.');
        }
      } catch (e) {
        print("Error fetching route: $e");
      }
    }
  }
}
