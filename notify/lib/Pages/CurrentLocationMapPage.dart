import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

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
        title: Text('Current Location Map'),
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
      _currentLocation = LatLng(position.latitude, position.longitude);
      _addMarker(_currentLocation!);
      _mapController.move(_currentLocation!, 17);
    });
  }

  void _addMarker(LatLng location) {
    _markers.add(
      Marker(
        point: location,
        child: Column(
          children: [
            Expanded(
              child: Icon(
                Icons.location_pin,
                size: 40.0,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
