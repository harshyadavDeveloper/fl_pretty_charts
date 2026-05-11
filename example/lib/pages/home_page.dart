import 'package:flutter/material.dart';
import 'bar_charts_page.dart';
import 'line_charts_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('fl_pretty_charts'),
        centerTitle: true,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Bar Charts',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Line Charts',
          ),
        ],
      ),
      body: _currentTab == 0 ? const BarChartsPage() : const LineChartsPage(),
    );
  }
}
