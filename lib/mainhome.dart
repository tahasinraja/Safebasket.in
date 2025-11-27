import 'package:flutter/material.dart';

import 'package:safbasketapp/fastfoods.dart';
import 'package:safbasketapp/homepage.dart';
import 'package:safbasketapp/nonveg.dart';

import 'package:safbasketapp/veg.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
     VegPage(),
      FastFoodPage(),
      NonVegPage()
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

    );
  }
}
