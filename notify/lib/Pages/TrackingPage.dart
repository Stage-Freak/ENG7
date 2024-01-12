import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingPage extends StatefulWidget {
  final LatLng selectedLocation;
  const TrackingPage({Key? key, required this.selectedLocation})
      : super(key: key);

  @override
  _TrackingPageState createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveMapToSelectedLocation(); // Call after the first frame is rendered
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Tracking Page",
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
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _buildMap(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: widget.selectedLocation,
        zoom: 17,
        // Just pass the callback without invoking it
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

  void _moveMapToSelectedLocation() {
    if (widget.selectedLocation != null) {
      _mapController.move(widget.selectedLocation, 17);
      _addMarker(widget.selectedLocation);
    } else {
      // Handle the case where selectedLocation is null
      print("Selected location is null. Cannot move map.");
      // Consider displaying a default location or an error message here.
    }
  }

  void _addMarker(LatLng location) {
    _markers.add(
      Marker(
          point: location,
          child: Column(
            children: [
              Expanded(
                // Wrap the Icon in Expanded
                child: Icon(
                  Icons.location_pin,
                  size: 40.0,
                  color: Colors.red,
                ),
              ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    _mapController
        .dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }
}
