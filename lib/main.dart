import 'package:flutter/material.dart';

import 'package:d3h1blog/pages/main/main.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: homeContent(context),
      ),
    );
  }
}