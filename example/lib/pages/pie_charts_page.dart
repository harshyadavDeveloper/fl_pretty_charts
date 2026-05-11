import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';
import '../widgets/chart_section.dart';

class PieChartsPage extends StatefulWidget {
  const PieChartsPage({super.key});

  @override
  State<PieChartsPage> createState() => _PieChartsPageState();
}

class _PieChartsPageState extends State<PieChartsPage> {
  String _lastTapped = 'Tap any segment!';

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _basicPieData = PieChartData(
    segments: [
      PieSegment(value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
      PieSegment(value: 30, label: 'React', color: Color(0xFF26A69A)),
      PieSegment(value: 20, label: 'Vue', color: Color(0xFFFFCA28)),
      PieSegment(value: 10, label: 'Other', color: Color(0xFFEF5350)),
    ],
  );

  static const _donutData = PieChartData(
    segments: [
      PieSegment(value: 35, label: 'Design', color: Color(0xFF5C6BC0)),
      PieSegment(value: 25, label: 'Dev', color: Color(0xFF26A69A)),
      PieSegment(value: 20, label: 'Testing', color: Color(0xFFFF7043)),
      PieSegment(value: 15, label: 'Meetings', color: Color(0xFFAB47BC)),
      PieSegment(value: 5, label: 'Other', color: Color(0xFFFFCA28)),
    ],
    donut: true,
    donutRadius: 0.55,
    centerLabel: CenterLabelStyle(
      title: 'Hours',
      value: '160',
    ),
  );

  static const _customGapData = PieChartData(
    segments: [
      PieSegment(value: 60, label: 'Profit', color: Color(0xFF66BB6A)),
      PieSegment(value: 25, label: 'Expenses', color: Color(0xFFEF5350)),
      PieSegment(value: 15, label: 'Tax', color: Color(0xFFFFCA28)),
    ],
    segmentGap: 4,
    expandOffset: 14,
    legendStyle: LegendStyle(
      dotSize: 12,
      spacing: 20,
    ),
  );

  static const _donutCustomData = PieChartData(
    segments: [
      PieSegment(value: 45, label: 'Stocks', color: Color(0xFF5C6BC0)),
      PieSegment(value: 30, label: 'Crypto', color: Color(0xFF26A69A)),
      PieSegment(value: 15, label: 'Bonds', color: Color(0xFFFF7043)),
      PieSegment(value: 10, label: 'Cash', color: Color(0xFFAB47BC)),
    ],
    donut: true,
    donutRadius: 0.6,
    segmentGap: 3,
    centerLabel: CenterLabelStyle(
      title: 'Portfolio',
      value: '\$24.5k',
    ),
    legendStyle: LegendStyle(
      dotSize: 10,
      spacing: 12,
    ),
  );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildTapBanner(),
        ChartSection(
          title: '🥧 Framework Popularity',
          subtitle: 'Basic pie chart · Elegant animation · Tap a segment!',
          child: FlPieChart(
            data: _basicPieData,
            animation: ChartAnimation.elegant(),
            onSegmentTapped: (segment, index) => setState(
              () => _lastTapped = '${segment.label}: ${segment.value.toInt()}%',
            ),
          ),
        ),
        ChartSection(
          title: '🍩 Time Distribution',
          subtitle: 'Donut chart · Center label · Snappy animation',
          child: FlPieChart(
            data: _donutData,
            animation: ChartAnimation.snappy(),
            onSegmentTapped: (segment, index) => setState(
              () => _lastTapped =
                  '${segment.label}: ${segment.value.toInt()} hrs',
            ),
          ),
        ),
        ChartSection(
          title: '📊 Revenue Breakdown',
          subtitle: 'Wide gaps · Large expand offset · Bouncy animation',
          child: FlPieChart(
            data: _customGapData,
            animation: ChartAnimation.bouncy(),
            onSegmentTapped: (segment, index) => setState(
              () => _lastTapped = '${segment.label}: ${segment.value.toInt()}%',
            ),
          ),
        ),
        ChartSection(
          title: '💰 Portfolio Allocation',
          subtitle: 'Donut · Custom center label · No animation',
          child: FlPieChart(
            data: _donutCustomData,
            animation: ChartAnimation.none(),
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
}
