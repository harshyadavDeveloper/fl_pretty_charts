/// fl_pretty_charts
///
/// A beautiful, animated Flutter charts library.
/// Zero external dependencies — pure Flutter custom painter.
///
/// ## Available Charts
/// - [FlBarChart] — animated bar chart with tap tooltips (v0.0.1)
/// - [FlLineChart] — smooth bezier line chart, multi-line support (v0.1.0)
/// - [FlPieChart] — animated pie and donut chart (v0.5.0)
/// - [FlRadarChart] — radar/spider chart, multi-dataset (v0.9.0)
///
/// ## Quick Start
/// ```dart
/// import 'package:fl_pretty_charts/fl_pretty_charts.dart';
///
/// FlRadarChart(
///   data: RadarChartData(
///     labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
///     datasets: [
///       RadarDataset(
///         values: [80, 90, 70, 85, 60],
///         label: 'Hero A',
///         style: RadarDatasetStyle(color: Color(0xFF5C6BC0)),
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
