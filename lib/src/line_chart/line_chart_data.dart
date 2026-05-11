import 'package:flutter/material.dart';

/// Represents a single data point on a line chart.
///
/// Each [LinePoint] holds an [x] and [y] value. The [x] value
/// is used for spacing along the horizontal axis and [label]
/// is shown on the x-axis below the point.
///
/// Example:
/// ```dart
/// LinePoint(x: 0, y: 30, label: 'Jan')
/// LinePoint(x: 1, y: 80, label: 'Feb')
/// ```
class LinePoint {
  /// Horizontal position index of this point.
  final double x;

  /// The value this point represents on the y-axis.
  final double y;

  /// Label displayed on the x-axis below this point.
  final String label;

  const LinePoint({
    required this.x,
    required this.y,
    required this.label,
  });
}

/// Style configuration for a single line series.
///
/// Controls stroke width, color, gradient fill, and dot appearance.
///
/// Example:
/// ```dart
/// LineStyle(
///   color: Colors.indigo,
///   strokeWidth: 3.0,
///   gradient: LinearGradient(
///     colors: [Colors.indigo, Colors.teal],
///   ),
///   showDots: true,
///   dotRadius: 5.0,
/// )
/// ```
class LineStyle {
  /// The color of the line stroke.
  final Color color;

  /// Width of the line stroke. Defaults to `3.0`.
  final double strokeWidth;

  /// Optional gradient applied to the line stroke.
  /// If set, overrides [color] for the line itself.
  final LinearGradient? gradient;

  /// Whether to fill the area below the line with a gradient.
  /// Defaults to `true`.
  final bool showFill;

  /// Opacity of the area fill gradient. Defaults to `0.2`.
  final double fillOpacity;

  /// Whether to show dot indicators at each data point.
  /// Defaults to `true`.
  final bool showDots;

  /// Radius of the dot indicators. Defaults to `4.5`.
  final double dotRadius;

  /// Whether to use smooth bezier curves between points.
  /// If false, straight lines are drawn. Defaults to `true`.
  final bool smooth;

  const LineStyle({
    this.color = const Color(0xFF5C6BC0),
    this.strokeWidth = 3.0,
    this.gradient,
    this.showFill = true,
    this.fillOpacity = 0.2,
    this.showDots = true,
    this.dotRadius = 4.5,
    this.smooth = true,
  });
}

/// Represents a single line series on the chart.
///
/// A [LineData] holds a list of [LinePoint] objects and a [LineStyle]
/// that controls how the line looks. Multiple [LineData] objects can
/// be passed to [LineChartData] to render a multi-line chart.
///
/// Example:
/// ```dart
/// LineData(
///   points: [
///     LinePoint(x: 0, y: 30, label: 'Jan'),
///     LinePoint(x: 1, y: 80, label: 'Feb'),
///     LinePoint(x: 2, y: 55, label: 'Mar'),
///   ],
///   label: 'Revenue',
///   style: LineStyle(color: Colors.indigo),
/// )
/// ```
class LineData {
  /// The ordered list of points that make up this line.
  final List<LinePoint> points;

  /// Display name for this line series. Used in legends.
  final String label;

  /// Visual style for this line series.
  final LineStyle style;

  const LineData({
    required this.points,
    required this.label,
    this.style = const LineStyle(),
  });
}

/// The main data class for [FlLineChart].
///
/// Holds one or more [LineData] series and all visual configuration.
///
/// Example:
/// ```dart
/// LineChartData(
///   lines: [
///     LineData(
///       points: [
///         LinePoint(x: 0, y: 30, label: 'Jan'),
///         LinePoint(x: 1, y: 80, label: 'Feb'),
///         LinePoint(x: 2, y: 55, label: 'Mar'),
///       ],
///       label: 'Sales',
///       style: LineStyle(color: Colors.indigo),
///     ),
///   ],
/// )
/// ```
class LineChartData {
  /// One or more line series to render on the chart.
  final List<LineData> lines;

  /// Style config for axes and grid lines.
  final AxisLineStyle axisStyle;

  /// Style config for tap tooltips.
  final LineTooltipStyle tooltipStyle;

  /// Optional fixed maximum y value.
  /// If null, derived automatically from the highest point + 10% padding.
  final double? maxY;

  /// Minimum y value. Defaults to `0`.
  final double minY;

  const LineChartData({
    required this.lines,
    this.axisStyle = const AxisLineStyle(),
    this.tooltipStyle = const LineTooltipStyle(),
    this.maxY,
    this.minY = 0,
  });
}

/// Style configuration for axes and grid lines on a line chart.
class AxisLineStyle {
  /// Text style for axis labels.
  final TextStyle labelStyle;

  /// Color of the horizontal grid lines.
  final Color gridColor;

  /// Opacity of the grid lines.
  final double gridOpacity;

  /// Whether to show horizontal grid lines. Defaults to `true`.
  final bool showGrid;

  /// Number of y-axis divisions. Defaults to `5`.
  final int yAxisDivisions;

  const AxisLineStyle({
    this.labelStyle = const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
    this.gridColor = const Color(0xFF9E9E9E),
    this.gridOpacity = 0.2,
    this.showGrid = true,
    this.yAxisDivisions = 5,
  });
}

/// Tooltip style for [FlLineChart].
class LineTooltipStyle {
  /// Background color of the tooltip bubble.
  final Color backgroundColor;

  /// Text style for the value shown in the tooltip.
  final TextStyle textStyle;

  /// Corner radius of the tooltip bubble.
  final double borderRadius;

  /// Inner padding of the tooltip bubble.
  final EdgeInsets padding;

  const LineTooltipStyle({
    this.backgroundColor = const Color(0xDD000000),
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });
}
