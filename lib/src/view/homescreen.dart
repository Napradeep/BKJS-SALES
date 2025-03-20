


import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:bkjs_sales/src/provider/registerprovider/registerprovider.dart';
import 'package:bkjs_sales/src/utils/const/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
  StreamSubscription<Position>? _positionStream;
  final service = FlutterBackgroundService();
  Timer? _locationTimer;
  double? latitude;
  double? longitude;

  bool isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeWebView();
    _requestPermissions();
  }

  /// Initializes WebView with JavaScript enabled
  void _initializeWebView() {
    _controller =
        WebViewController()
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

  /// Requests necessary permissions and starts location tracking
  Future<void> _requestPermissions() async {
    var locationStatus = await Permission.locationAlways.request();
    var cameraStatus = await Permission.camera.request();

    if (locationStatus.isGranted && cameraStatus.isGranted) {
      log("Permissions granted.");
      _startLocationUpdates();
      _initializeBackgroundService();
    } else if (locationStatus.isPermanentlyDenied ||
        cameraStatus.isPermanentlyDenied) {
      log("Permissions permanently denied. Redirecting to settings...");
      openAppSettings();
    } else {
      log("One or more permissions denied.");
    }
  }

  /// Handles app lifecycle changes for background execution
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("App Lifecycle State: $state");
    if (state == AppLifecycleState.resumed) {
      _startLocationUpdates();
    } else if (state == AppLifecycleState.paused) {
      _initializeBackgroundService();
    } else if (state == AppLifecycleState.detached) {
      _stopLocationUpdates();
    }
  }

  /// Initializes and configures background service
  Future<void> _initializeBackgroundService() async {
    if (isServiceRunning) return;
    isServiceRunning = true;

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        isForegroundMode: true,
        autoStartOnBoot: true,
        onStart: _onStart,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );
  }

  /// Background execution function for iOS
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  /// Background execution function for Android/iOS
  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    bool isRunning = true;

    service.on("stop").listen((event) {
      service.stopSelf();
      isRunning = false;
      log("Background service stopped.");
    });

    Timer.periodic(const Duration(minutes: 2), (timer) async {
      if (!isRunning) {
        timer.cancel();
        return;
      }
      log("Background location tracking...");
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    });
  }

  /// Stops the background service
  Future<void> _stopBackgroundService() async {
    service.invoke("stop");
    isServiceRunning = false;
    log("Background service stopped.");
  }

  /// Starts location updates every 2 minutes
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

  /// Stops location updates
  void _stopLocationUpdates() {
    _positionStream?.cancel();
    _locationTimer?.cancel();
    log("Stopped Location Updates");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationUpdates();
    _stopBackgroundService();
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
