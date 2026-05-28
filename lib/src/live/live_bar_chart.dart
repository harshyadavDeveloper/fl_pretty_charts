import 'package:flutter/material.dart';
import '../bar_chart/bar_chart_data.dart';
import '../bar_chart/bar_chart_painter.dart';
import '../common/chart_animation.dart';
import '../common/chart_theme.dart';
import '../common/chart_utils.dart';
import 'live_data_controller.dart';

/// A live, animated bar chart that smoothly tweens between data updates.
///
/// Pass a [LiveDataController<List<BarData>>] to push new data at any time.
/// Each update triggers a smooth tween animation from the old values to
/// the new values — not a full re-render.
///
/// Basic example:
/// ```dart
/// final controller = LiveDataController<List<BarData>>();
///
/// FlLiveBarChart(
///   controller: controller,
///   labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
///   initialData: [30, 80, 55, 65, 40],
/// )
///
/// // Later — push new data
/// controller.add([
///   BarData(value: 50, label: 'Mon'),
///   BarData(value: 60, label: 'Tue'),
///   BarData(value: 75, label: 'Wed'),
///   BarData(value: 45, label: 'Thu'),
///   BarData(value: 90, label: 'Fri'),
/// ]);
/// ```
class FlLiveBarChart extends StatefulWidget {
  /// The controller that pushes new data to this chart.
  final LiveDataController<List<BarData>> controller;

  /// Initial bar data shown before the first controller update.
  final List<BarData> initialData;

  /// Style config for bars.
  final BarStyle barStyle;

  /// Style config for axes and grid.
  final AxisStyle axisStyle;

  /// Style config for tooltip.
  final TooltipStyle tooltipStyle;

  /// Optional color theme.
  final ChartTheme? theme;

  /// Height of the chart canvas. Defaults to `260.0`.
  final double height;

  /// Padding around the chart. Defaults to `EdgeInsets.all(16)`.
  final EdgeInsets padding;

  /// Optional background decoration.
  final BoxDecoration? decoration;

  /// Duration of the tween animation between data updates.
  /// Defaults to `400ms`.
  final Duration transitionDuration;

  /// Curve of the tween animation. Defaults to [Curves.easeOutCubic].
  final Curve transitionCurve;

  /// Callback fired when a bar is tapped.
  final void Function(BarData bar, int index)? onBarTapped;

  const FlLiveBarChart({
    super.key,
    required this.controller,
    required this.initialData,
    this.barStyle = const BarStyle(),
    this.axisStyle = const AxisStyle(),
    this.tooltipStyle = const TooltipStyle(),
    this.theme,
    this.height = 260.0,
    this.padding = const EdgeInsets.all(16),
    this.decoration,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.transitionCurve = Curves.easeOutCubic,
    this.onBarTapped,
  });

  @override
  State<FlLiveBarChart> createState() => _FlLiveBarChartState();
}

class _FlLiveBarChartState extends State<FlLiveBarChart>
    with
        SingleTickerProviderStateMixin,
        ChartAnimationMixin,
        LiveChartMixin<FlLiveBarChart, List<BarData>> {
  late List<double> _fromValues;
  late List<double> _toValues;
  late List<BarData> _currentBars;
  int _selectedIndex = -1;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _fromValues = widget.initialData.map((b) => b.value).toList();
    _toValues = List.from(_fromValues);
    _currentBars = List.from(widget.initialData);
    initAnimation(
      ChartAnimation(
        duration: widget.transitionDuration,
        curve: widget.transitionCurve,
      ),
      this,
    );
    initController(widget.controller, onData: _onNewData);
  }

  void _onNewData(List<BarData> newBars) {
    if (newBars.length != _currentBars.length) {
      // If bar count changes — just replace
      setState(() {
        _currentBars = newBars;
        _fromValues = newBars.map((b) => b.value).toList();
        _toValues = List.from(_fromValues);
      });
      return;
    }

    // Tween from current animated values to new values
    _fromValues = _interpolatedValues;
    _toValues = newBars.map((b) => b.value).toList();
    _currentBars = newBars;
    replayAnimation();
  }

  /// Returns the current interpolated values based on animation progress.
  List<double> get _interpolatedValues {
    return List.generate(_fromValues.length, (i) {
      return _fromValues[i] + (_toValues[i] - _fromValues[i]) * animationValue;
    });
  }

  List<BarData> get _animatedBars {
    final interpolated = _interpolatedValues;
    return List.generate(_currentBars.length, (i) {
      return BarData(
        value: interpolated[i],
        label: _currentBars[i].label,
        color: _currentBars[i].color,
      );
    });
  }

  double get _maxY {
    final maxVal = _toValues.fold(0.0, (a, b) => a > b ? a : b);
    return ChartUtils.niceMax(maxVal);
  }

  BarChartData get _resolvedData {
    final bars = _animatedBars;
    final color = widget.theme?.colorAt(0) ?? const Color(0xFF5C6BC0);
    return BarChartData(
      bars: bars,
      defaultColor: color,
      barStyle: widget.barStyle,
      axisStyle: widget.axisStyle,
      tooltipStyle: widget.tooltipStyle,
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (_chartSize == Size.zero) return;
    final painter = BarChartPainter(
      data: _resolvedData,
      animationProgress: 1.0,
      selectedIndex: -1,
      maxY: _maxY,
    );
    final index = painter.indexFromTap(details.localPosition, _chartSize);
    setState(() => _selectedIndex = index);
    if (index >= 0) {
      widget.onBarTapped?.call(_currentBars[index], index);
    }
  }

  @override
  void dispose() {
    disposeController();
    disposeAnimation();
    super.dispose();
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
                  data: _resolvedData,
                  animationProgress: 1.0,
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
