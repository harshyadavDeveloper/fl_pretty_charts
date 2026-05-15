import 'package:flutter/material.dart';
import 'line_chart_data.dart';
import 'line_chart_painter.dart';
import '../common/chart_animation.dart';
import '../common/chart_theme.dart';
import '../common/chart_utils.dart';

/// A beautiful, animated line chart widget.
///
/// Drop [FlLineChart] anywhere in your widget tree. Supports single and
/// multi-line charts, smooth bezier curves, gradient area fill, dot
/// indicators, and interactive tap tooltips.
///
/// Basic example:
/// ```dart
/// FlLineChart(
///   data: LineChartData(
///     lines: [
///       LineData(
///         points: [
///           LinePoint(x: 0, y: 30, label: 'Jan'),
///           LinePoint(x: 1, y: 80, label: 'Feb'),
///           LinePoint(x: 2, y: 55, label: 'Mar'),
///         ],
///         label: 'Sales',
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Multi-line example:
/// ```dart
/// FlLineChart(
///   data: LineChartData(
///     lines: [
///       LineData(
///         points: [
///           LinePoint(x: 0, y: 30, label: 'Jan'),
///           LinePoint(x: 1, y: 80, label: 'Feb'),
///           LinePoint(x: 2, y: 55, label: 'Mar'),
///         ],
///         label: 'Revenue',
///         style: LineStyle(color: Colors.indigo),
///       ),
///       LineData(
///         points: [
///           LinePoint(x: 0, y: 20, label: 'Jan'),
///           LinePoint(x: 1, y: 60, label: 'Feb'),
///           LinePoint(x: 2, y: 40, label: 'Mar'),
///         ],
///         label: 'Expenses',
///         style: LineStyle(color: Colors.orange),
///       ),
///     ],
///   ),
///   animation: ChartAnimation.elegant(),
/// )
/// ```
class FlLineChart extends StatefulWidget {
  /// The data and style configuration for this chart.
  final LineChartData data;

  /// Controls the reveal animation speed and curve.
  final ChartAnimation animation;

  /// Height of the chart canvas. Defaults to `260.0`.
  final double height;

  /// Optional background decoration for the chart container.
  final BoxDecoration? decoration;

  /// Padding around the chart container.
  final EdgeInsets padding;

  /// Callback fired when a data point is tapped.
  /// Receives the tapped [LinePoint], its line index, and point index.
  final void Function(LinePoint point, int lineIndex, int pointIndex)?
      onPointTapped;

  /// Optional theme that overrides each line series color in order.
  /// [ChartTheme.colorAt(i)] is applied to line series at index i.
  final ChartTheme? theme;

  const FlLineChart({
    super.key,
    required this.data,
    this.animation = const ChartAnimation(),
    this.height = 260.0,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
    this.onPointTapped,
    this.theme,
  });

  @override
  State<FlLineChart> createState() => _FlLineChartState();
}

class _FlLineChartState extends State<FlLineChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  int _selectedLineIndex = -1;
  int _selectedPointIndex = -1;
  late double _maxY;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    assert(
      widget.data.lines.isNotEmpty,
      'LineChartData.lines must not be empty',
    );
    _maxY = _resolveMaxY();
    initAnimation(widget.animation, this);
  }

  @override
  void didUpdateWidget(FlLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _maxY = _resolveMaxY();
      _selectedLineIndex = -1;
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
    double highest = 0;
    for (final line in widget.data.lines) {
      for (final point in line.points) {
        if (point.y > highest) highest = point.y;
      }
    }
    return ChartUtils.niceMax(highest);
  }

  void _onTapDown(TapDownDetails details) {
    if (_chartSize == Size.zero) return;

    final painter = LineChartPainter(
      data: widget.data,
      animationProgress: 1.0,
      selectedLineIndex: -1,
      selectedPointIndex: -1,
      maxY: _maxY,
    );

    final result = painter.indexFromTap(details.localPosition, _chartSize);
    final lineIndex = result[0];
    final pointIndex = result[1];

    setState(() {
      _selectedLineIndex = lineIndex;
      _selectedPointIndex = pointIndex;
    });

    if (lineIndex >= 0 && pointIndex >= 0) {
      widget.onPointTapped?.call(
        widget.data.lines[lineIndex].points[pointIndex],
        lineIndex,
        pointIndex,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        height: widget.height,
        decoration: widget.decoration,
        child: GestureDetector(
          onTapDown: _onTapDown,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _chartSize = Size(constraints.maxWidth, widget.height);
              return CustomPaint(
                size: _chartSize,
                painter: LineChartPainter(
                  data: widget.theme != null
                      ? LineChartData(
                          lines: List.generate(
                            widget.data.lines.length,
                            (i) => LineData(
                              points: widget.data.lines[i].points,
                              label: widget.data.lines[i].label,
                              style: LineStyle(
                                color: widget.theme!.colorAt(i),
                                strokeWidth:
                                    widget.data.lines[i].style.strokeWidth,
                                showFill: widget.data.lines[i].style.showFill,
                                fillOpacity:
                                    widget.data.lines[i].style.fillOpacity,
                                showDots: widget.data.lines[i].style.showDots,
                                dotRadius: widget.data.lines[i].style.dotRadius,
                                smooth: widget.data.lines[i].style.smooth,
                              ),
                            ),
                          ),
                          axisStyle: widget.data.axisStyle,
                          tooltipStyle: widget.data.tooltipStyle,
                          maxY: widget.data.maxY,
                          minY: widget.data.minY,
                        )
                      : widget.data,
                  animationProgress: animationValue,
                  selectedLineIndex: _selectedLineIndex,
                  selectedPointIndex: _selectedPointIndex,
                  maxY: _maxY,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
