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
    _checkPermissions();
  }

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

  void startLocationUpdates() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
          setState(() {
            latitude = position.latitude;
            longitude = position.longitude;
          });

          log("Updated Location: $latitude, $longitude");
        })
        .catchError((e) {
          log("Error fetching location: $e");
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    log("App Lifecycle State: $state");
    if (state == AppLifecycleState.resumed) {
      startLocationUpdates();
      _checkPermissions();
      _startLocationUpdates();
    } else if (state == AppLifecycleState.paused) {
      _initializeBackgroundService();
    } else if (state == AppLifecycleState.detached) {
      _stopLocationUpdates();
    }
  }

  /// Checks & requests necessary permissions
  Future<bool> _checkPermissions() async {
    var locationWhenInUseStatus = await Permission.locationWhenInUse.status;
    var locationAlwaysStatus = await Permission.locationAlways.status;
    var cameraStatus = await Permission.camera.status;

    // Request location when in use permission if denied
    if (locationWhenInUseStatus.isDenied) {
      log("Requesting location (when in use) permission...");
      locationWhenInUseStatus = await Permission.locationWhenInUse.request();
    }

    // Request location always only if when-in-use is granted
    if (locationWhenInUseStatus.isGranted && locationAlwaysStatus.isDenied) {
      log("Requesting location always permission...");
      locationAlwaysStatus = await Permission.locationAlways.request();
    }

    // Request camera permission if denied
    if (cameraStatus.isDenied) {
      log("Requesting camera permission...");
      cameraStatus = await Permission.camera.request();
    }

    // Handle permanently denied permissions
    if (locationWhenInUseStatus.isPermanentlyDenied ||
        locationAlwaysStatus.isPermanentlyDenied ||
        cameraStatus.isPermanentlyDenied) {
      log(
        "Some permissions are permanently denied. Redirecting to settings...",
      );
      openAppSettings();
      return false;
    }

    // Check if all permissions are granted
    bool allGranted = locationAlwaysStatus.isGranted && cameraStatus.isGranted;

    if (allGranted) {
      log("All required permissions granted.");
    } else {
      log("Permissions still denied.");
    }

    return allGranted;
  }

  /// Initializes the background service only if permissions are granted
  Future<void> _initializeBackgroundService() async {
    if (isServiceRunning) return;
    isServiceRunning = true;

    // Ensure permissions before starting the service
    bool hasPermissions = await _checkPermissions();
    if (!hasPermissions) return;

    log("Starting background service...");

    // Configure the background service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        isForegroundMode: true,
        //  notificationChannelId: "hidden_service",
        autoStartOnBoot: true,

        onStart: _onStart,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
    );

    _startLocationUpdates();
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

    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!isRunning) {
        timer.cancel();
        return;
      }
      log("Fetching Background Location...");
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        log("Background Location: ${position.latitude}, ${position.longitude}");
      } catch (e) {
        log("Error fetching location: $e");
      }
    });
  }

  /// Stops the background service
  Future<void> _stopBackgroundService() async {
    service.invoke("stop");
    isServiceRunning = false;
    log("Background service stopped.");
  }

  /// Starts location updates every 2 min
  void _startLocationUpdates() {
    // Cancel any existing timer to prevent multiple instances
    _locationTimer?.cancel();

    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (mounted) {
          setState(() {
            latitude = position.latitude;
            longitude = position.longitude;
          });
        }

        log("Updated Location: $latitude, $longitude");

        if (latitude != null && longitude != null) {
          // Ensure widget is still mounted before using context
          if (mounted) {
            await context.read<RegistrationProvider>().sendLocationUpdate(
              latitude: latitude!,
              longitude: longitude!,
            );
          }
        }
      } catch (e) {
        log("Error fetching location: $e");
      }
    });
  }

  /// Stops location updates
  void _stopLocationUpdates() {
    _positionStream?.cancel();
    _positionStream = null;
    log("Stopped Location Updates");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLocationUpdates();
    _stopBackgroundService();
    _locationTimer?.cancel();
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
