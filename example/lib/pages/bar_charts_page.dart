import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';
import '../widgets/chart_section.dart';

class BarChartsPage extends StatefulWidget {
  const BarChartsPage({super.key});

  @override
  State<BarChartsPage> createState() => _BarChartsPageState();
}

class _BarChartsPageState extends State<BarChartsPage> {
  String _lastTapped = 'Tap any bar!';

  // ── Vertical Bar Datasets ──────────────────────────────────────────────────

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
    axisStyle: AxisStyle(yAxisDivisions: 4, gridOpacity: 0.15),
  );

  // ── Horizontal Bar Datasets ────────────────────────────────────────────────

  static const _frameworkData = BarChartData(
    bars: [
      BarData(value: 80, label: 'Flutter'),
      BarData(value: 65, label: 'React'),
      BarData(value: 50, label: 'Vue'),
      BarData(value: 40, label: 'Angular'),
      BarData(value: 30, label: 'Svelte'),
    ],
  );

  static const _gradientHorizontalData = BarChartData(
    bars: [
      BarData(value: 240, label: 'Q4'),
      BarData(value: 170, label: 'Q3'),
      BarData(value: 200, label: 'Q2'),
      BarData(value: 120, label: 'Q1'),
    ],
    barStyle: BarStyle(
      borderRadius: 10,
      barWidthFraction: 0.5,
      gradient: LinearGradient(
        colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
  );

  static const _customColorHorizontalData = BarChartData(
    bars: [
      BarData(value: 95, label: 'Sales', color: Color(0xFF5C6BC0)),
      BarData(value: 72, label: 'Support', color: Color(0xFF26A69A)),
      BarData(value: 60, label: 'Design', color: Color(0xFFFF7043)),
      BarData(value: 45, label: 'Dev', color: Color(0xFFAB47BC)),
      BarData(value: 38, label: 'HR', color: Color(0xFFFFCA28)),
    ],
    axisStyle: AxisStyle(yAxisDivisions: 4, gridOpacity: 0.15),
  );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildTapBanner(),

        // ── Vertical ──────────────────────────────────────────────────────
        _buildSectionHeader('Vertical Bar Charts'),
        ChartSection(
          title: '📊 Weekly Activity',
          subtitle: 'Default theme · Elegant animation · Tap a bar!',
          child: FlBarChart(
            data: _weeklyData,
            animation: ChartAnimation.elegant(),
            onBarTapped: (bar, index) => setState(
              () => _lastTapped = '${bar.label}: ${bar.value.toInt()} units',
            ),
          ),
        ),
        ChartSection(
          title: '📈 Quarterly Revenue',
          subtitle: 'Gradient bars · Rounded corners · Snappy animation',
          child: FlBarChart(
            data: _quarterlyData,
            animation: ChartAnimation.snappy(),
            height: 280,
          ),
        ),
        ChartSection(
          title: '🎨 Custom Colors per Bar',
          subtitle: 'Per-bar color override · Bouncy animation',
          child: FlBarChart(
            data: _customColorData,
            animation: ChartAnimation.bouncy(),
          ),
        ),

        // ── Horizontal ────────────────────────────────────────────────────
        _buildSectionHeader('Horizontal Bar Charts'),
        ChartSection(
          title: '↔️ Framework Popularity',
          subtitle: 'Horizontal bars · Elegant animation · Tap a bar!',
          child: FlHorizontalBarChart(
            data: _frameworkData,
            animation: ChartAnimation.elegant(),
            onBarTapped: (bar, index) => setState(
              () => _lastTapped = '${bar.label}: ${bar.value.toInt()}%',
            ),
          ),
        ),
        ChartSection(
          title: '🌈 Quarterly Revenue',
          subtitle: 'Gradient · centerLeft → centerRight · Snappy',
          child: FlHorizontalBarChart(
            data: _gradientHorizontalData,
            animation: ChartAnimation.snappy(),
            height: 200,
          ),
        ),
        ChartSection(
          title: '🎨 Department Performance',
          subtitle: 'Per-bar colors · Bouncy animation · Tap a bar!',
          child: FlHorizontalBarChart(
            data: _customColorHorizontalData,
            animation: ChartAnimation.bouncy(),
            onBarTapped: (bar, index) => setState(
              () => _lastTapped = '${bar.label}: ${bar.value.toInt()}%',
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9E9E9E),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
