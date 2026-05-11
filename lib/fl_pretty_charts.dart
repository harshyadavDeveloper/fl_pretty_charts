/// fl_pretty_charts
///
/// A beautiful, animated Flutter charts library.
/// Zero external dependencies — pure Flutter custom painter.
///
/// ## Available Charts
/// - [FlBarChart] — animated bar chart with tap tooltips (v0.0.1)
/// - [FlLineChart] — smooth bezier line chart, multi-line support (v0.1.0)
/// - [FlPieChart] — animated pie and donut chart (v0.5.0)
///
/// ## Coming Soon
/// - FlRadarChart (v0.9.0)
///
/// ## Quick Start
/// ```dart
/// import 'package:fl_pretty_charts/fl_pretty_charts.dart';
///
/// FlPieChart(
///   data: PieChartData(
///     segments: [
///       PieSegment(value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
///       PieSegment(value: 30, label: 'React',   color: Color(0xFF26A69A)),
///       PieSegment(value: 20, label: 'Vue',     color: Color(0xFFFFCA28)),
///       PieSegment(value: 10, label: 'Other',   color: Color(0xFFEF5350)),
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

// ── Common ─────────────────────────────────────────────────────────────────
export 'src/common/chart_animation.dart';
export 'src/common/chart_theme.dart';
export 'src/common/chart_utils.dart';
