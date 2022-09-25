import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Google Maps Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => MapCurrentViewPage(),
      },
    );
  }
}

class MapCurrentViewPage extends StatefulWidget {
  const MapCurrentViewPage({Key? key}) : super(key: key);

  @override
  State<MapCurrentViewPage> createState() => _MapCurrentViewPageState();
}

class _MapCurrentViewPageState extends State<MapCurrentViewPage> {
  static const CameraPosition _initialCameraPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  Set<Marker> _marker = {};

  late GoogleMapController googleMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Current Page"),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialCameraPosition,
        markers: _marker,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _position();
          googleMapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          )));

          _marker.clear();

          _marker.add(Marker(
              markerId: MarkerId("Location"),
              position: LatLng(position.latitude, position.longitude)));

          setState(() {});
        },
        label: const Text("Location"),
        icon: Icon(Icons.location_on),
      ),
    );
  }

  Future<Position> _position() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
