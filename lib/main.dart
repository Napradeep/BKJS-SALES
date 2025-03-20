import 'package:bkjs_sales/src/provider/registerprovider/registerprovider.dart';
import 'package:bkjs_sales/src/utils/messenger/messenger.dart';
import 'package:bkjs_sales/src/utils/router/router.dart';
import 'package:bkjs_sales/src/view/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? staffId = prefs.getInt('staff_id');

  runApp(MyApp(isRegistered: staffId != null));
}

class MyApp extends StatelessWidget {
  final bool isRegistered;
  const MyApp({super.key, required this.isRegistered});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => RegistrationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: Messenger.rootScaffoldMessengerKey,
        navigatorKey: MyRouter.navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
