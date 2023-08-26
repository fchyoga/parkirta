import 'package:flutter/material.dart';
import 'package:parkirta/auth/splash.dart';
import 'package:parkirta/pelanggan/app.dart';
import 'package:parkirta/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MainApp(isLoggedIn: isLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (isLoggedIn) {
      home = MyApp();
    } else {
      home = const SplashPage();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parkirta',
      theme: ThemeData(
        primaryColor: Red50,
      ),
      home: home,
    );
  }
}
