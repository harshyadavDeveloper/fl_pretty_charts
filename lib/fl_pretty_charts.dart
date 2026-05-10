/// fl_pretty_charts
///
/// A beautiful, animated Flutter charts library.
/// Zero external dependencies — pure Flutter custom painter.
///
/// ## Available Charts (v0.0.1)
/// - [FlBarChart] — animated bar chart with tap tooltips
///
/// ## Coming Soon
/// - FlLineChart (v0.1.0)
/// - FlPieChart / FlDonutChart (v0.5.0)
/// - FlRadarChart (v0.9.0)
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

// ── Common ─────────────────────────────────────────────────────────────────
export 'src/common/chart_animation.dart';
export 'src/common/chart_theme.dart';
export 'src/common/chart_utils.dart';
