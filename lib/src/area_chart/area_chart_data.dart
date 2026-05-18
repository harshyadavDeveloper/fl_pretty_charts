import 'package:flutter/material.dart';

/// Represents a single data point on an area chart.
///
/// Example:
/// ```dart
/// AreaPoint(x: 0, y: 30, label: 'Jan')
/// AreaPoint(x: 1, y: 80, label: 'Feb')
/// ```
class AreaPoint {
  /// Horizontal position index of this point.
  final double x;

  /// The value this point represents on the y-axis.
  final double y;

  /// Label displayed on the x-axis below this point.
  final String label;

  const AreaPoint({
    required this.x,
    required this.y,
    required this.label,
  });
}

/// Style configuration for a single area series.
///
/// Example:
/// ```dart
/// AreaSeriesStyle(
///   color: Color(0xFF5C6BC0),
///   strokeWidth: 2.5,
///   fillOpacity: 0.3,
///   showDots: true,
///   smooth: true,
/// )
/// ```
class AreaSeriesStyle {
  /// The primary color of this series — used for stroke and fill base.
  final Color color;

  /// Width of the line stroke. Defaults to `2.5`.
  final double strokeWidth;

  /// Opacity of the filled area. Defaults to `0.3`.
  final double fillOpacity;

  /// Whether to show dot indicators at each data point.
  final bool showDots;

  /// Radius of the dot indicators. Defaults to `4.0`.
  final double dotRadius;

  /// Whether to use smooth bezier curves. Defaults to `true`.
  final bool smooth;

  /// Optional gradient override for the fill area.
  /// If null, [color] with [fillOpacity] is used.
  final LinearGradient? fillGradient;

  const AreaSeriesStyle({
    this.color = const Color(0xFF5C6BC0),
    this.strokeWidth = 2.5,
    this.fillOpacity = 0.3,
    this.showDots = true,
    this.dotRadius = 4.0,
    this.smooth = true,
    this.fillGradient,
  });
}

/// Represents a single area series on the chart.
///
/// Example:
/// ```dart
/// AreaSeries(
///   points: [
///     AreaPoint(x: 0, y: 30, label: 'Jan'),
///     AreaPoint(x: 1, y: 80, label: 'Feb'),
///   ],
///   label: 'Revenue',
///   style: AreaSeriesStyle(color: Color(0xFF5C6BC0)),
/// )
/// ```
class AreaSeries {
  /// The ordered list of data points.
  final List<AreaPoint> points;

  /// Display name for this series. Used in the legend.
  final String label;

  /// Visual style for this series.
  final AreaSeriesStyle style;

  const AreaSeries({
    required this.points,
    required this.label,
    this.style = const AreaSeriesStyle(),
  });
}

/// Style configuration for axes and grid lines.
class AreaAxisStyle {
  /// Text style for axis labels.
  final TextStyle labelStyle;

  /// Color of the horizontal grid lines.
  final Color gridColor;

  /// Opacity of the grid lines. Defaults to `0.2`.
  final double gridOpacity;

  /// Whether to show horizontal grid lines. Defaults to `true`.
  final bool showGrid;

  /// Number of y-axis divisions. Defaults to `5`.
  final int yAxisDivisions;

  const AreaAxisStyle({
    this.labelStyle = const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
    this.gridColor = const Color(0xFF9E9E9E),
    this.gridOpacity = 0.2,
    this.showGrid = true,
    this.yAxisDivisions = 5,
  });
}

/// Tooltip style for area chart.
class AreaTooltipStyle {
  /// Background color of the tooltip bubble.
  final Color backgroundColor;

  /// Text style for the tooltip content.
  final TextStyle textStyle;

  /// Corner radius of the tooltip bubble.
  final double borderRadius;

  /// Inner padding of the tooltip bubble.
  final EdgeInsets padding;

  const AreaTooltipStyle({
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

/// The main data class for [FlAreaChart].
///
/// Basic example:
/// ```dart
/// AreaChartData(
///   series: [
///     AreaSeries(
///       points: [
///         AreaPoint(x: 0, y: 30, label: 'Jan'),
///         AreaPoint(x: 1, y: 80, label: 'Feb'),
///         AreaPoint(x: 2, y: 55, label: 'Mar'),
///       ],
///       label: 'Revenue',
///     ),
///   ],
/// )
/// ```
///
/// Stacked mode:
/// ```dart
/// AreaChartData(
///   series: [...],
///   stacked: true,
/// )
/// ```
class AreaChartData {
  /// One or more area series to render.
  final List<AreaSeries> series;

  /// Whether to stack series on top of each other. Defaults to `false`.
  final bool stacked;

  /// Axis and grid style configuration.
  final AreaAxisStyle axisStyle;

  /// Tooltip style configuration.
  final AreaTooltipStyle tooltipStyle;

  /// Optional fixed maximum y value. Auto-calculated if null.
  final double? maxY;

  /// Minimum y value. Defaults to `0`.
  final double minY;

  const AreaChartData({
    required this.series,
    this.stacked = false,
    this.axisStyle = const AreaAxisStyle(),
    this.tooltipStyle = const AreaTooltipStyle(),
    this.maxY,
    this.minY = 0,
  });
}
