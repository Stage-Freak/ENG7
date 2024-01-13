import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:notify/Pages/primary_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TrackingPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  LatLng? _selectedLocation;
  MapController _mapController = MapController();
  List<Marker> _markers = [];
  String? _placeName;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      try {
        final Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        await _getPlaceName(position.latitude, position.longitude);

        setState(() {
          _currentPosition = position;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          _flyToCurrentLocation();
        });
      } catch (e) {
        print("Error: $e");
      }
    } else {
      print("Location permission denied");
    }
  }

  Future<void> _getPlaceName(double latitude, double longitude) async {
    final String apiKey =
        'pk.eyJ1Ijoic3RhZ2VmcmVhayIsImEiOiJjbHI1M3ZreDAxbWtwMmt0YTd5b3AwMWo5In0.k9jmtjdZz8LBPuwRblKUmw'; // Replace with your Mapbox API key
    final String apiUrl =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json';

    final response = await http.get(
      Uri.parse('$apiUrl?access_token=$apiKey'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('features') && data['features'].isNotEmpty) {
        final String placeName = data['features'][0]['place_name'];
        print('Place Name: $placeName');

        setState(() {
          _placeName = placeName;
        });
      } else {
        print('No place name found for the given coordinates.');
      }
    } else {
      print('Error: ${response.statusCode}, ${response.reasonPhrase}');
    }
  }

  void _onMapTapped(LatLng tappedPoint) async {
    setState(() {
      _selectedLocation = tappedPoint;
      _placeName = null; // Reset placeName when a new location is selected
      _markers.clear();
      // Add a marker for the selected location using FlutterMap's Marker class
      _markers.add(
        Marker(
          point: _selectedLocation!,
          child: Column(
            children: [
              Icon(
                Icons.location_pin,
                size: 30.0,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      );
    });

    // Get the place name for the selected location
    await _getPlaceName(
        _selectedLocation!.latitude, _selectedLocation!.longitude);
    // Update the UI with the fetched place name
    setState(() {
      // Now _placeName has been updated, and the UI will be rebuilt
    });
  }

  void _handleMapTap(TapPosition tapPosition, LatLng tappedLocation) {
    _onMapTapped(tappedLocation);
  }


  void _flyToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16.5,
      );
    }
  }

  // ADD MARKERS INTO THE MAP
  void _useCurrentLocation() {
    if (_currentPosition != null) {
      setState(() {
        _selectedLocation = LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );

        // Clear existing markers
        _markers.clear();

        // Add a marker for the current location using FlutterMap's Marker class
        _markers.add(
          Marker(
            point: _selectedLocation!,
            child: Column(
              children: [
                Icon(
                  Icons.location_pin,
                  size: 30.0,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        );

        _flyToCurrentLocation();
      });
    }
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : const LatLng(27.673672160292725, 85.32507835333786),
        zoom: 17,
        onTap: _handleMapTap, // Just pass the callback without invoking it
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

  String? get selectedPlaceName => _placeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pickup location",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
            fontFamily: 'Judson',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF98C28C),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height,
            width: MediaQuery
                .of(context)
                .size
                .width,
            child: _buildMap(),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 500.0, left: 340),
            child: FloatingActionButton(
              onPressed: _useCurrentLocation,
              backgroundColor: Colors.grey[400],
              child: Tooltip(
                message: 'Current Location',
                child: Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              shape: CircleBorder(
                side: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 570.0),
            child: Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  color: Colors.white70,
                ),
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: 200,
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  children: [
                    //PrimaryButton(onTap:  _useCurrentLocation, buttonText: 'Use Current Location'),
                    const SizedBox(height: 10),
                    const Text("Use Current Location ",
                        style: TextStyle(fontFamily: 'Judson', fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const Text("Or tap in preferred location for new location",
                        style: TextStyle(fontFamily: 'Judson',
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    _placeName != null
                        ? Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20, top: 10, bottom: 15),
                      child: Text(
                        "Selected Location: $_placeName",
                        style: const TextStyle(
                            fontFamily: 'Judson',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                        : Container(),
                    PrimaryButton(
                        onTap: () {
                          CollectionReference collRef =
                          FirebaseFirestore.instance.collection('CurrentLocationDatabase');
                           collRef.add({
                            'UploadTime': Timestamp.fromDate(DateTime.now()),
                            'additionalData': {
                              'SelectLatitude': _selectedLocation!.latitude,
                              'SelectLongitude': _selectedLocation!.longitude,
                            },
                          });
                          print('Location and additional data added to Firestore: $_selectedLocation');

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackingPage(selectedLocation: _selectedLocation!),
                            ),
                          );
                        }, buttonText: 'Continue with location')
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
