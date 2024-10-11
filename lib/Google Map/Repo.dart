import 'dart:ui';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Repo {
  Repo._();
  static  placeAutoComplete(
      {required String placeInput}) async {
    try {
      Map<String, dynamic> querys = {
        'input': placeInput,
        'key': "AIzaSyD5KT2GjTnovLF-JbbPLEf5kpvzIEvRWXc"
      };
      final url = Uri.https(
          "maps.googleapis.com", "maps/api/place/autocomplete/json", querys);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // return PredictionModel.fromJson(jsonDecode(response.body));
      } else {
        response.body;
      }
    } on Exception catch (e) {
      print(e.toString());
    }
    return null;
  }

  static Future<PolylineResult?> getRouteBetweenTwoPoints(
      {required LatLng start,
        required LatLng end,
        required Color color}) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult res = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: "AIzaSyCILYd8F2M7g95NQErBTZsXLmTD7baDBIw",
        request: PolylineRequest(origin:PointLatLng(start.latitude, start.longitude),destination: PointLatLng(end.latitude, end.longitude) , mode: TravelMode.driving) );
    if (res.points.isNotEmpty) {
      return res;
    } else {
      return null;
    }
  }
}