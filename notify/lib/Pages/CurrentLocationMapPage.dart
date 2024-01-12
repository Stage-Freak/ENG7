import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Import for timers

class CurrentLocationMapPage extends StatefulWidget {
  const CurrentLocationMapPage({Key? key}) : super(key: key);

  @override
  _CurrentLocationMapPageState createState() => _CurrentLocationMapPageState();
}

class _CurrentLocationMapPageState extends State<CurrentLocationMapPage> {
  MapController _mapController = MapController();
  LatLng? _currentLocation;
  LatLng? _previousLocation; // Track previous location
  List<Marker> _markers = [];
  late Timer _locationUpdateTimer;
  final double _significantDistanceThreshold = 10; // Adjust as needed

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Initial location retrieval
    _locationUpdateTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) async {
          await _getCurrentLocation();
        });
  }

  @override
  void dispose() {
    _locationUpdateTimer.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Current Location Map",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            fontFamily: 'Judson',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF98C28C),
      ),
      body: FutureBuilder<void>(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildMap();
          } else {
            return Center(
                child: CircularProgressIndicator()); // Show loading indicator
          }
        },
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentLocation ?? LatLng(0, 0),
        zoom: 17,
      ),
      children: [
        TileLayer(
          urlTemplate:
          'https://api.mapbox.com/styles/v1/stagefreak/cljl3ez7l008401qwdg1u89zc/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3RhZ2VmcmVhayIsImEiOiJjbHI1M3ZreDAxbWtwMmt0YTd5b3AwMWo5In0.k9jmtjdZz8LBPuwRblKUmw',
          additionalOptions: const {
            'accessTokens':
            'pk.eyJ1Ijoic3rhZ2VmcmVhayIsImEiOiJja3R6Nzh2ZHYwMWd5MnVtazN1YXp5ZDZ3In0.cZqEKOJbBfQYWYF8hbJlcw',
            'id': 'mapbox.mapbox-streets-v8',
          },
        ),
        MarkerLayer(
          markers: _markers,
        ),
      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newLocation = LatLng(position.latitude, position.longitude);

      // Only update if location has changed significantly
      if (_previousLocation == null ||
          _hasMovedSignificantly(_previousLocation!, newLocation)) {
        setState(() {
          _currentLocation = newLocation;
          _addMarker(_currentLocation!);
          Future.microtask(() => _mapController.move(_currentLocation!, 17));
        });
        _sendLocationToFirestore(_currentLocation!);
        _previousLocation = newLocation; // Update previous location
      }
    } catch (error) {
      // Handle the error
    }
  }

  bool _hasMovedSignificantly(LatLng oldPosition, LatLng newPosition) {
    // Calculate distance between positions and compare to threshold
    final distanceInMeters = Geolocator.distanceBetween(
      oldPosition.latitude,
      oldPosition.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );
    return distanceInMeters >= _significantDistanceThreshold;
  }

  void _addMarker(LatLng location) {
    _markers.add(
      Marker(
        point: location,
        child: const Image(
          image: AssetImage('assets/images/garbage-truck.png'),
          height: 80,
          width: 80,
        ),
      ),
    );
  }

  void _sendLocationToFirestore(LatLng location) async {
    print('Send location function called');
    try {
      // Replace 'Collector' with your actual collection name
      CollectionReference collRef =
      FirebaseFirestore.instance.collection('locationDatabase');
      await collRef.add({
        'pickupDateTime': Timestamp.fromDate(DateTime.now()),
        'additionalData': {
          'Latitude': location.latitude,
          'Longitude': location.longitude,
        },
      });
      print('Location and additional data added to Firestore: $location');
    } catch (e) {
      print('Error adding location to Firestore: $e');
    }
  }
}
