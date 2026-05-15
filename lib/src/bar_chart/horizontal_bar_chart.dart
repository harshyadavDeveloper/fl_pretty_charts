import 'package:flutter/material.dart';
import 'bar_chart_data.dart';
import 'horizontal_bar_chart_painter.dart';
import '../common/chart_animation.dart';
import '../common/chart_theme.dart';
import '../common/chart_utils.dart';

/// A beautiful, animated horizontal bar chart widget.
///
/// Drop [FlHorizontalBarChart] anywhere in your widget tree.
/// Bars grow from left to right with smooth animation.
/// Reuses all [BarChartData] models — just swap the widget.
///
/// Basic example:
/// ```dart
/// FlHorizontalBarChart(
///   data: BarChartData(
///     bars: [
///       BarData(value: 80, label: 'Flutter'),
///       BarData(value: 65, label: 'React'),
///       BarData(value: 50, label: 'Vue'),
///       BarData(value: 40, label: 'Angular'),
///     ],
///   ),
/// )
/// ```
///
/// With gradient:
/// ```dart
/// FlHorizontalBarChart(
///   data: BarChartData(
///     bars: [...],
///     barStyle: BarStyle(
///       gradient: LinearGradient(
///         colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
///         begin: Alignment.centerLeft,
///         end: Alignment.centerRight,
///       ),
///     ),
///   ),
///   animation: ChartAnimation.elegant(),
/// )
/// ```
class FlHorizontalBarChart extends StatefulWidget {
  /// The data and style configuration for this chart.
  final BarChartData data;

  /// Controls the reveal animation speed and curve.
  final ChartAnimation animation;

  /// Height of the chart canvas. Defaults to `260.0`.
  final double height;

  /// Optional background decoration for the chart container.
  final BoxDecoration? decoration;

  /// Padding around the chart container.
  final EdgeInsets padding;

  /// Optional theme that overrides [BarChartData.defaultColor].
  final ChartTheme? theme;

  /// Callback fired when a bar is tapped.
  /// Receives the tapped [BarData] and its index.
  final void Function(BarData bar, int index)? onBarTapped;

  const FlHorizontalBarChart({
    super.key,
    required this.data,
    this.animation = const ChartAnimation(),
    this.height = 260.0,
    this.decoration,
    this.padding = const EdgeInsets.all(16),
    this.theme,
    this.onBarTapped,
  });

  @override
  State<FlHorizontalBarChart> createState() => _FlHorizontalBarChartState();
}

class _FlHorizontalBarChartState extends State<FlHorizontalBarChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  int _selectedIndex = -1;
  late double _maxX;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    assert(
      widget.data.bars.isNotEmpty,
      'BarChartData.bars must not be empty',
    );
    _maxX = _resolveMaxX();
    initAnimation(widget.animation, this);
  }

  @override
  void didUpdateWidget(FlHorizontalBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _maxX = _resolveMaxX();
      _selectedIndex = -1;
      replayAnimation();
    }
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }

  double _resolveMaxX() {
    if (widget.data.maxY != null) return widget.data.maxY!;
    final highest =
        widget.data.bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    return ChartUtils.niceMax(highest);
  }

  BarChartData get _resolvedData {
    if (widget.theme == null) return widget.data;
    return BarChartData(
      bars: widget.data.bars,
      defaultColor: widget.theme!.colorAt(0),
      barStyle: widget.data.barStyle,
      axisStyle: widget.data.axisStyle,
      tooltipStyle: widget.data.tooltipStyle,
      maxY: widget.data.maxY,
      minY: widget.data.minY,
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (_chartSize == Size.zero) return;

    final painter = HorizontalBarChartPainter(
      data: _resolvedData,
      animationProgress: 1.0,
      selectedIndex: -1,
      maxX: _maxX,
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
                painter: HorizontalBarChartPainter(
                  data: _resolvedData,
                  animationProgress: animationValue,
                  selectedIndex: _selectedIndex,
                  maxX: _maxX,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
