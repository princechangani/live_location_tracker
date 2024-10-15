import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

class MyGoogleMapController extends GetxController {



  GoogleMapController? googleMapController;


  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('locations');

  var currentLocationMarker = Marker(
    markerId: MarkerId('currentLocation'),
    position: LatLng(0, 0),
    infoWindow: InfoWindow(title: "Current Location"),
  ).obs;

  StreamSubscription<Position>? positionStream;
  StreamSubscription<Position>? permissionStream;

  final List<LatLng> polygonCoordinates = [
    LatLng(22.28584709905549, 70.79243953422272) ,//point 1
    LatLng(22.285953119244954, 70.7928654795932), //point 2
    LatLng(22.285659775053606, 70.79327710046273), //point 3
    LatLng(22.285254806987506, 70.79269448687344) ,//point 4

  ];

  final List<Polygon> polygons = [];

  @override
  void onInit() {
    super.onInit();
    _initializePolygons();

    _listenToRealtimeDatabase();
  }

  List<LatLng> convexHull(List<LatLng> points) {
    points.sort((a, b) {
      if (a.latitude == b.latitude) {
        return a.longitude.compareTo(b.longitude);
      }
      return a.latitude.compareTo(b.latitude);
    });

    // Build lower hull
    List<LatLng> lower = [];
    for (LatLng p in points) {
      while (lower.length >= 2 && _cross(lower[lower.length - 2], lower[lower.length - 1], p) <= 0) {
        lower.removeLast();
      }
      lower.add(p);
    }

    // Build upper hull
    List<LatLng> upper = [];
    for (int i = points.length - 1; i >= 0; i--) {
      LatLng p = points[i];
      while (upper.length >= 2 && _cross(upper[upper.length - 2], upper[upper.length - 1], p) <= 0) {
        upper.removeLast();
      }
      upper.add(p);
    }

    // Remove the last point of each half because it's repeated at the beginning of the other half
    upper.removeLast();
    return lower + upper; // Concatenate lower and upper hull
  }
  List<LatLng> orderedPoints(List<LatLng> points) {
    List<LatLng> hull = [];

    // Sort points by latitude and longitude
    points.sort((a, b) {
      if (a.latitude == b.latitude) {
        return a.longitude.compareTo(b.longitude);
      }
      return a.latitude.compareTo(b.latitude);
    });


    for (LatLng p in points) {
      while (hull.length >= 2 && _cross(hull[hull.length - 2], hull[hull.length - 1], p) <= 0) {
        hull.removeLast();
      }
      hull.add(p);
    }

    // Upper hull
    int lowerHullSize = hull.length;
    for (int i = points.length - 1; i >= 0; i--) {
      LatLng p = points[i];
      while (hull.length > lowerHullSize && _cross(hull[hull.length - 2], hull[hull.length - 1], p) <= 0) {
        hull.removeLast();
      }
      hull.add(p);
    }
    hull.removeLast();
    Set<LatLng> hullSet = hull.toSet();
    for (LatLng p in points) {
      if (!hullSet.contains(p)) {
        hull.add(p);
      }
    }

    return hull;
  }

  double _cross(LatLng o, LatLng a, LatLng b) {
    return (a.longitude - o.longitude) * (b.latitude - o.latitude) -
        (a.latitude - o.latitude) * (b.longitude - o.longitude);
  }



  void _initializePolygons() {
    final List<LatLng> sortedCoordinates = orderedPoints(polygonCoordinates);

    polygons.add(Polygon(
      polygonId: PolygonId('dynamicZone'),
      points: sortedCoordinates,
      strokeColor: Colors.red,
      strokeWidth: 3,
      fillColor: Colors.red.withOpacity(0.5),
    ));
  }



  @override
  void onClose() {
    googleMapController?.dispose();
    positionStream?.cancel();
    permissionStream?.cancel();
    super.onClose();
  }

  void onMapCreated(GoogleMapController controller) {
    googleMapController = controller;
    _startTrackingLocation();
    googleMapController?.animateCamera(
      CameraUpdate.newLatLng(currentLocationMarker.value.position),
    );
  }

  void _startTrackingLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permission is denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Error", "Location permissions are permanently denied.");
      return;
    }


    positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((Position position) {
      LatLng currentLatLng = LatLng(position.latitude,position.longitude);

      currentLocationMarker.value = Marker(
        markerId: MarkerId('currentLocation'),
        position: currentLatLng,
        infoWindow: InfoWindow(title: "Current Location"),
      );

      googleMapController?.animateCamera(
        CameraUpdate.newLatLng(currentLatLng),
      );
      if(currentLatLng == LatLng(0.0,0.0)  ){
        _saveLocationToRealtimeDatabase(currentLatLng);
      }
      else{
        _updateLocationToRealtimeDatabase(currentLatLng);
      }
      _checkIfUserInZone(currentLatLng);
    });
  }

  void _saveLocationToRealtimeDatabase(LatLng location) {
    databaseRef.child("userLocation").set({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      print("Location saved to Realtime Database");
    }).catchError((error) {
      print("Failed to save location: $error");
    });
  }
  void _updateLocationToRealtimeDatabase(LatLng location) {
    databaseRef.child("userLocation").update({
      'latitude': location.latitude,
      'longitude': location.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }).then((_) {
      print("Location updated in Realtime Database");
    }).catchError((error) {
      print("Failed to update location: $error");
    });
  }

  void _checkIfUserInZone(LatLng userLocation) {
    final List<LatLng> sortedCoordinates = convexHull(polygonCoordinates);
    bool isInside = _isPointInPolygon(userLocation,sortedCoordinates);
    if (isInside) {
      _showZoneAlert();
    }
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    for (int i = 0; i < polygon.length; i++) {
      LatLng p1 = polygon[i];
      LatLng p2 = polygon[(i + 1) % polygon.length];

      if (((p1.latitude > point.latitude) != (p2.latitude > point.latitude)) &&
          (point.longitude < (p2.longitude - p1.longitude) * (point.latitude - p1.latitude) /
              (p2.latitude - p1.latitude) + p1.longitude)) {
        intersections++;
      }
    }
    return (intersections % 2) == 1;
  }
  void _listenToRealtimeDatabase() {
    databaseRef.onValue.listen((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        data.forEach((key, value) {
          final double latitude = value['latitude'];
          final double longitude = value['longitude'];
          LatLng receivedLocation = LatLng(latitude, longitude);
          print("Received location: $receivedLocation");
          googleMapController?.animateCamera(
            CameraUpdate.newLatLng(receivedLocation),
          );
        });
      }
    });
  }

  void _showZoneAlert() {
    Get.defaultDialog(
      title: "Zone Alert",
      middleText: "You have entered the predefined zone!",
      textConfirm: "OK",
      onConfirm: () {
        Get.back();
      },
    );
  }
}
