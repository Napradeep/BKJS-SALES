
import 'dart:async';
import 'dart:developer';

import 'package:bkjs_sales/src/provider/registerprovider/registerprovider.dart';
import 'package:bkjs_sales/src/utils/const/color.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  final String url;
  const HomeScreen({super.key, required this.url});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late final WebViewController _controller;
  Timer? _locationTimer;
  double? latitude;
  double? longitude;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWebView();
    _checkPermissions();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log("WebView started loading: $url");
          },
          onPageFinished: (String url) {
            log("WebView finished loading: $url");
          },
          onWebResourceError: (error) {
            log("WebView error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _checkPermissions() async {
    var locationWhenInUseStatus = await Permission.locationWhenInUse.status;
    var locationAlwaysStatus = await Permission.locationAlways.status;
    var cameraStatus = await Permission.camera.status;

    if (locationWhenInUseStatus.isDenied) {
      log("Location (when in use) permission denied. Requesting...");
      locationWhenInUseStatus = await Permission.locationWhenInUse.request();
    }

    if (locationWhenInUseStatus.isGranted && locationAlwaysStatus.isDenied) {
      log("Requesting location always permission...");
      locationAlwaysStatus = await Permission.locationAlways.request();
    }

    if (cameraStatus.isDenied) {
      log("Camera permission denied. Requesting again...");
      cameraStatus = await Permission.camera.request();
    }

    if (locationWhenInUseStatus.isPermanentlyDenied ||
        locationAlwaysStatus.isPermanentlyDenied ||
        cameraStatus.isPermanentlyDenied) {
      log("Permission permanently denied. Redirecting to settings...");
      openAppSettings();
      return;
    }

    if (locationAlwaysStatus.isGranted && cameraStatus.isGranted) {
      log("Permissions granted.");
      _startLocationUpdates();
    } else {
      log("Permissions still denied.");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("App Lifecycle State: $state");
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    } else if (state == AppLifecycleState.detached) {
      _stopLocationUpdates();
    }
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
          .then((Position position) async {
            setState(() {
              latitude = position.latitude;
              longitude = position.longitude;
            });

            log("Updated Location: $latitude, $longitude");

            if (latitude != null && longitude != null) {
              await context.read<RegistrationProvider>().sendLocationUpdate(
                latitude: latitude!,
                longitude: longitude!,
              );
            }
          })
          .catchError((e) {
            log("Error fetching location: $e");
          });
    });
  }

  void _stopLocationUpdates() {
    _locationTimer?.cancel();
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: backgroundClr,
      ),
      body: Column(
        children: [Expanded(child: WebViewWidget(controller: _controller))],
      ),
    );
  }
}
