import 'package:flutter/material.dart';
import 'prediction_page.dart';

void main() {
  runApp(const InflationApp());
}

class InflationApp extends StatelessWidget {
  const InflationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inflation Insight Africa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const InflationPredictionPage(),
    );
  }
}