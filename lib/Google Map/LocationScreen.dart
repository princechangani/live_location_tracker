import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // late GoogleMapController googleMapController;

  // static const CameraPosition initialCameraPosition=CameraPosition(target: LatLng(22.28529405224105, 70.79233636331122),zoom: 14);

  // Set<Marker> markers={};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
        backgroundColor: Colors.white,
      ),
      // body: GoogleMap(initialCameraPosition: initialCameraPosition,markers:  markers,zoomControlsEnabled: true,mapType: MapType.normal,onMapCreated: (GoogleMapController controller) {
      //   googleMapController=controller;
      // },),
    );
  }
}
