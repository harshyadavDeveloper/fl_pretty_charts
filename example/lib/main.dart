import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fl_pretty_charts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF5C6BC0),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
