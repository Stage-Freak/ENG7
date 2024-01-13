import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // Import for timers
import 'dart:convert';

class CurrentLocationMapPage extends StatefulWidget {
  const CurrentLocationMapPage({Key? key}) : super(key: key);
  @override
  _CurrentLocationMapPageState createState() => _CurrentLocationMapPageState();
}

class _CurrentLocationMapPageState extends State<CurrentLocationMapPage> {
  MapController _mapController = MapController();
  LatLng? _currentLocation;
  List<Marker> _markers = [];
  late Timer _locationUpdateTimer;
  LatLng? _previousLocation;
  bool _notificationSent = false;
  var diatanceFromUserLocation = 0.00;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Initial location retrieval
    _locationUpdateTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) async {
          await _getCurrentLocation();
          _sendLocationToFirestore(_currentLocation!);
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

      if (_previousLocation == null ||
          _hasMovedSignificantly(newLocation, _previousLocation!)) {
        setState(() {
          _currentLocation = newLocation;
          _markers.clear(); // Clear existing markers
          _addMarker(_currentLocation!);
          Future.microtask(() => _mapController.move(_currentLocation!, 17));
        });
        _sendLocationToFirestore(_currentLocation!);
        _previousLocation = newLocation;
      }

      // Fetch current location from Firestore (only once after location retrieval)
      FirebaseFirestore.instance
          .collection('CurrentLocationDatabase')
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final latitude = doc['additionalData']['SelectLatitude'];
          final longitude = doc['additionalData']['SelectLongitude'];
          final fetchedLocation = LatLng(latitude, longitude);

          // Calculate distance (only once)
          _calculateDistance(fetchedLocation);
        } else {
          print("No current location data found in Firestore");
        }
      });
    } catch (error) {
      // Handle the error
    }
  }



  void _calculateDistance(LatLng fetchedLocation) {
    final distanceInMeters =
    Distance().distance(_currentLocation!, fetchedLocation);
    diatanceFromUserLocation =distanceInMeters;
    print('Distance: ${distanceInMeters.toStringAsFixed(2)} meters');

    if (distanceInMeters <= 500 && !_notificationSent) {
      _sendNotification();
      _notificationSent = true; // Set the flag to true after sending the notification
    }
  }

  bool _hasMovedSignificantly(LatLng newLocation, LatLng oldLocation) {
    final distanceInMeters = Geolocator.distanceBetween(
      newLocation.latitude,
      newLocation.longitude,
      oldLocation.latitude,
      oldLocation.longitude,
    );
    return distanceInMeters >= 10; // Adjust the threshold as needed
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

  void _sendNotification() async {
    print('Notification Sent');
    List<String> tokens =  [
      'dbcjdbcdsjcbjsdbcjbdsjcbjdbcjbfvconcdsncbidbckdsnckdscjbjsbdjvbjdbcjdbvjbdjvcbjbvjbcjbdjcvbjbvjbvjfdbvjbdvjbfjdvbjbvjdbvjdjvbjfdvbjdbvj',
      'cPTtS_1zTxKIoCwyxA_Cv6:APA91bEBvLK7lkAMoXR3_TXBaqIMmXPM2J8h2HnCQy2aig2xHSqstd4Wq8F288PaOH3r86V3PElKDFeQShZDU-Tt5CEhhv0gvfoYYD6LWC0KYhx2-5acof1USZah8FRZgdOWE8-m4V03',
      'fCN-9gBHSCurUdH0mubBnm:APA91bF6tQXyiH0-qj6xig1yOILKyWhtXJGh5W-wlvHS6EstMhnFWrcPlqCej8Iyalz36owJYOu2lkl6vgWoat74vbUSla2N7CO0GrvwpnUoLMq-ucLi5YF2bwOLq2jQMbps917uIFnS',
      'fvJXr7ViSyaYs0JPTsXxxd:APA91bEbun0aZqbBPsqZwsXNoo0pTDGlNg9_z7M3HPAQKzPL2d1Wcp2WHMcjmp-Q2ZVUHFyQv-177yyz9VQ3sWPqTeopsBOZroMwOb5glT1jFcDH1TmcnIPJ60JZeG-yhphkmk7-B0oU'
    ];

    await Future.forEach(tokens, (String token) async {
      print(token);
      var data = {
        'to': token,
        'priority': 'high',
        'notification': {
          'title': 'Pickup Truck is nearby you.',
          'body':
          'Garbage pickup truck is $diatanceFromUserLocation meters away from you.',
        },
      };

      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization':
          'key=AAAARfaUx0c:APA91bHgHAhID9O6SitasqynYPSqZEW_LUPiOcDDBKs7yA7CfrEYnC45flZ_YxjwNOQPyzJkuYswEtjRpCGTHYEEd9pEB7IO0lCQ4c-WUB0dDKqI5NQc5VUKsGV27FTa9UHtsYu64mjb',
        },
      );
    });

  }
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