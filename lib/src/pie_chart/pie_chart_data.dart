import 'package:flutter/material.dart';

/// Represents a single segment in a pie or donut chart.
///
/// Each [PieSegment] holds a [value], a display [label], and a [color].
/// An optional [gradient] can be used instead of a solid color.
///
/// Example:
/// ```dart
/// PieSegment(value: 40, label: 'Flutter', color: Color(0xFF5C6BC0))
/// PieSegment(value: 30, label: 'React', color: Color(0xFF26A69A))
/// ```
class PieSegment {
  /// The numeric value this segment represents.
  /// Used to calculate the proportion of the full circle.
  final double value;

  /// The label displayed in the legend for this segment.
  final String label;

  /// The solid color of this segment.
  /// Ignored if [gradient] is provided.
  final Color color;

  /// Optional gradient applied to this segment.
  /// If set, overrides [color].
  final SweepGradient? gradient;

  const PieSegment({
    required this.value,
    required this.label,
    required this.color,
    this.gradient,
  });
}

/// Controls the appearance of the legend displayed below the chart.
///
/// Example:
/// ```dart
/// LegendStyle(
///   show: true,
///   position: LegendPosition.bottom,
///   textStyle: TextStyle(fontSize: 12),
///   dotSize: 10,
///   spacing: 16,
/// )
/// ```
enum LegendPosition { bottom, top }

/// Style configuration for the pie/donut chart legend.
class LegendStyle {
  /// Whether to show the legend. Defaults to `true`.
  final bool show;

  /// Position of the legend relative to the chart.
  final LegendPosition position;

  /// Text style for legend labels.
  final TextStyle textStyle;

  /// Size of the colored dot indicator. Defaults to `10.0`.
  final double dotSize;

  /// Horizontal spacing between legend items. Defaults to `16.0`.
  final double spacing;

  const LegendStyle({
    this.show = true,
    this.position = LegendPosition.bottom,
    this.textStyle = const TextStyle(
      fontSize: 12,
      color: Color(0xFF616161),
    ),
    this.dotSize = 10.0,
    this.spacing = 16.0,
  });
}

/// Style configuration for the center label in donut mode.
///
/// Example:
/// ```dart
/// CenterLabelStyle(
///   title: 'Total',
///   titleStyle: TextStyle(fontSize: 14, color: Colors.grey),
///   value: '1,250',
///   valueStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
/// )
/// ```
class CenterLabelStyle {
  /// The small title text shown above the value.
  final String? title;

  /// Text style for the title. Defaults to grey 13px.
  final TextStyle titleStyle;

  /// The main value text shown in the center.
  final String? value;

  /// Text style for the value. Defaults to bold 22px.
  final TextStyle valueStyle;

  const CenterLabelStyle({
    this.title,
    this.titleStyle = const TextStyle(
      fontSize: 13,
      color: Color(0xFF9E9E9E),
    ),
    this.value,
    this.valueStyle = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Color(0xFF212121),
    ),
  });
}

/// Style configuration for segment tooltip on tap.
class PieTooltipStyle {
  /// Background color of the tooltip bubble.
  final Color backgroundColor;

  /// Text style for the tooltip content.
  final TextStyle textStyle;

  /// Corner radius of the tooltip bubble.
  final double borderRadius;

  /// Inner padding of the tooltip bubble.
  final EdgeInsets padding;

  const PieTooltipStyle({
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

/// The main data class for [FlPieChart].
///
/// Controls segments, donut mode, gaps, legend, and center label.
///
/// Basic pie chart:
/// ```dart
/// PieChartData(
///   segments: [
///     PieSegment(value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
///     PieSegment(value: 30, label: 'React',   color: Color(0xFF26A69A)),
///     PieSegment(value: 20, label: 'Vue',     color: Color(0xFFFFCA28)),
///     PieSegment(value: 10, label: 'Other',   color: Color(0xFFEF5350)),
///   ],
/// )
/// ```
///
/// Donut chart:
/// ```dart
/// PieChartData(
///   segments: [...],
///   donut: true,
///   donutRadius: 0.55,
///   centerLabel: CenterLabelStyle(title: 'Total', value: '100'),
/// )
/// ```
class PieChartData {
  /// The list of segments. Must not be empty.
  final List<PieSegment> segments;

  /// Whether to render as a donut chart. Defaults to `false`.
  final bool donut;

  /// The inner radius fraction for donut mode (0.0 to 1.0).
  /// `0.5` means the hole is 50% of the total radius. Defaults to `0.55`.
  final double donutRadius;

  /// Gap in degrees between each segment. Defaults to `1.5`.
  final double segmentGap;

  /// How much a tapped segment expands outward in pixels. Defaults to `10.0`.
  final double expandOffset;

  /// Legend configuration.
  final LegendStyle legendStyle;

  /// Center label config for donut mode.
  final CenterLabelStyle? centerLabel;

  /// Tooltip style for tapped segments.
  final PieTooltipStyle tooltipStyle;

  /// Starting angle in degrees. `0` = 3 o'clock, `-90` = 12 o'clock.
  /// Defaults to `-90` (top of chart).
  final double startAngle;

  const PieChartData({
    required this.segments,
    this.donut = false,
    this.donutRadius = 0.55,
    this.segmentGap = 1.5,
    this.expandOffset = 10.0,
    this.legendStyle = const LegendStyle(),
    this.centerLabel,
    this.tooltipStyle = const PieTooltipStyle(),
    this.startAngle = -90,
  });
}
