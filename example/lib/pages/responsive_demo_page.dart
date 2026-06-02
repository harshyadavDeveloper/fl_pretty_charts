import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';

class ResponsiveDemoPage extends StatefulWidget {
  const ResponsiveDemoPage({super.key});

  @override
  State<ResponsiveDemoPage> createState() => _ResponsiveDemoPageState();
}

class _ResponsiveDemoPageState extends State<ResponsiveDemoPage> {
  double _simulatedWidth = 400;

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _barData = BarChartData(
    bars: [
      BarData(value: 60, label: 'Mon'),
      BarData(value: 90, label: 'Tue'),
      BarData(value: 45, label: 'Wed'),
      BarData(value: 75, label: 'Thu'),
      BarData(value: 85, label: 'Fri'),
      BarData(value: 55, label: 'Sat'),
      BarData(value: 70, label: 'Sun'),
    ],
  );

  static const _lineData = LineChartData(
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

  static const _areaData = AreaChartData(
    series: [
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 20, label: 'Q1'),
          AreaPoint(x: 1, y: 55, label: 'Q2'),
          AreaPoint(x: 2, y: 40, label: 'Q3'),
          AreaPoint(x: 3, y: 80, label: 'Q4'),
        ],
        label: 'Sales',
        style: AreaSeriesStyle(
          color: Color(0xFF26A69A),
          fillOpacity: 0.3,
          strokeWidth: 2.5,
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
        _buildInfoBanner(),
        _buildWidthSimulator(),
        _buildSection(
          title: '📊 Responsive Bar Chart',
          subtitle:
              'Auto-adjusts height, grid, labels based on available width',
          child: _buildResponsiveBar(),
        ),
        _buildSection(
          title: '📈 Responsive Line Chart',
          subtitle: 'Dots hidden on small · Fewer divisions on medium',
          child: _buildResponsiveLine(),
        ),
        _buildSection(
          title: '📉 Responsive Area Chart',
          subtitle: 'Grid hidden on small · Full config on large',
          child: _buildResponsiveArea(),
        ),
        _buildBreakpointTable(),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Responsive charts ──────────────────────────────────────────────────────

  Widget _buildResponsiveBar() {
    return SizedBox(
      width: _simulatedWidth,
      child: FlResponsiveChart(
        breakpoints: const ChartBreakpoints(
          smallMaxWidth: 360,
          mediumMaxWidth: 600,
        ),
        small: const ResponsiveChartConfig(
          height: 160,
          padding: EdgeInsets.all(8),
          yAxisDivisions: 3,
          showGrid: false,
          labelFontSize: 9,
        ),
        medium: const ResponsiveChartConfig(
          height: 220,
          padding: EdgeInsets.all(12),
          yAxisDivisions: 4,
          showGrid: true,
          labelFontSize: 10,
        ),
        large: const ResponsiveChartConfig(
          height: 280,
          padding: EdgeInsets.all(16),
          yAxisDivisions: 5,
          showGrid: true,
          labelFontSize: 11,
        ),
        builder: (context, config) => FlBarChart(
          data: BarChartData(
            bars: _barData.bars,
            axisStyle: AxisStyle(
              yAxisDivisions: config.resolveYAxisDivisions(),
              showGrid: config.resolveShowGrid(),
              labelStyle: TextStyle(
                fontSize: config.resolveLabelFontSize(),
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          height: config.resolveHeight(260),
          padding: config.resolvePadding(),
          animation: ChartAnimation.snappy(),
        ),
      ),
    );
  }

  Widget _buildResponsiveLine() {
    return SizedBox(
      width: _simulatedWidth,
      child: FlResponsiveChart(
        small: const ResponsiveChartConfig(
          height: 160,
          padding: EdgeInsets.all(8),
          yAxisDivisions: 3,
          showGrid: false,
          labelFontSize: 9,
          showDots: false,
        ),
        medium: const ResponsiveChartConfig(
          height: 210,
          padding: EdgeInsets.all(12),
          yAxisDivisions: 4,
          showGrid: true,
          labelFontSize: 10,
          showDots: true,
        ),
        large: const ResponsiveChartConfig(
          height: 260,
          padding: EdgeInsets.all(16),
          yAxisDivisions: 5,
          showGrid: true,
          labelFontSize: 11,
          showDots: true,
        ),
        builder: (context, config) => FlLineChart(
          data: LineChartData(
            lines: [
              LineData(
                points: _lineData.lines.first.points,
                label: 'Revenue',
                style: LineStyle(
                  color: const Color(0xFF5C6BC0),
                  strokeWidth: 2.5,
                  showFill: true,
                  showDots: config.resolveShowDots(),
                ),
              ),
            ],
            axisStyle: AxisLineStyle(
              yAxisDivisions: config.resolveYAxisDivisions(),
              showGrid: config.resolveShowGrid(),
              labelStyle: TextStyle(
                fontSize: config.resolveLabelFontSize(),
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          height: config.resolveHeight(260),
          padding: config.resolvePadding(),
          animation: ChartAnimation.snappy(),
        ),
      ),
    );
  }

  Widget _buildResponsiveArea() {
    return SizedBox(
      width: _simulatedWidth,
      child: FlResponsiveChart(
        small: const ResponsiveChartConfig(
          height: 150,
          padding: EdgeInsets.all(8),
          yAxisDivisions: 3,
          showGrid: false,
          labelFontSize: 9,
          showDots: false,
        ),
        medium: const ResponsiveChartConfig(
          height: 200,
          padding: EdgeInsets.all(12),
          yAxisDivisions: 4,
          showGrid: true,
          labelFontSize: 10,
          showDots: false,
        ),
        large: const ResponsiveChartConfig(
          height: 260,
          padding: EdgeInsets.all(16),
          yAxisDivisions: 5,
          showGrid: true,
          labelFontSize: 11,
          showDots: true,
        ),
        builder: (context, config) => FlAreaChart(
          data: AreaChartData(
            series: [
              AreaSeries(
                points: _areaData.series.first.points,
                label: 'Sales',
                style: AreaSeriesStyle(
                  color: const Color(0xFF26A69A),
                  fillOpacity: 0.3,
                  strokeWidth: 2.5,
                  showDots: config.resolveShowDots(),
                ),
              ),
            ],
            axisStyle: AreaAxisStyle(
              yAxisDivisions: config.resolveYAxisDivisions(),
              showGrid: config.resolveShowGrid(),
              labelStyle: TextStyle(
                fontSize: config.resolveLabelFontSize(),
                color: const Color(0xFF9E9E9E),
              ),
            ),
          ),
          height: config.resolveHeight(260),
          padding: config.resolvePadding(),
          showLegend: false,
          animation: ChartAnimation.snappy(),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF26A69A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF26A69A).withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF26A69A), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Use the slider below to simulate different screen widths. '
              'Watch the charts automatically adapt their height, labels, '
              'grid density, and dot visibility.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF616161),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidthSimulator() {
    final size = _simulatedWidth < 360
        ? 'Small'
        : _simulatedWidth < 600
            ? 'Medium'
            : 'Large';
    final color = _simulatedWidth < 360
        ? const Color(0xFFEF5350)
        : _simulatedWidth < 600
            ? const Color(0xFFFFCA28)
            : const Color(0xFF66BB6A);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Text(
                '📐 Simulate Screen Width',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF212121),
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$size · ${_simulatedWidth.toInt()}px',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 280,
              max: 800,
              value: _simulatedWidth,
              onChanged: (v) => setState(() => _simulatedWidth = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBreakpointChip('Small', '< 360px', const Color(0xFFEF5350),
                  _simulatedWidth < 360),
              _buildBreakpointChip(
                  'Medium',
                  '360–600px',
                  const Color(0xFFFFCA28),
                  _simulatedWidth >= 360 && _simulatedWidth < 600),
              _buildBreakpointChip('Large', '≥ 600px', const Color(0xFF66BB6A),
                  _simulatedWidth >= 600),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakpointChip(
      String label, String range, Color color, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? color : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? color : const Color(0xFF9E9E9E),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 9,
              color: active ? color : const Color(0xFFBDBDBD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakpointTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
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
          const Text(
            '📋 Breakpoint Behavior',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          _buildTableRow('Property', 'Small', 'Medium', 'Large',
              isHeader: true),
          _buildTableRow('Height', '160px', '220px', '280px'),
          _buildTableRow('Y Divisions', '3', '4', '5'),
          _buildTableRow('Grid Lines', 'Hidden', 'Visible', 'Visible'),
          _buildTableRow('Dots', 'Hidden', 'Visible', 'Visible'),
          _buildTableRow('Label Size', '9px', '10px', '11px'),
          _buildTableRow('Padding', '8px', '12px', '16px'),
        ],
      ),
    );
  }

  Widget _buildTableRow(
    String property,
    String small,
    String medium,
    String large, {
    bool isHeader = false,
  }) {
    final style = TextStyle(
      fontSize: isHeader ? 11 : 12,
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
      color: isHeader ? const Color(0xFF9E9E9E) : const Color(0xFF424242),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFEEEEEE),
            width: isHeader ? 1.5 : 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(property, style: style)),
          Expanded(
            flex: 2,
            child: Text(small,
                style: style.copyWith(
                    color: isHeader
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFFEF5350))),
          ),
          Expanded(
            flex: 2,
            child: Text(medium,
                style: style.copyWith(
                    color: isHeader
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFFFFCA28))),
          ),
          Expanded(
            flex: 2,
            child: Text(large,
                style: style.copyWith(
                    color: isHeader
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF66BB6A))),
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
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: child),
        ],
      ),
    );
  }
}
