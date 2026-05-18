import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';
import '../widgets/chart_section.dart';

class AreaChartsPage extends StatefulWidget {
  const AreaChartsPage({super.key});

  @override
  State<AreaChartsPage> createState() => _AreaChartsPageState();
}

class _AreaChartsPageState extends State<AreaChartsPage> {
  String _lastTapped = 'Tap any data point!';

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _singleSeriesData = AreaChartData(
    series: [
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 30, label: 'Jan'),
          AreaPoint(x: 1, y: 80, label: 'Feb'),
          AreaPoint(x: 2, y: 55, label: 'Mar'),
          AreaPoint(x: 3, y: 90, label: 'Apr'),
          AreaPoint(x: 4, y: 65, label: 'May'),
          AreaPoint(x: 5, y: 110, label: 'Jun'),
        ],
        label: 'Revenue',
        style: AreaSeriesStyle(
          color: Color(0xFF5C6BC0),
          strokeWidth: 3,
          fillOpacity: 0.3,
        ),
      ),
    ],
  );

  static const _multiSeriesData = AreaChartData(
    series: [
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 30, label: 'Jan'),
          AreaPoint(x: 1, y: 80, label: 'Feb'),
          AreaPoint(x: 2, y: 55, label: 'Mar'),
          AreaPoint(x: 3, y: 90, label: 'Apr'),
          AreaPoint(x: 4, y: 65, label: 'May'),
          AreaPoint(x: 5, y: 110, label: 'Jun'),
        ],
        label: 'Revenue',
        style: AreaSeriesStyle(
          color: Color(0xFF5C6BC0),
          strokeWidth: 2.5,
          fillOpacity: 0.25,
        ),
      ),
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 20, label: 'Jan'),
          AreaPoint(x: 1, y: 45, label: 'Feb'),
          AreaPoint(x: 2, y: 35, label: 'Mar'),
          AreaPoint(x: 3, y: 60, label: 'Apr'),
          AreaPoint(x: 4, y: 40, label: 'May'),
          AreaPoint(x: 5, y: 75, label: 'Jun'),
        ],
        label: 'Expenses',
        style: AreaSeriesStyle(
          color: Color(0xFFFF7043),
          strokeWidth: 2.5,
          fillOpacity: 0.25,
        ),
      ),
    ],
  );

  static const _stackedData = AreaChartData(
    series: [
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 30, label: 'Q1'),
          AreaPoint(x: 1, y: 50, label: 'Q2'),
          AreaPoint(x: 2, y: 40, label: 'Q3'),
          AreaPoint(x: 3, y: 60, label: 'Q4'),
        ],
        label: 'Product A',
        style: AreaSeriesStyle(
          color: Color(0xFF5C6BC0),
          fillOpacity: 0.5,
          strokeWidth: 2,
        ),
      ),
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 20, label: 'Q1'),
          AreaPoint(x: 1, y: 30, label: 'Q2'),
          AreaPoint(x: 2, y: 25, label: 'Q3'),
          AreaPoint(x: 3, y: 35, label: 'Q4'),
        ],
        label: 'Product B',
        style: AreaSeriesStyle(
          color: Color(0xFF26A69A),
          fillOpacity: 0.5,
          strokeWidth: 2,
        ),
      ),
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 10, label: 'Q1'),
          AreaPoint(x: 1, y: 20, label: 'Q2'),
          AreaPoint(x: 2, y: 15, label: 'Q3'),
          AreaPoint(x: 3, y: 25, label: 'Q4'),
        ],
        label: 'Product C',
        style: AreaSeriesStyle(
          color: Color(0xFFFF7043),
          fillOpacity: 0.5,
          strokeWidth: 2,
        ),
      ),
    ],
    stacked: true,
  );

  static const _gradientData = AreaChartData(
    series: [
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 10, label: 'Mon'),
          AreaPoint(x: 1, y: 55, label: 'Tue'),
          AreaPoint(x: 2, y: 30, label: 'Wed'),
          AreaPoint(x: 3, y: 85, label: 'Thu'),
          AreaPoint(x: 4, y: 60, label: 'Fri'),
          AreaPoint(x: 5, y: 95, label: 'Sat'),
          AreaPoint(x: 6, y: 70, label: 'Sun'),
        ],
        label: 'Steps',
        style: AreaSeriesStyle(
          color: Color(0xFF26A69A),
          strokeWidth: 3,
          fillOpacity: 0.4,
          fillGradient: LinearGradient(
            colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          dotRadius: 5,
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
          title: '📉 Monthly Revenue',
          subtitle: 'Single series · Bezier curves · Tap a point!',
          child: FlAreaChart(
            data: _singleSeriesData,
            animation: ChartAnimation.elegant(),
            showLegend: false,
            onPointTapped: (point, si, pi) => setState(
              () => _lastTapped = '${point.label}: ${point.y.toInt()}',
            ),
          ),
        ),
        ChartSection(
          title: '📊 Revenue vs Expenses',
          subtitle: 'Multi-series · Legend · Tap to highlight · Snappy',
          child: FlAreaChart(
            data: _multiSeriesData,
            animation: ChartAnimation.snappy(),
            onPointTapped: (point, si, pi) => setState(
              () => _lastTapped = '${_multiSeriesData.series[si].label} · '
                  '${point.label}: ${point.y.toInt()}',
            ),
          ),
        ),
        ChartSection(
          title: '📦 Stacked Product Sales',
          subtitle: 'Stacked mode · Three series · Bouncy animation',
          child: FlAreaChart(
            data: _stackedData,
            animation: ChartAnimation.bouncy(),
            height: 280,
            onPointTapped: (point, si, pi) => setState(
              () => _lastTapped = '${_stackedData.series[si].label} · '
                  '${point.label}: ${point.y.toInt()}',
            ),
          ),
        ),
        ChartSection(
          title: '🌈 Weekly Steps',
          subtitle: 'Custom fill gradient · Large dots · No animation',
          child: FlAreaChart(
            data: _gradientData,
            animation: ChartAnimation.none(),
            showLegend: false,
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
