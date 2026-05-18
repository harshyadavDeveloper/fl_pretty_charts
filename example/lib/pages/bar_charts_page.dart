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

  // ── Stacked Bar Datasets ───────────────────────────────────────────────────

  static const _stackedRevenueData = StackedBarChartData(
    groups: ['Q1', 'Q2', 'Q3', 'Q4'],
    series: [
      StackedBarSeries(
        label: 'Revenue',
        color: Color(0xFF5C6BC0),
        values: [30, 50, 40, 60],
      ),
      StackedBarSeries(
        label: 'Expenses',
        color: Color(0xFF26A69A),
        values: [20, 30, 25, 35],
      ),
      StackedBarSeries(
        label: 'Profit',
        color: Color(0xFFFFCA28),
        values: [10, 20, 15, 25],
      ),
    ],
  );

  static const _stackedPercentageData = StackedBarChartData(
    groups: ['Jan', 'Feb', 'Mar', 'Apr', 'May'],
    series: [
      StackedBarSeries(
        label: 'Mobile',
        color: Color(0xFF5C6BC0),
        values: [60, 55, 65, 70, 58],
      ),
      StackedBarSeries(
        label: 'Desktop',
        color: Color(0xFF26A69A),
        values: [30, 35, 25, 20, 32],
      ),
      StackedBarSeries(
        label: 'Tablet',
        color: Color(0xFFFF7043),
        values: [10, 10, 10, 10, 10],
      ),
    ],
    percentageMode: true,
  );

  static const _stackedTeamData = StackedBarChartData(
    groups: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
    series: [
      StackedBarSeries(
        label: 'Design',
        color: Color(0xFFAB47BC),
        values: [15, 20, 18, 22],
      ),
      StackedBarSeries(
        label: 'Dev',
        color: Color(0xFF5C6BC0),
        values: [40, 35, 45, 38],
      ),
      StackedBarSeries(
        label: 'QA',
        color: Color(0xFF26A69A),
        values: [10, 15, 12, 18],
      ),
      StackedBarSeries(
        label: 'PM',
        color: Color(0xFFFF7043),
        values: [8, 10, 9, 12],
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

        // ── Stacked ───────────────────────────────────────────────────────
        _buildSectionHeader('Stacked Bar Charts'),
        ChartSection(
          title: '📦 Revenue Breakdown',
          subtitle: 'Three series · Legend · Tap a segment!',
          child: FlStackedBarChart(
            data: _stackedRevenueData,
            animation: ChartAnimation.elegant(),
            onSegmentTapped: (series, gi, si) => setState(
              () => _lastTapped =
                  '${series.label} ${_stackedRevenueData.groups[gi]}: '
                      '${series.values[gi].toInt()}',
            ),
          ),
        ),
        ChartSection(
          title: '📱 Device Usage',
          subtitle: 'Percentage mode · Normalized to 100% · Snappy',
          child: FlStackedBarChart(
            data: _stackedPercentageData,
            animation: ChartAnimation.snappy(),
            onSegmentTapped: (series, gi, si) => setState(
              () => _lastTapped =
                  '${series.label} ${_stackedPercentageData.groups[gi]}: '
                      '${series.values[gi].toInt()}%',
            ),
          ),
        ),
        ChartSection(
          title: '👥 Team Hours by Week',
          subtitle: 'Four series · Bouncy animation · Tap a segment!',
          child: FlStackedBarChart(
            data: _stackedTeamData,
            animation: ChartAnimation.bouncy(),
            height: 300,
            onSegmentTapped: (series, gi, si) => setState(
              () => _lastTapped =
                  '${series.label} ${_stackedTeamData.groups[gi]}: '
                      '${series.values[gi].toInt()} hrs',
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
