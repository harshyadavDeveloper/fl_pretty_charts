import 'package:flutter/material.dart';
import 'area_chart_data.dart';
import 'area_chart_painter.dart';
import '../common/chart_animation.dart';
import '../common/chart_theme.dart';
import '../common/chart_utils.dart';
import '../common/legend_widget.dart';

/// A beautiful, animated area chart widget.
///
/// Drop [FlAreaChart] anywhere in your widget tree. Supports single and
/// multi-series area charts, stacked mode, smooth bezier curves, gradient
/// fills, dot indicators, and interactive tap tooltips.
///
/// Basic example:
/// ```dart
/// FlAreaChart(
///   data: AreaChartData(
///     series: [
///       AreaSeries(
///         points: [
///           AreaPoint(x: 0, y: 30, label: 'Jan'),
///           AreaPoint(x: 1, y: 80, label: 'Feb'),
///           AreaPoint(x: 2, y: 55, label: 'Mar'),
///         ],
///         label: 'Revenue',
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Stacked area chart:
/// ```dart
/// FlAreaChart(
///   data: AreaChartData(
///     series: [...],
///     stacked: true,
///   ),
/// )
/// ```
class FlAreaChart extends StatefulWidget {
  /// The data and style configuration for this chart.
  final AreaChartData data;

  /// Controls the reveal animation speed and curve.
  final ChartAnimation animation;

  /// Height of the chart canvas. Defaults to `260.0`.
  final double height;

  /// Optional background decoration for the chart container.
  final BoxDecoration? decoration;

  /// Padding around the chart container.
  final EdgeInsets padding;

  /// Optional theme that overrides each series color in order.
  final ChartTheme? theme;

  /// Whether to show the legend below the chart. Defaults to `true`.
  final bool showLegend;

  /// Callback fired when a data point is tapped.
  /// Receives the [AreaPoint], series index, and point index.
  final void Function(AreaPoint point, int seriesIndex, int pointIndex)?
      onPointTapped;

  const FlAreaChart({
    super.key,
    required this.data,
    this.animation = const ChartAnimation(),
    this.height = 260.0,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
    this.theme,
    this.showLegend = true,
    this.onPointTapped,
  });

  @override
  State<FlAreaChart> createState() => _FlAreaChartState();
}

class _FlAreaChartState extends State<FlAreaChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  int _selectedSeriesIndex = -1;
  int _selectedPointIndex = -1;
  late double _maxY;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    assert(
      widget.data.series.isNotEmpty,
      'AreaChartData.series must not be empty',
    );
    _maxY = _resolveMaxY();
    initAnimation(widget.animation, this);
  }

  @override
  void didUpdateWidget(FlAreaChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _maxY = _resolveMaxY();
      _selectedSeriesIndex = -1;
      _selectedPointIndex = -1;
      replayAnimation();
    }
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }

  double _resolveMaxY() {
    if (widget.data.maxY != null) return widget.data.maxY!;

    if (widget.data.stacked) {
      // In stacked mode max is the sum of all series at each point
      double highest = 0;
      final pointCount = widget.data.series.first.points.length;
      for (int i = 0; i < pointCount; i++) {
        double total = 0;
        for (final series in widget.data.series) {
          if (i < series.points.length) total += series.points[i].y;
        }
        if (total > highest) highest = total;
      }
      return ChartUtils.niceMax(highest);
    }

    double highest = 0;
    for (final series in widget.data.series) {
      for (final point in series.points) {
        if (point.y > highest) highest = point.y;
      }
    }
    return ChartUtils.niceMax(highest);
  }

  AreaChartData get _resolvedData {
    if (widget.theme == null) return widget.data;
    return AreaChartData(
      series: List.generate(
        widget.data.series.length,
        (i) => AreaSeries(
          points: widget.data.series[i].points,
          label: widget.data.series[i].label,
          style: AreaSeriesStyle(
            color: widget.theme!.colorAt(i),
            strokeWidth: widget.data.series[i].style.strokeWidth,
            fillOpacity: widget.data.series[i].style.fillOpacity,
            showDots: widget.data.series[i].style.showDots,
            dotRadius: widget.data.series[i].style.dotRadius,
            smooth: widget.data.series[i].style.smooth,
          ),
        ),
      ),
      stacked: widget.data.stacked,
      axisStyle: widget.data.axisStyle,
      tooltipStyle: widget.data.tooltipStyle,
      maxY: widget.data.maxY,
      minY: widget.data.minY,
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (_chartSize == Size.zero) return;

    final painter = AreaChartPainter(
      data: _resolvedData,
      animationProgress: 1.0,
      selectedSeriesIndex: -1,
      selectedPointIndex: -1,
      maxY: _maxY,
    );

    final result = painter.indexFromTap(details.localPosition, _chartSize);
    final si = result[0];
    final pi = result[1];

    setState(() {
      _selectedSeriesIndex = si;
      _selectedPointIndex = pi;
    });

    if (si >= 0 && pi >= 0) {
      widget.onPointTapped?.call(
        widget.data.series[si].points[pi],
        si,
        pi,
      );
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
                    painter: AreaChartPainter(
                      data: resolved,
                      animationProgress: animationValue,
                      selectedSeriesIndex: _selectedSeriesIndex,
                      selectedPointIndex: _selectedPointIndex,
                      maxY: _maxY,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Legend ──────────────────────────────────────────────────────
          if (widget.showLegend && resolved.series.length > 1) ...[
            const SizedBox(height: 12),
            LegendWidget(
              items: List.generate(
                resolved.series.length,
                (i) => LegendItem(
                  color: resolved.series[i].style.color,
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
