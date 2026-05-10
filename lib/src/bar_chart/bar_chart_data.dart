import 'package:flutter/material.dart';

/// Represents a single bar in the chart.
///
/// Each [BarData] holds a [value], a display [label] shown on the x-axis,
/// and an optional [color] that overrides the theme color for that bar.
///
/// Example:
/// ```dart
/// BarData(value: 42.0, label: 'Jan', color: Colors.blue)
/// ```
class BarData {
  /// The numeric value this bar represents.
  final double value;

  /// The label displayed below this bar on the x-axis.
  final String label;

  /// Optional color override for this specific bar.
  /// If null, the chart theme color is used.
  final Color? color;

  const BarData({
    required this.value,
    required this.label,
    this.color,
  });
}

/// Style configuration for bars.
///
/// Controls the visual appearance of all bars in the chart —
/// radius, width, gradient, and spacing.
///
/// Example:
/// ```dart
/// BarStyle(
///   borderRadius: 8.0,
///   barWidthFraction: 0.5,
///   gradient: LinearGradient(
///     colors: [Colors.blue, Colors.purple],
///     begin: Alignment.bottomCenter,
///     end: Alignment.topCenter,
///   ),
/// )
/// ```
class BarStyle {
  /// Corner radius for the top of each bar.
  /// Defaults to `6.0`.
  final double borderRadius;

  /// Width of each bar as a fraction of the available slot width.
  /// Value between `0.1` and `1.0`. Defaults to `0.55`.
  final double barWidthFraction;

  /// Optional gradient applied to all bars.
  /// If null, [BarChartData.defaultColor] is used as a solid color.
  final LinearGradient? gradient;

  const BarStyle({
    this.borderRadius = 6.0,
    this.barWidthFraction = 0.55,
    this.gradient,
  });
}

/// Style configuration for axis labels and grid lines.
///
/// Controls the appearance of x/y axis labels and the background grid.
///
/// Example:
/// ```dart
/// AxisStyle(
///   labelStyle: TextStyle(fontSize: 11, color: Colors.grey),
///   gridColor: Colors.grey,
///   gridOpacity: 0.2,
///   showGrid: true,
/// )
/// ```
class AxisStyle {
  /// Text style for axis labels (x and y).
  final TextStyle labelStyle;

  /// Color of the horizontal grid lines.
  final Color gridColor;

  /// Opacity of the grid lines. Value between `0.0` and `1.0`.
  final double gridOpacity;

  /// Whether to show horizontal grid lines. Defaults to `true`.
  final bool showGrid;

  /// Number of y-axis grid lines / labels to display.
  /// Defaults to `5`.
  final int yAxisDivisions;

  const AxisStyle({
    this.labelStyle = const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
    this.gridColor = const Color(0xFF9E9E9E),
    this.gridOpacity = 0.2,
    this.showGrid = true,
    this.yAxisDivisions = 5,
  });
}

/// Tooltip style shown when a bar is tapped.
///
/// Example:
/// ```dart
/// TooltipStyle(
///   backgroundColor: Colors.black87,
///   textStyle: TextStyle(color: Colors.white, fontSize: 12),
///   borderRadius: 6.0,
///   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
/// )
/// ```
class TooltipStyle {
  /// Background color of the tooltip bubble.
  final Color backgroundColor;

  /// Text style for the value displayed in the tooltip.
  final TextStyle textStyle;

  /// Corner radius of the tooltip bubble.
  final double borderRadius;

  /// Inner padding of the tooltip bubble.
  final EdgeInsets padding;

  const TooltipStyle({
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

/// The main data class for [FlBarChart].
///
/// Holds the list of bars and all visual configuration.
///
/// Example:
/// ```dart
/// BarChartData(
///   bars: [
///     BarData(value: 30, label: 'Mon'),
///     BarData(value: 80, label: 'Tue'),
///     BarData(value: 55, label: 'Wed'),
///   ],
///   defaultColor: Colors.indigo,
///   barStyle: BarStyle(borderRadius: 10),
///   axisStyle: AxisStyle(showGrid: true),
/// )
/// ```
class BarChartData {
  /// The list of bars to display. Must not be empty.
  final List<BarData> bars;

  /// Fallback color for bars that don't have an individual [BarData.color].
  final Color defaultColor;

  /// Style config for bar appearance.
  final BarStyle barStyle;

  /// Style config for axes and grid.
  final AxisStyle axisStyle;

  /// Style config for the tap tooltip.
  final TooltipStyle tooltipStyle;

  /// Optional fixed maximum y-axis value.
  /// If null, it is derived from the highest bar value + 10% padding.
  final double? maxY;

  /// Optional fixed minimum y-axis value. Defaults to `0`.
  final double minY;

  const BarChartData({
    required this.bars,
    this.defaultColor = const Color(0xFF5C6BC0),
    this.barStyle = const BarStyle(),
    this.axisStyle = const AxisStyle(),
    this.tooltipStyle = const TooltipStyle(),
    this.maxY,
    this.minY = 0,
  }) : assert(bars.length > 0, 'BarChartData.bars must not be empty');
}
