import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  final String url;
  const HomeScreen({super.key, required this.url});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late WebViewController _controller;
  StreamSubscription<Position>? _positionStream;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(widget.url));

    _requestPermissions();
  }

  // Handle App Lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("App Lifecycle State: $state");
    if (state == AppLifecycleState.resumed) {
      _startLocationUpdates();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopLocationUpdates();
    }
  }

  // Request permissions for Location and Camera
  Future<void> _requestPermissions() async {
    var locationStatus = await Permission.locationWhenInUse.request();
    var cameraStatus = await Permission.camera.request();

    if (locationStatus.isGranted && cameraStatus.isGranted) {
      log("Permissions granted.");
      _startLocationUpdates();
    } else {
      log("One or more permissions denied.");
      openAppSettings(); // Opens the app settings if permissions are denied permanently
    }
  }

  // Start Location Updates
  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
      log("Updated Location: $latitude, $longitude");
    });
  }

  // Stop Location Updates
  void _stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
    log("Stopped Location Updates");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'BKJS SALES',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          // if (latitude != null && longitude != null)
          //   Padding(
          //     padding: const EdgeInsets.all(10),
          //     child: Text("Latitude: $latitude, Longitude: $longitude"),
          //   ),
        ],
      ),
    );
  }
}
