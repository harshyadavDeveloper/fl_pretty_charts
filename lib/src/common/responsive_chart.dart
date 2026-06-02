import 'package:flutter/material.dart';

/// Defines the screen width breakpoints for responsive chart behavior.
///
/// Charts automatically switch between [small], [medium], and [large]
/// configs based on the available width.
///
/// Default breakpoints:
/// - Small: width < 360px (compact phones)
/// - Medium: 360px ≤ width < 600px (standard phones)
/// - Large: width ≥ 600px (tablets, desktops)
///
/// Example:
/// ```dart
/// ChartBreakpoints(
///   smallMaxWidth: 320,
///   mediumMaxWidth: 500,
/// )
/// ```
class ChartBreakpoints {
  /// Maximum width for the small breakpoint. Defaults to `360.0`.
  final double smallMaxWidth;

  /// Maximum width for the medium breakpoint. Defaults to `600.0`.
  final double mediumMaxWidth;

  const ChartBreakpoints({
    this.smallMaxWidth = 360.0,
    this.mediumMaxWidth = 600.0,
  });

  /// Returns the [ScreenSize] for the given [width].
  ScreenSize resolve(double width) {
    if (width < smallMaxWidth) return ScreenSize.small;
    if (width < mediumMaxWidth) return ScreenSize.medium;
    return ScreenSize.large;
  }
}

/// The resolved screen size category for a chart.
enum ScreenSize { small, medium, large }

/// Configuration for a chart at a specific breakpoint.
///
/// Each property has a sensible default so you only need to override
/// what you want to change.
///
/// Example:
/// ```dart
/// ResponsiveChartConfig(
///   height: 180,
///   padding: EdgeInsets.all(8),
///   yAxisDivisions: 3,
///   showGrid: true,
///   labelFontSize: 9,
/// )
/// ```
class ResponsiveChartConfig {
  /// Chart height at this breakpoint.
  final double? height;

  /// Chart padding at this breakpoint.
  final EdgeInsets? padding;

  /// Number of y-axis divisions at this breakpoint.
  final int? yAxisDivisions;

  /// Whether to show grid lines at this breakpoint.
  final bool? showGrid;

  /// Font size for axis labels at this breakpoint.
  final double? labelFontSize;

  /// Whether to show dot indicators at this breakpoint (line/area charts).
  final bool? showDots;

  const ResponsiveChartConfig({
    this.height,
    this.padding,
    this.yAxisDivisions,
    this.showGrid,
    this.labelFontSize,
    this.showDots,
  });
}

/// A wrapper that makes any fl_pretty_charts widget responsive.
///
/// [FlResponsiveChart] watches the available width and applies the
/// matching [ResponsiveChartConfig] — adjusting height, padding, label
/// density, and grid lines automatically.
///
/// The [builder] receives the resolved [ResponsiveChartConfig] so you
/// can wire it into your chart widget's parameters.
///
/// Basic example:
/// ```dart
/// FlResponsiveChart(
///   small: ResponsiveChartConfig(
///     height: 180,
///     yAxisDivisions: 3,
///     showGrid: false,
///     labelFontSize: 9,
///   ),
///   medium: ResponsiveChartConfig(
///     height: 220,
///     yAxisDivisions: 4,
///     labelFontSize: 10,
///   ),
///   large: ResponsiveChartConfig(
///     height: 280,
///     yAxisDivisions: 5,
///     labelFontSize: 11,
///   ),
///   builder: (context, config) => FlBarChart(
///     data: BarChartData(
///       bars: myBars,
///       axisStyle: AxisStyle(
///         yAxisDivisions: config.yAxisDivisions ?? 5,
///         showGrid: config.showGrid ?? true,
///         labelStyle: TextStyle(fontSize: config.labelFontSize ?? 11),
///       ),
///     ),
///     height: config.height ?? 260,
///     padding: config.padding ?? EdgeInsets.all(16),
///   ),
/// )
/// ```
class FlResponsiveChart extends StatelessWidget {
  /// Config applied when width < [breakpoints.smallMaxWidth].
  final ResponsiveChartConfig small;

  /// Config applied when [breakpoints.smallMaxWidth] ≤ width
  /// < [breakpoints.mediumMaxWidth].
  final ResponsiveChartConfig medium;

  /// Config applied when width ≥ [breakpoints.mediumMaxWidth].
  final ResponsiveChartConfig large;

  /// Custom breakpoint thresholds. Uses defaults if not provided.
  final ChartBreakpoints breakpoints;

  /// Builder called with the resolved [ResponsiveChartConfig].
  /// Return your chart widget here.
  final Widget Function(BuildContext context, ResponsiveChartConfig config)
      builder;

  /// Whether to print the resolved breakpoint in debug mode.
  /// Useful during development. Defaults to `false`.
  final bool debugLabel;

  const FlResponsiveChart({
    super.key,
    required this.small,
    required this.medium,
    required this.large,
    required this.builder,
    this.breakpoints = const ChartBreakpoints(),
    this.debugLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final screenSize = breakpoints.resolve(width);
        final config = _resolveConfig(screenSize);

        if (debugLabel) {
          debugPrint(
            'FlResponsiveChart: width=$width '
            '→ ${screenSize.name} '
            '(height=${config.height}, '
            'divisions=${config.yAxisDivisions})',
          );
        }

        return builder(context, config);
      },
    );
  }

  ResponsiveChartConfig _resolveConfig(ScreenSize size) {
    switch (size) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium;
      case ScreenSize.large:
        return large;
    }
  }
}

/// A pre-configured responsive bar chart that auto-adapts to screen size.
///
/// Uses sensible defaults for small/medium/large breakpoints.
/// Override any config to customize behavior.
///
/// Example:
/// ```dart
/// FlResponsiveBarChart(
///   data: myBarChartData,
///   small: ResponsiveChartConfig(height: 160, yAxisDivisions: 3),
/// )
/// ```
class FlResponsiveBarChart extends StatelessWidget {
  /// The chart data.
  final dynamic data;

  /// Optional small config override.
  final ResponsiveChartConfig? small;

  /// Optional medium config override.
  final ResponsiveChartConfig? medium;

  /// Optional large config override.
  final ResponsiveChartConfig? large;

  /// Custom breakpoints.
  final ChartBreakpoints breakpoints;

  /// Builder that receives the resolved config and returns the chart.
  final Widget Function(BuildContext context, ResponsiveChartConfig config)
      builder;

  const FlResponsiveBarChart({
    super.key,
    required this.data,
    required this.builder,
    this.small,
    this.medium,
    this.large,
    this.breakpoints = const ChartBreakpoints(),
  });

  @override
  Widget build(BuildContext context) {
    return FlResponsiveChart(
      breakpoints: breakpoints,
      small: small ??
          const ResponsiveChartConfig(
            height: 180,
            padding: EdgeInsets.all(8),
            yAxisDivisions: 3,
            showGrid: false,
            labelFontSize: 9,
            showDots: false,
          ),
      medium: medium ??
          const ResponsiveChartConfig(
            height: 220,
            padding: EdgeInsets.all(12),
            yAxisDivisions: 4,
            showGrid: true,
            labelFontSize: 10,
            showDots: true,
          ),
      large: large ??
          const ResponsiveChartConfig(
            height: 280,
            padding: EdgeInsets.all(16),
            yAxisDivisions: 5,
            showGrid: true,
            labelFontSize: 11,
            showDots: true,
          ),
      builder: builder,
    );
  }
}

/// Extension on [ResponsiveChartConfig] providing merge/fallback helpers.
extension ResponsiveChartConfigX on ResponsiveChartConfig {
  /// Returns [value] if this config's field is null, otherwise this field.
  double resolveHeight([double fallback = 260.0]) => height ?? fallback;
  EdgeInsets resolvePadding([EdgeInsets fallback = const EdgeInsets.all(16)]) =>
      padding ?? fallback;
  int resolveYAxisDivisions([int fallback = 5]) => yAxisDivisions ?? fallback;
  bool resolveShowGrid([bool fallback = true]) => showGrid ?? fallback;
  double resolveLabelFontSize([double fallback = 11.0]) =>
      labelFontSize ?? fallback;
  bool resolveShowDots([bool fallback = true]) => showDots ?? fallback;
}
