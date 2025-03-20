
import 'dart:async';

import 'package:bkjs_sales/src/utils/router/router.dart';
import 'package:bkjs_sales/src/view/homescreen.dart';
import 'package:bkjs_sales/src/view/registration.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 4)); 

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? staffId = prefs.getInt('staff_id');

    if (staffId != null) {
      MyRouter.pushReplace(
        screen: const HomeScreen(url: 'https://sales.bhangarukalasam.com'),
      );
    } else {
      MyRouter.pushReplace(screen: const RegistrationScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/splash.png', 
          fit: BoxFit.cover, 
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
