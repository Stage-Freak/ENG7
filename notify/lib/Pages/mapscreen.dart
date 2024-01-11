import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      _selectedLocation = tappedPoint;
      _placeName = _placeName;
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
                color: Colors.blue,
              ),
            ],
          ),
        ),
      );
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
      body: Column(
        children: [
          Container(
            height: 0.75 * MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _buildMap(),
          ),
          Expanded(
            child: Container(
              color: const Color(0xff98c28c),
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top:8),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _useCurrentLocation,
                    child: Text('Use Current Location'),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(150, 40)),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Or choose location from the map above"),
                  SizedBox(height: 10),
                  _placeName != null
                      ? Text("Selected Location: $_placeName")
                      : Container(),
                  ElevatedButton(
                    onPressed: (){
                      // Navigator.push(context,
                      //     MaterialPageRoute(builder: (context) =>Tracking()));
                    },
                    child: Text('Continue with location'),
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(150, 40)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
