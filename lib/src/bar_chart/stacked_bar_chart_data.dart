import 'package:flutter/material.dart';

/// Represents a single series (layer) in a stacked bar chart.
///
/// Each [StackedBarSeries] has a [label], a [color], and a list of
/// [values] — one value per bar group.
///
/// Example:
/// ```dart
/// StackedBarSeries(
///   label: 'Revenue',
///   color: Color(0xFF5C6BC0),
///   values: [30, 50, 40, 60],
/// )
/// ```
class StackedBarSeries {
  /// Display name for this series. Used in the legend.
  final String label;

  /// Color of this series segment in the stack.
  final Color color;

  /// One value per bar group. Length must match [StackedBarChartData.groups].
  final List<double> values;

  const StackedBarSeries({
    required this.label,
    required this.color,
    required this.values,
  });
}

/// Style configuration for stacked bars.
class StackedBarStyle {
  /// Corner radius for the top of the topmost segment. Defaults to `6.0`.
  final double borderRadius;

  /// Width of each bar as a fraction of the available slot. Defaults to `0.6`.
  final double barWidthFraction;

  const StackedBarStyle({
    this.borderRadius = 6.0,
    this.barWidthFraction = 0.6,
  });
}

/// Style configuration for axis labels and grid lines.
class StackedAxisStyle {
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

  const StackedAxisStyle({
    this.labelStyle = const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
    this.gridColor = const Color(0xFF9E9E9E),
    this.gridOpacity = 0.2,
    this.showGrid = true,
    this.yAxisDivisions = 5,
  });
}

/// Tooltip style for stacked bar chart.
class StackedTooltipStyle {
  /// Background color of the tooltip bubble.
  final Color backgroundColor;

  /// Text style for the tooltip content.
  final TextStyle textStyle;

  /// Corner radius of the tooltip bubble.
  final double borderRadius;

  /// Inner padding of the tooltip bubble.
  final EdgeInsets padding;

  const StackedTooltipStyle({
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

/// The main data class for [FlStackedBarChart].
///
/// Example:
/// ```dart
/// StackedBarChartData(
///   groups: ['Q1', 'Q2', 'Q3', 'Q4'],
///   series: [
///     StackedBarSeries(
///       label: 'Revenue',
///       color: Color(0xFF5C6BC0),
///       values: [30, 50, 40, 60],
///     ),
///     StackedBarSeries(
///       label: 'Expenses',
///       color: Color(0xFF26A69A),
///       values: [20, 30, 25, 35],
///     ),
///   ],
/// )
/// ```
class StackedBarChartData {
  /// The x-axis group labels. One label per bar.
  final List<String> groups;

  /// The data series to stack. Each series adds on top of the previous.
  final List<StackedBarSeries> series;

  /// Bar appearance configuration.
  final StackedBarStyle barStyle;

  /// Axis and grid configuration.
  final StackedAxisStyle axisStyle;

  /// Tooltip appearance configuration.
  final StackedTooltipStyle tooltipStyle;

  /// Whether to normalize each bar to 100%. Defaults to `false`.
  final bool percentageMode;

  /// Optional fixed maximum y value. Auto-calculated if null.
  final double? maxY;

  const StackedBarChartData({
    required this.groups,
    required this.series,
    this.barStyle = const StackedBarStyle(),
    this.axisStyle = const StackedAxisStyle(),
    this.tooltipStyle = const StackedTooltipStyle(),
    this.percentageMode = false,
    this.maxY,
  });
}
