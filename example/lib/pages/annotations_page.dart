import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';
import '../widgets/chart_section.dart';

class AnnotationsPage extends StatelessWidget {
  const AnnotationsPage({super.key});

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _barData = BarChartData(
    bars: [
      BarData(value: 45, label: 'Mon'),
      BarData(value: 72, label: 'Tue'),
      BarData(value: 60, label: 'Wed'),
      BarData(value: 88, label: 'Thu'),
      BarData(value: 53, label: 'Fri'),
      BarData(value: 95, label: 'Sat'),
      BarData(value: 70, label: 'Sun'),
    ],
  );

  static const _lineData = LineChartData(
    lines: [
      LineData(
        points: [
          LinePoint(x: 0, y: 30, label: 'Jan'),
          LinePoint(x: 1, y: 55, label: 'Feb'),
          LinePoint(x: 2, y: 45, label: 'Mar'),
          LinePoint(x: 3, y: 80, label: 'Apr'),
          LinePoint(x: 4, y: 60, label: 'May'),
          LinePoint(x: 5, y: 90, label: 'Jun'),
        ],
        label: 'Revenue',
        style: LineStyle(
          color: Color(0xFF5C6BC0),
          strokeWidth: 3,
          showFill: true,
          fillOpacity: 0.15,
        ),
      ),
    ],
  );

  static const _areaData = AreaChartData(
    series: [
      AreaSeries(
        points: [
          AreaPoint(x: 0, y: 20, label: 'Q1'),
          AreaPoint(x: 1, y: 45, label: 'Q2'),
          AreaPoint(x: 2, y: 35, label: 'Q3'),
          AreaPoint(x: 3, y: 70, label: 'Q4'),
        ],
        label: 'Sales',
        style: AreaSeriesStyle(
          color: Color(0xFF26A69A),
          strokeWidth: 3,
          fillOpacity: 0.25,
        ),
      ),
    ],
  );

  static const _multiAnnotationData = BarChartData(
    bars: [
      BarData(value: 30, label: 'Jan'),
      BarData(value: 65, label: 'Feb'),
      BarData(value: 50, label: 'Mar'),
      BarData(value: 85, label: 'Apr'),
      BarData(value: 45, label: 'May'),
      BarData(value: 75, label: 'Jun'),
    ],
  );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildInfoBanner(context),
        ChartSection(
          title: '📊 Bar Chart — Target Line',
          subtitle: 'Horizontal annotation · Dashed red line · "Target: 80"',
          child: FlBarChart(
            data: _barData,
            animation: ChartAnimation.elegant(),
            annotations: [
              ChartAnnotation.horizontal(
                value: 80,
                label: 'Target',
                color: const Color(0xFFEF5350),
                dashPattern: [8, 4],
              ),
            ],
          ),
        ),
        ChartSection(
          title: '📊 Bar Chart — Average + Max',
          subtitle: 'Two horizontal annotations · Different colors',
          child: FlBarChart(
            data: _barData,
            animation: ChartAnimation.snappy(),
            annotations: [
              ChartAnnotation.horizontal(
                value: 67,
                label: 'Avg',
                color: const Color(0xFF5C6BC0),
                dashPattern: [6, 3],
              ),
              ChartAnnotation.horizontal(
                value: 90,
                label: 'Max',
                color: const Color(0xFFFF7043),
                dashPattern: [10, 4],
                labelPosition: AnnotationLabelPosition.start,
              ),
            ],
          ),
        ),
        ChartSection(
          title: '📈 Line Chart — Threshold + Event',
          subtitle: 'Horizontal threshold · Vertical event marker · "Launch"',
          child: FlLineChart(
            data: _lineData,
            animation: ChartAnimation.elegant(),
            annotations: [
              ChartAnnotation.horizontal(
                value: 70,
                label: 'Threshold',
                color: const Color(0xFFEF5350),
                dashPattern: [8, 4],
                labelPosition: AnnotationLabelPosition.start,
              ),
              ChartAnnotation.vertical(
                index: 3,
                label: 'Launch',
                color: const Color(0xFF66BB6A),
                dashPattern: [6, 3],
              ),
            ],
          ),
        ),
        ChartSection(
          title: '📉 Area Chart — Target + Milestone',
          subtitle: 'Horizontal target · Vertical milestone marker',
          child: FlAreaChart(
            data: _areaData,
            animation: ChartAnimation.bouncy(),
            showLegend: false,
            annotations: [
              ChartAnnotation.horizontal(
                value: 60,
                label: 'Target',
                color: const Color(0xFFEF5350),
                dashPattern: [8, 4],
              ),
              ChartAnnotation.vertical(
                index: 2,
                label: 'Milestone',
                color: const Color(0xFFAB47BC),
                dashPattern: [6, 3],
                labelPosition: AnnotationLabelPosition.start,
              ),
            ],
          ),
        ),
        ChartSection(
          title: '📊 Multiple Annotations',
          subtitle: 'Min · Avg · Max · Event — all on one chart',
          child: FlBarChart(
            data: _multiAnnotationData,
            animation: ChartAnimation.elegant(),
            annotations: [
              ChartAnnotation.horizontal(
                value: 30,
                label: 'Min',
                color: const Color(0xFF42A5F5),
                dashPattern: [4, 4],
                labelPosition: AnnotationLabelPosition.start,
              ),
              ChartAnnotation.horizontal(
                value: 58,
                label: 'Avg',
                color: const Color(0xFF5C6BC0),
                dashPattern: [8, 4],
                labelPosition: AnnotationLabelPosition.center,
              ),
              ChartAnnotation.horizontal(
                value: 85,
                label: 'Max',
                color: const Color(0xFFEF5350),
                dashPattern: [8, 4],
              ),
              ChartAnnotation.vertical(
                index: 3,
                label: 'Best Day',
                color: const Color(0xFF66BB6A),
                dashPattern: [6, 3],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF5350).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF5350).withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFFEF5350), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Annotations add reference lines to any chart — mark targets, '
              'averages, thresholds, or events with horizontal and vertical lines.',
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
}
