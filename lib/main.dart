import 'package:flutter/material.dart';
import 'package:mapapp/custom_marker_with_info_window.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Renegan - Police',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const CustomMarkerInfoWindowScreen(),
    );
  }
}
