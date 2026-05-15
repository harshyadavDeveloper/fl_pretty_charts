/// fl_pretty_charts
///
/// A beautiful, animated Flutter charts library.
/// Zero external dependencies — pure Flutter custom painter.
///
/// ## Available Charts
/// - [FlBarChart] — animated bar chart with tap tooltips
/// - [FlLineChart] — smooth bezier line chart, multi-line support
/// - [FlPieChart] — animated pie and donut chart
/// - [FlRadarChart] — radar/spider chart, multi-dataset
///
/// ## Theming
/// Apply a consistent color palette across all charts:
/// ```dart
/// FlBarChart(
///   data: myBarData,
///   theme: ChartTheme.ocean(),
/// )
///
/// FlLineChart(
///   data: myLineData,
///   theme: ChartTheme.sunset(),
/// )
/// ```
///
/// ## Standalone Legend
/// ```dart
/// LegendWidget(
///   items: [
///     LegendItem(color: Color(0xFF5C6BC0), label: 'Revenue'),
///     LegendItem(color: Color(0xFF26A69A), label: 'Expenses'),
///   ],
/// )
/// ```
///
/// ## Quick Start
/// ```dart
/// import 'package:fl_pretty_charts/fl_pretty_charts.dart';
///
/// FlBarChart(
///   data: BarChartData(
///     bars: [
///       BarData(value: 30, label: 'Mon'),
///       BarData(value: 80, label: 'Tue'),
///       BarData(value: 55, label: 'Wed'),
///     ],
///   ),
/// )
/// ```
library fl_pretty_charts;

// ── Bar Chart ──────────────────────────────────────────────────────────────
export 'src/bar_chart/bar_chart.dart';
export 'src/bar_chart/bar_chart_data.dart';
export 'src/bar_chart/bar_chart_painter.dart';

// ── Line Chart ─────────────────────────────────────────────────────────────
export 'src/line_chart/line_chart.dart';
export 'src/line_chart/line_chart_data.dart';
export 'src/line_chart/line_chart_painter.dart';

// ── Pie Chart ──────────────────────────────────────────────────────────────
export 'src/pie_chart/pie_chart.dart';
export 'src/pie_chart/pie_chart_data.dart';
export 'src/pie_chart/pie_chart_painter.dart';

// ── Radar Chart ────────────────────────────────────────────────────────────
export 'src/radar_chart/radar_chart.dart';
export 'src/radar_chart/radar_chart_data.dart';
export 'src/radar_chart/radar_chart_painter.dart';

// ── Common ─────────────────────────────────────────────────────────────────
export 'src/common/chart_animation.dart';
export 'src/common/chart_theme.dart';
export 'src/common/chart_utils.dart';
export 'src/common/legend_widget.dart';
