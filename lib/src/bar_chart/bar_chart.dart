import 'package:flutter/material.dart';
import 'bar_chart_data.dart';
import 'bar_chart_painter.dart';
import '../common/chart_animation.dart';
import '../common/chart_theme.dart';
import '../common/chart_utils.dart';

/// A beautiful, animated bar chart widget.
///
/// Drop [FlBarChart] anywhere in your widget tree. Pass a [BarChartData]
/// to configure bars, colors, axes, and tooltips. Tap any bar to show
/// an interactive tooltip.
///
/// Basic example:
/// ```dart
/// FlBarChart(
///   data: BarChartData(
///     bars: [
///       BarData(value: 30, label: 'Mon'),
///       BarData(value: 80, label: 'Tue'),
///       BarData(value: 55, label: 'Wed'),
///       BarData(value: 65, label: 'Thu'),
///       BarData(value: 40, label: 'Fri'),
///     ],
///   ),
/// )
/// ```
///
/// With custom animation and gradient:
/// ```dart
/// FlBarChart(
///   data: BarChartData(
///     bars: [
///       BarData(value: 120, label: 'Q1'),
///       BarData(value: 200, label: 'Q2'),
///       BarData(value: 170, label: 'Q3'),
///       BarData(value: 240, label: 'Q4'),
///     ],
///     barStyle: BarStyle(
///       gradient: LinearGradient(
///         colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
///         begin: Alignment.bottomCenter,
///         end: Alignment.topCenter,
///       ),
///       borderRadius: 10,
///     ),
///   ),
///   animation: ChartAnimation.elegant(),
///   height: 300,
/// )
/// ```
class FlBarChart extends StatefulWidget {
  /// The data and style configuration for this chart.
  final BarChartData data;

  /// Controls the reveal animation speed and curve.
  /// Defaults to [ChartAnimation] with 900ms easeOutCubic.
  final ChartAnimation animation;

  /// Height of the chart canvas. Defaults to `260.0`.
  final double height;

  /// Optional background decoration for the chart container.
  final BoxDecoration? decoration;

  /// Padding around the chart container.
  final EdgeInsets padding;

  /// Callback fired when a bar is tapped.
  /// Receives the tapped [BarData] and its index.
  final void Function(BarData bar, int index)? onBarTapped;

  /// Optional theme that overrides [BarChartData.defaultColor].
  /// The first color in [ChartTheme.colors] is used as the bar color.
  final ChartTheme? theme;

  const FlBarChart({
    super.key,
    required this.data,
    this.animation = const ChartAnimation(),
    this.height = 260.0,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
    this.onBarTapped,
    this.theme,
  });

  @override
  State<FlBarChart> createState() => _FlBarChartState();
}

class _FlBarChartState extends State<FlBarChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  int _selectedIndex = -1;
  late double _maxY;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _maxY = _resolveMaxY();
    initAnimation(widget.animation, this);
  }

  @override
  void didUpdateWidget(FlBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _maxY = _resolveMaxY();
      _selectedIndex = -1;
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
    final highest =
        widget.data.bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    return ChartUtils.niceMax(highest);
  }

  void _onTapDown(TapDownDetails details) {
    if (_chartSize == Size.zero) return;

    final painter = BarChartPainter(
      data: widget.data,
      animationProgress: 1.0,
      selectedIndex: -1,
      maxY: _maxY,
    );

    final index = painter.indexFromTap(details.localPosition, _chartSize);
    setState(() => _selectedIndex = index);

    if (index >= 0) {
      widget.onBarTapped?.call(widget.data.bars[index], index);
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
                painter: BarChartPainter(
                  data: widget.theme != null
                      ? BarChartData(
                          bars: widget.data.bars,
                          defaultColor: widget.theme!.colorAt(0),
                          barStyle: widget.data.barStyle,
                          axisStyle: widget.data.axisStyle,
                          tooltipStyle: widget.data.tooltipStyle,
                          maxY: widget.data.maxY,
                          minY: widget.data.minY,
                        )
                      : widget.data,
                  animationProgress: animationValue,
                  selectedIndex: _selectedIndex,
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
