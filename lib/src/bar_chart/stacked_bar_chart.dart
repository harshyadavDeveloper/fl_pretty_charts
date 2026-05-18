import 'package:flutter/material.dart';
import 'stacked_bar_chart_data.dart';
import 'stacked_bar_chart_painter.dart';
import '../common/chart_animation.dart';
import '../common/chart_theme.dart';
import '../common/chart_utils.dart';
import '../common/legend_widget.dart';

/// A beautiful, animated stacked bar chart widget.
///
/// Drop [FlStackedBarChart] anywhere in your widget tree. Each bar is
/// composed of multiple series stacked on top of each other.
/// Supports percentage mode, tap-to-highlight, legend, and theming.
///
/// Basic example:
/// ```dart
/// FlStackedBarChart(
///   data: StackedBarChartData(
///     groups: ['Q1', 'Q2', 'Q3', 'Q4'],
///     series: [
///       StackedBarSeries(
///         label: 'Revenue',
///         color: Color(0xFF5C6BC0),
///         values: [30, 50, 40, 60],
///       ),
///       StackedBarSeries(
///         label: 'Expenses',
///         color: Color(0xFF26A69A),
///         values: [20, 30, 25, 35],
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Percentage mode:
/// ```dart
/// FlStackedBarChart(
///   data: StackedBarChartData(
///     groups: ['Q1', 'Q2', 'Q3', 'Q4'],
///     series: [...],
///     percentageMode: true,
///   ),
/// )
/// ```
class FlStackedBarChart extends StatefulWidget {
  /// The data and style configuration for this chart.
  final StackedBarChartData data;

  /// Controls the reveal animation speed and curve.
  final ChartAnimation animation;

  /// Height of the chart canvas. Defaults to `280.0`.
  final double height;

  /// Optional background decoration for the chart container.
  final BoxDecoration? decoration;

  /// Padding around the chart container.
  final EdgeInsets padding;

  /// Optional theme that overrides series colors in order.
  final ChartTheme? theme;

  /// Whether to show the legend below the chart. Defaults to `true`.
  final bool showLegend;

  /// Callback fired when a segment is tapped.
  /// Receives the [StackedBarSeries], group index, and series index.
  final void Function(
    StackedBarSeries series,
    int groupIndex,
    int seriesIndex,
  )? onSegmentTapped;

  const FlStackedBarChart({
    super.key,
    required this.data,
    this.animation = const ChartAnimation(),
    this.height = 280.0,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
    this.theme,
    this.showLegend = true,
    this.onSegmentTapped,
  });

  @override
  State<FlStackedBarChart> createState() => _FlStackedBarChartState();
}

class _FlStackedBarChartState extends State<FlStackedBarChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  int _selectedGroupIndex = -1;
  int _selectedSeriesIndex = -1;
  late double _maxY;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    assert(
      widget.data.groups.isNotEmpty,
      'StackedBarChartData.groups must not be empty',
    );
    assert(
      widget.data.series.isNotEmpty,
      'StackedBarChartData.series must not be empty',
    );
    _maxY = _resolveMaxY();
    initAnimation(widget.animation, this);
  }

  @override
  void didUpdateWidget(FlStackedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _maxY = _resolveMaxY();
      _selectedGroupIndex = -1;
      _selectedSeriesIndex = -1;
      replayAnimation();
    }
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }

  double _resolveMaxY() {
    if (widget.data.percentageMode) return 100.0;
    if (widget.data.maxY != null) return widget.data.maxY!;

    double highest = 0;
    for (int gi = 0; gi < widget.data.groups.length; gi++) {
      double groupTotal = 0;
      for (final series in widget.data.series) {
        if (gi < series.values.length) groupTotal += series.values[gi];
      }
      if (groupTotal > highest) highest = groupTotal;
    }
    return ChartUtils.niceMax(highest);
  }

  StackedBarChartData get _resolvedData {
    if (widget.theme == null) return widget.data;
    return StackedBarChartData(
      groups: widget.data.groups,
      series: List.generate(
        widget.data.series.length,
        (i) => StackedBarSeries(
          label: widget.data.series[i].label,
          color: widget.theme!.colorAt(i),
          values: widget.data.series[i].values,
        ),
      ),
      barStyle: widget.data.barStyle,
      axisStyle: widget.data.axisStyle,
      tooltipStyle: widget.data.tooltipStyle,
      percentageMode: widget.data.percentageMode,
      maxY: widget.data.maxY,
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (_chartSize == Size.zero) return;

    final painter = StackedBarChartPainter(
      data: _resolvedData,
      animationProgress: 1.0,
      selectedGroupIndex: -1,
      selectedSeriesIndex: -1,
      maxY: _maxY,
    );

    final result = painter.indexFromTap(details.localPosition, _chartSize);
    final gi = result[0];
    final si = result[1];

    setState(() {
      _selectedGroupIndex = gi;
      _selectedSeriesIndex = si;
    });

    if (gi >= 0 && si >= 0) {
      widget.onSegmentTapped?.call(widget.data.series[si], gi, si);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedData;
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Chart canvas ────────────────────────────────────────────────
          Container(
            height: widget.height,
            decoration: widget.decoration,
            child: GestureDetector(
              onTapDown: _onTapDown,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _chartSize = Size(constraints.maxWidth, widget.height);
                  return CustomPaint(
                    size: _chartSize,
                    painter: StackedBarChartPainter(
                      data: resolved,
                      animationProgress: animationValue,
                      selectedGroupIndex: _selectedGroupIndex,
                      selectedSeriesIndex: _selectedSeriesIndex,
                      maxY: _maxY,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Legend ──────────────────────────────────────────────────────
          if (widget.showLegend) ...[
            const SizedBox(height: 12),
            LegendWidget(
              items: List.generate(
                resolved.series.length,
                (i) => LegendItem(
                  color: resolved.series[i].color,
                  label: resolved.series[i].label,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
