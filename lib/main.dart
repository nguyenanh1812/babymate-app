import 'package:flutter/material.dart';

void main() {
  runApp(const BabyMateApp());
}

class BabyMateApp extends StatelessWidget {
  const BabyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyMate',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('BabyMate'),
        ),
      ),
    );
  }
}