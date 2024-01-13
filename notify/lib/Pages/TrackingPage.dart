import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String? _fetchedLocationDocumentId;
  double _distanceInMeters = 0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moveMapToSelectedLocation();
      _fetchLocationFromFirestore();
      _fetchAndListenToFirestoreUpdates();
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
          Positioned(
            // Adjust positioning as needed
            bottom: 20,
            right: 20,
            child: Text(
              'Distance: ${_distanceInMeters.toStringAsFixed(2)} meters',
              style: TextStyle(fontSize: 18),
            ),
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

  void _addMarker(LatLng location, {bool isFetchedLocation = false}) {
    if (!_markers.any((marker) => marker.point == location)) {
      _markers.add(
        Marker(
          point: location,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: isFetchedLocation
                          ? Image.asset(
                              'assets/images/garbage-truck.png',
                              width: 50,
                              height: 50,
                            )
                          : Icon(Icons.location_pin,
                              size: 40.0, color: Colors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _fetchLocationFromFirestore() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('locationDatabase').get();

      final docs = querySnapshot.docs;
      if (docs.isNotEmpty) {
        final doc = docs.first; // Assuming there's only one document
        final data = doc.data() as Map<String, dynamic>;
        final latitude = data['additionalData']['Latitude'];
        final longitude = data['additionalData']['Longitude'];
        final fetchedLocation = LatLng(latitude, longitude);
        _addMarker(fetchedLocation,
            isFetchedLocation: true); // Add with specific style
      } else {
        print("No documents found in the collection");
      }
    } catch (error) {
      print("Error fetching location: $error");
    }
  }
  Future<void> _fetchAndListenToFirestoreUpdates() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('locationDatabase')
          .get();

      final docs = querySnapshot.docs;
      if (docs.isNotEmpty) {
        final doc = docs.first; // Assuming there's only one document
        _fetchedLocationDocumentId = doc.id; // Store the ID for listening

        final data = doc.data() as Map<String, dynamic>;
        final latitude = data['additionalData']['Latitude'];
        final longitude = data['additionalData']['Longitude'];
        final fetchedLocation = LatLng(latitude, longitude);
        _addMarker(fetchedLocation, isFetchedLocation: true);
        _calculateDistance();
        _listenToFirestoreUpdates(); // Start listening for changes
      } else {
        print("No documents found in the collection");
      }
    } catch (error) {
      print("Error fetching location: $error");
    }
  }

  void _calculateDistance() {
    if (_markers.length >= 2) {
      final selectedLocation = _markers[0].point;
      final fetchedLocation = _markers[1].point;
      _distanceInMeters = Distance().distance(selectedLocation, fetchedLocation);
      setState(() {}); // Update the UI
    }
  }

  void _listenToFirestoreUpdates() {
    FirebaseFirestore.instance
        .collection('locationDatabase')
        .doc(_fetchedLocationDocumentId) // Use the stored ID
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final latitude = data['additionalData']['Latitude'];
        final longitude = data['additionalData']['Longitude'];
        final updatedLocation = LatLng(latitude, longitude);

        // Remove any existing marker with the same coordinates
        _markers.removeWhere((marker) => marker.point == updatedLocation);

        _addMarker(updatedLocation, isFetchedLocation: true);
      } else {
        // Handle the case where the document no longer exists
      }
    });
  }

  @override
  void dispose() {
    _mapController
        .dispose(); // Dispose of the controller when the widget is disposed
    super.dispose();
  }
}
