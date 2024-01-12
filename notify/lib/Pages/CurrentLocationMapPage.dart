import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentLocationMapPage extends StatefulWidget {
  const CurrentLocationMapPage({Key? key}) : super(key: key);
  @override
  _CurrentLocationMapPageState createState() => _CurrentLocationMapPageState();
}

class _CurrentLocationMapPageState extends State<CurrentLocationMapPage> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<Marker> _markers = [];

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
      body: FutureBuilder(
        future: _getCurrentLocation(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildMap();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
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
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      print('Set state called');
      _currentLocation = LatLng(position.latitude, position.longitude);
      _addMarker(_currentLocation!);
      _mapController.move(_currentLocation!, 17);
      _sendLocationToFirestore(_currentLocation!); // Send location to Firestore
    });
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
      CollectionReference collRef = FirebaseFirestore.instance.collection('locationDatabase');
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


  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
