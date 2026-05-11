import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';
import '../widgets/chart_section.dart';

class LineChartsPage extends StatefulWidget {
  const LineChartsPage({super.key});

  @override
  State<LineChartsPage> createState() => _LineChartsPageState();
}

class _LineChartsPageState extends State<LineChartsPage> {
  String _lastTapped = 'Tap any data point!';

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _singleLineData = LineChartData(
    lines: [
      LineData(
        points: [
          LinePoint(x: 0, y: 30, label: 'Jan'),
          LinePoint(x: 1, y: 80, label: 'Feb'),
          LinePoint(x: 2, y: 55, label: 'Mar'),
          LinePoint(x: 3, y: 90, label: 'Apr'),
          LinePoint(x: 4, y: 65, label: 'May'),
          LinePoint(x: 5, y: 110, label: 'Jun'),
        ],
        label: 'Revenue',
        style: LineStyle(
          color: Color(0xFF5C6BC0),
          strokeWidth: 3,
          showFill: true,
        ),
      ),
    ],
  );

  static const _multiLineData = LineChartData(
    lines: [
      LineData(
        points: [
          LinePoint(x: 0, y: 30, label: 'Jan'),
          LinePoint(x: 1, y: 80, label: 'Feb'),
          LinePoint(x: 2, y: 55, label: 'Mar'),
          LinePoint(x: 3, y: 90, label: 'Apr'),
          LinePoint(x: 4, y: 65, label: 'May'),
          LinePoint(x: 5, y: 110, label: 'Jun'),
        ],
        label: 'Revenue',
        style: LineStyle(
          color: Color(0xFF5C6BC0),
          strokeWidth: 3,
          showFill: true,
          fillOpacity: 0.15,
        ),
      ),
      LineData(
        points: [
          LinePoint(x: 0, y: 20, label: 'Jan'),
          LinePoint(x: 1, y: 45, label: 'Feb'),
          LinePoint(x: 2, y: 35, label: 'Mar'),
          LinePoint(x: 3, y: 60, label: 'Apr'),
          LinePoint(x: 4, y: 40, label: 'May'),
          LinePoint(x: 5, y: 75, label: 'Jun'),
        ],
        label: 'Expenses',
        style: LineStyle(
          color: Color(0xFFFF7043),
          strokeWidth: 3,
          showFill: true,
          fillOpacity: 0.15,
        ),
      ),
    ],
  );

  static const _gradientLineData = LineChartData(
    lines: [
      LineData(
        points: [
          LinePoint(x: 0, y: 10, label: 'Mon'),
          LinePoint(x: 1, y: 55, label: 'Tue'),
          LinePoint(x: 2, y: 30, label: 'Wed'),
          LinePoint(x: 3, y: 85, label: 'Thu'),
          LinePoint(x: 4, y: 60, label: 'Fri'),
          LinePoint(x: 5, y: 95, label: 'Sat'),
          LinePoint(x: 6, y: 70, label: 'Sun'),
        ],
        label: 'Steps',
        style: LineStyle(
          color: Color(0xFF26A69A),
          strokeWidth: 3.5,
          gradient: LinearGradient(
            colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
          ),
          showFill: true,
          fillOpacity: 0.2,
          dotRadius: 5,
        ),
      ),
    ],
  );

  static const _straightLineData = LineChartData(
    lines: [
      LineData(
        points: [
          LinePoint(x: 0, y: 40, label: 'Q1'),
          LinePoint(x: 1, y: 70, label: 'Q2'),
          LinePoint(x: 2, y: 50, label: 'Q3'),
          LinePoint(x: 3, y: 90, label: 'Q4'),
        ],
        label: 'Target',
        style: LineStyle(
          color: Color(0xFFAB47BC),
          strokeWidth: 2.5,
          smooth: false,
          showFill: false,
          dotRadius: 6,
        ),
      ),
      LineData(
        points: [
          LinePoint(x: 0, y: 30, label: 'Q1'),
          LinePoint(x: 1, y: 60, label: 'Q2'),
          LinePoint(x: 2, y: 45, label: 'Q3'),
          LinePoint(x: 3, y: 80, label: 'Q4'),
        ],
        label: 'Actual',
        style: LineStyle(
          color: Color(0xFF26A69A),
          strokeWidth: 2.5,
          smooth: false,
          showFill: false,
          dotRadius: 6,
        ),
      ),
    ],
  );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildTapBanner(),
        ChartSection(
          title: '📈 Monthly Revenue',
          subtitle:
              'Single line · Bezier curves · Gradient fill · Tap a point!',
          child: FlLineChart(
            data: _singleLineData,
            animation: ChartAnimation.elegant(),
            onPointTapped: (point, lineIndex, pointIndex) => setState(
              () => _lastTapped = '${point.label}: ${point.y.toInt()}',
            ),
          ),
        ),
        ChartSection(
          title: '📊 Revenue vs Expenses',
          subtitle: 'Multi-line · Two series · Snappy animation',
          child: FlLineChart(
            data: _multiLineData,
            animation: ChartAnimation.snappy(),
            height: 280,
            onPointTapped: (point, lineIndex, pointIndex) => setState(
              () => _lastTapped =
                  '${_multiLineData.lines[lineIndex].label} · ${point.label}: ${point.y.toInt()}',
            ),
          ),
        ),
        ChartSection(
          title: '🌈 Weekly Steps',
          subtitle: 'Gradient stroke · Area fill · Bouncy animation',
          child: FlLineChart(
            data: _gradientLineData,
            animation: ChartAnimation.bouncy(),
          ),
        ),
        ChartSection(
          title: '🎯 Target vs Actual',
          subtitle: 'Straight lines · No fill · Two series · No animation',
          child: FlLineChart(
            data: _straightLineData,
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
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildTapBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF26A69A).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF26A69A).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Color(0xFF26A69A), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _lastTapped,
              style: const TextStyle(
                color: Color(0xFF26A69A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
