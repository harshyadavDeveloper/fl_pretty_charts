/// fl_pretty_charts
///
/// A beautiful, animated Flutter charts library.
/// Zero external dependencies — pure Flutter custom painter.
///
/// ## Available Charts
/// - [FlBarChart] — animated bar chart with tap tooltips (v0.0.1)
/// - [FlLineChart] — smooth bezier line chart, multi-line support (v0.1.0)
///
/// ## Coming Soon
/// - FlPieChart / FlDonutChart (v0.5.0)
/// - FlRadarChart (v0.9.0)
///
/// ## Quick Start
/// ```dart
/// import 'package:fl_pretty_charts/fl_pretty_charts.dart';
///
/// FlLineChart(
///   data: LineChartData(
///     lines: [
///       LineData(
///         points: [
///           LinePoint(x: 0, y: 30, label: 'Jan'),
///           LinePoint(x: 1, y: 80, label: 'Feb'),
///           LinePoint(x: 2, y: 55, label: 'Mar'),
///         ],
///         label: 'Sales',
///       ),
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

// ── Common ─────────────────────────────────────────────────────────────────
export 'src/common/chart_animation.dart';
export 'src/common/chart_theme.dart';
export 'src/common/chart_utils.dart';