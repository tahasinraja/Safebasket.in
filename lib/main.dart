import 'package:flutter/material.dart';
import 'package:safbasketapp/homepage.dart';

import 'package:shared_preferences/shared_preferences.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Check login status before running app
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safebasket',
      debugShowCheckedModeBanner: false,
      // ✅ Decide start screen based on login status
    //  home: AboutPage(),
      home: HomePage()
    );
  }
}
