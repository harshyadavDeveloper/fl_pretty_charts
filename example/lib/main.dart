import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _lastTapped = 'Tap any bar!';

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _weeklyData = BarChartData(
    bars: [
      BarData(value: 30, label: 'Mon'),
      BarData(value: 80, label: 'Tue'),
      BarData(value: 55, label: 'Wed'),
      BarData(value: 65, label: 'Thu'),
      BarData(value: 40, label: 'Fri'),
      BarData(value: 90, label: 'Sat'),
      BarData(value: 70, label: 'Sun'),
    ],
  );

  static const _quarterlyData = BarChartData(
    bars: [
      BarData(value: 120, label: 'Q1'),
      BarData(value: 200, label: 'Q2'),
      BarData(value: 170, label: 'Q3'),
      BarData(value: 240, label: 'Q4'),
    ],
    barStyle: BarStyle(
      borderRadius: 12,
      barWidthFraction: 0.5,
      gradient: LinearGradient(
        colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  );

  static const _customColorData = BarChartData(
    bars: [
      BarData(value: 45, label: 'Jan', color: Color(0xFFEF5350)),
      BarData(value: 72, label: 'Feb', color: Color(0xFFAB47BC)),
      BarData(value: 60, label: 'Mar', color: Color(0xFF42A5F5)),
      BarData(value: 88, label: 'Apr', color: Color(0xFF26A69A)),
      BarData(value: 53, label: 'May', color: Color(0xFFFFCA28)),
      BarData(value: 95, label: 'Jun', color: Color(0xFFFF7043)),
    ],
    axisStyle: AxisStyle(
      yAxisDivisions: 4,
      gridOpacity: 0.15,
    ),
  );

  static const _snappyData = BarChartData(
    bars: [
      BarData(value: 300, label: 'React'),
      BarData(value: 250, label: 'Vue'),
      BarData(value: 180, label: 'Angular'),
      BarData(value: 120, label: 'Svelte'),
      BarData(value: 90, label: 'Others'),
    ],
    defaultColor: Color(0xFFFF7043),
    barStyle: BarStyle(borderRadius: 4, barWidthFraction: 0.6),
  );

  // ── Build ──────────────────────────────────────────────────────────────────

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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildTapBanner(),
          _buildSection(
            title: '📊 Weekly Activity',
            subtitle: 'Default theme · Elegant animation · Tap a bar!',
            child: FlBarChart(
              data: _weeklyData,
              animation: ChartAnimation.elegant(),
              onBarTapped: (bar, index) => setState(() =>
                  _lastTapped = '${bar.label}: ${bar.value.toInt()} units'),
            ),
          ),
          _buildSection(
            title: '📈 Quarterly Revenue',
            subtitle: 'Gradient bars · Rounded corners · Snappy animation',
            child: FlBarChart(
              data: _quarterlyData,
              animation: ChartAnimation.snappy(),
              height: 280,
            ),
          ),
          _buildSection(
            title: '🎨 Custom Colors per Bar',
            subtitle: 'Per-bar color override · Reduced grid opacity',
            child: FlBarChart(
              data: _customColorData,
              animation: ChartAnimation.bouncy(),
            ),
          ),
          _buildSection(
            title: '⚡ Framework Popularity',
            subtitle: 'Solid color · Minimal radius · No animation',
            child: FlBarChart(
              data: _snappyData,
              animation: ChartAnimation.none(),
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildTapBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF5C6BC0).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Color(0xFF5C6BC0), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _lastTapped,
              style: const TextStyle(
                color: Color(0xFF5C6BC0),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
