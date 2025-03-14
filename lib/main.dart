import 'package:bkjs_sales/src/utils/messenger/messenger.dart';
import 'package:bkjs_sales/src/utils/router/router.dart';
import 'package:bkjs_sales/src/view/splashscreen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: Messenger.rootScaffoldMessengerKey,
      navigatorKey: MyRouter.navigatorKey,
      home: SplashScreen(),
    );
  }
}
