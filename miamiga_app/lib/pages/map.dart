// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CurrentLocationScreen extends StatefulWidget {
  
  const CurrentLocationScreen({super.key});

  @override
  State<CurrentLocationScreen> createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> with WidgetsBindingObserver{
  final BitmapDescriptor customMarker = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueGreen,
  );

  LatLng selectedLatLng = LatLng(initialCameraPosition.target.latitude, initialCameraPosition.target.longitude);
  late GoogleMapController googleMapController;
  Set<Marker> markers = {};
  LatLng selectedLocation = initialCameraPosition.target;

  bool inSelectionMode = true;

  @override
  void initState() {
    super.initState();
    _getLocationAndSetCameraPosition();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    googleMapController.dispose();
    super.dispose();
  }

  Future<void> _getLocationAndSetCameraPosition() async {
    Position? position;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show a dialog to enable location services
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return Future.error('Permisos de ubicación denegados.');
        }
      }

      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print('Error obteniendo ubicación actual: $e');
    }

    if (position != null) {
      if (mounted) { // Check if the widget is still in the widget tree
        setState(() {
          initialCameraPosition = CameraPosition(
            target: LatLng(position!.latitude, position.longitude),
            zoom: 14,
          );
          selectedLatLng = LatLng(position.latitude, position.longitude);
          markers.clear();
          markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: selectedLatLng,
              icon: BitmapDescriptor.defaultMarker,
            ),
          );
        });
      }
    }
  }

  // Show a dialog to enable location services
  Future<void> _showLocationServiceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Servicios de ubicación deshabilitados'),
          content: const Text('Por favor habilite los servicios de ubicación en tus configuraciones.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              child: const Text(
                'Abrir configuraciones',
                style: TextStyle(
                  color: Color.fromRGBO(255, 87, 110, 1),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App has come to the foreground
      _getLocationAndSetCameraPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          googleMapController = controller;
        },
        onTap: (latLng) {
          _onMarkerTrapped(latLng);
        },
      ),
      floatingActionButton: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
          FloatingActionButton.extended(
            heroTag: 'currentLocation',
            onPressed: () {
              final selectedLocation = {
                'latitude': markers.first.position.latitude,
                'longitude': markers.first.position.longitude,
              };
              Navigator.of(context).pop(selectedLocation);
            },
            label: inSelectionMode
              ? const Text('Confirmar')
              : const Text('Confirmado'),
            icon: const Icon(Icons.check),
            backgroundColor: Colors.green,
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'cancel',
            onPressed: () {
              // Cancel button action
              Navigator.of(context).pop();
            },
            label: const Text('Cancelar'),
            icon: const Icon(Icons.cancel),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  void _onMarkerTrapped(LatLng latLng) {
    setState(() {
      selectedLatLng = latLng;
    });
    _updateMarkerLocation(selectedLatLng);
  }

  void _updateMarkerLocation(LatLng selectedLatLng) {
    setState(() {
      selectedLocation = selectedLatLng;
    });
    markers.clear();
    markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: selectedLocation,
        icon: customMarker,
      ),
    );
  }
}

CameraPosition initialCameraPosition = const CameraPosition(
  target: LatLng(-17.38414, -66.16670),
  zoom: 14,
);
