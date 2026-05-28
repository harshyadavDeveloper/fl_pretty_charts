import 'package:flutter/material.dart';
import '../area_chart/area_chart_data.dart';
import '../area_chart/area_chart_painter.dart';
import '../common/chart_animation.dart';
import '../common/chart_theme.dart';
import '../common/chart_utils.dart';
import 'live_data_controller.dart';

/// A live, animated area chart that smoothly updates when data changes.
///
/// Pass a [LiveDataController<List<AreaPoint>>] to push entire new datasets,
/// or use [LiveDataController<double>] for a rolling single-series window.
///
/// Single series rolling window example:
/// ```dart
/// final controller = LiveDataController<double>();
///
/// FlLiveAreaChart(
///   controller: controller,
///   label: 'CPU Usage',
///   color: Color(0xFF5C6BC0),
///   maxPoints: 20,
/// )
///
/// // Push new values
/// controller.add(45.0);
/// controller.add(60.0);
/// ```
///
/// Multi-series rolling window example:
/// ```dart
/// final controller = LiveDataController<List<double>>();
///
/// FlLiveAreaChart.multi(
///   controller: controller,
///   labels: ['CPU', 'Memory'],
///   colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
///   maxPoints: 20,
/// )
///
/// controller.add([45.0, 62.0]);
/// ```
class FlLiveAreaChart extends StatefulWidget {
  /// Controller for single-value rolling window.
  final LiveDataController<double>? singleController;

  /// Controller for multi-value rolling window.
  final LiveDataController<List<double>>? multiController;

  /// Series labels — one per area series.
  final List<String> labels;

  /// Colors for each area series.
  final List<Color> colors;

  /// Maximum number of data points in the rolling window. Defaults to `20`.
  final int maxPoints;

  /// Optional theme that overrides [colors].
  final ChartTheme? theme;

  /// Height of the chart canvas. Defaults to `260.0`.
  final double height;

  /// Padding around the chart. Defaults to `EdgeInsets.all(16)`.
  final EdgeInsets padding;

  /// Optional background decoration.
  final BoxDecoration? decoration;

  /// Fixed maximum y value. Auto-calculated if null.
  final double? maxY;

  /// Fixed minimum y value. Defaults to `0`.
  final double minY;

  /// Fill opacity for each area series. Defaults to `0.3`.
  final double fillOpacity;

  /// Stroke width for each area series. Defaults to `2.5`.
  final double strokeWidth;

  /// Whether to show dot indicators. Defaults to `false`.
  final bool showDots;

  /// Whether to use smooth bezier curves. Defaults to `true`.
  final bool smooth;

  const FlLiveAreaChart._({
    super.key,
    this.singleController,
    this.multiController,
    required this.labels,
    required this.colors,
    this.maxPoints = 20,
    this.theme,
    this.height = 260.0,
    this.padding = const EdgeInsets.all(16),
    this.decoration,
    this.maxY,
    this.minY = 0,
    this.fillOpacity = 0.3,
    this.strokeWidth = 2.5,
    this.showDots = false,
    this.smooth = true,
  });

  /// Single-series rolling window area chart.
  factory FlLiveAreaChart({
    Key? key,
    required LiveDataController<double> controller,
    required String label,
    Color color = const Color(0xFF5C6BC0),
    int maxPoints = 20,
    ChartTheme? theme,
    double height = 260.0,
    EdgeInsets padding = const EdgeInsets.all(16),
    BoxDecoration? decoration,
    double? maxY,
    double minY = 0,
    double fillOpacity = 0.3,
    double strokeWidth = 2.5,
    bool showDots = false,
    bool smooth = true,
  }) {
    return FlLiveAreaChart._(
      key: key,
      singleController: controller,
      labels: [label],
      colors: [color],
      maxPoints: maxPoints,
      theme: theme,
      height: height,
      padding: padding,
      decoration: decoration,
      maxY: maxY,
      minY: minY,
      fillOpacity: fillOpacity,
      strokeWidth: strokeWidth,
      showDots: showDots,
      smooth: smooth,
    );
  }

  /// Multi-series rolling window area chart.
  factory FlLiveAreaChart.multi({
    Key? key,
    required LiveDataController<List<double>> controller,
    required List<String> labels,
    List<Color> colors = const [
      Color(0xFF5C6BC0),
      Color(0xFF26A69A),
      Color(0xFFFF7043),
    ],
    int maxPoints = 20,
    ChartTheme? theme,
    double height = 260.0,
    EdgeInsets padding = const EdgeInsets.all(16),
    BoxDecoration? decoration,
    double? maxY,
    double minY = 0,
    double fillOpacity = 0.3,
    double strokeWidth = 2.5,
    bool showDots = false,
    bool smooth = true,
  }) {
    return FlLiveAreaChart._(
      key: key,
      multiController: controller,
      labels: labels,
      colors: colors,
      maxPoints: maxPoints,
      theme: theme,
      height: height,
      padding: padding,
      decoration: decoration,
      maxY: maxY,
      minY: minY,
      fillOpacity: fillOpacity,
      strokeWidth: strokeWidth,
      showDots: showDots,
      smooth: smooth,
    );
  }

  @override
  State<FlLiveAreaChart> createState() => _FlLiveAreaChartState();
}

class _FlLiveAreaChartState extends State<FlLiveAreaChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  late List<List<double>> _windows;

  dynamic _singleSub;
  dynamic _multiSub;

  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _windows = List.generate(widget.labels.length, (_) => []);

    initAnimation(
      const ChartAnimation(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      ),
      this,
    );

    if (widget.singleController != null) {
      _singleSub = widget.singleController!.dataStream.listen((value) {
        _appendValues([value]);
      });
    }

    if (widget.multiController != null) {
      _multiSub = widget.multiController!.dataStream.listen((values) {
        _appendValues(values);
      });
    }
  }

  void _appendValues(List<double> values) {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _windows.length; i++) {
        final value = i < values.length ? values[i] : 0.0;
        _windows[i].add(value);
        if (_windows[i].length > widget.maxPoints) {
          _windows[i].removeAt(0);
        }
      }
    });
    replayAnimation();
  }

  @override
  void dispose() {
    _singleSub?.cancel();
    _multiSub?.cancel();
    disposeAnimation();
    super.dispose();
  }

  String _xLabel(int index, int total) {
    final offset = total - 1 - index;
    return offset == 0 ? 'now' : '-$offset';
  }

  AreaChartData get _buildChartData {
    final effectiveColors = widget.theme != null
        ? List.generate(widget.labels.length, (i) => widget.theme!.colorAt(i))
        : widget.colors;

    final series = List.generate(_windows.length, (si) {
      final window = _windows[si];
      final color = si < effectiveColors.length
          ? effectiveColors[si]
          : effectiveColors.last;

      final points = List.generate(window.length, (i) {
        return AreaPoint(
          x: i.toDouble(),
          y: window[i],
          label: _xLabel(i, window.length),
        );
      });

      return AreaSeries(
        points: points,
        label: widget.labels[si],
        style: AreaSeriesStyle(
          color: color,
          strokeWidth: widget.strokeWidth,
          fillOpacity: widget.fillOpacity,
          showDots: widget.showDots,
          smooth: widget.smooth,
        ),
      );
    });

    double resolvedMaxY = widget.maxY ?? 0;
    if (widget.maxY == null) {
      for (final window in _windows) {
        for (final v in window) {
          if (v > resolvedMaxY) resolvedMaxY = v;
        }
      }
      resolvedMaxY = ChartUtils.niceMax(resolvedMaxY);
    }

    return AreaChartData(
      series: series,
      maxY: resolvedMaxY,
      minY: widget.minY,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _buildChartData;
    final hasData = _windows.any((w) => w.isNotEmpty);

    return Padding(
      padding: widget.padding,
      child: Container(
        height: widget.height,
        decoration: widget.decoration,
        child: hasData
            ? LayoutBuilder(
                builder: (context, constraints) {
                  _chartSize = Size(constraints.maxWidth, widget.height);
                  return CustomPaint(
                    size: _chartSize,
                    painter: AreaChartPainter(
                      data: chartData,
                      animationProgress: animationValue,
                      selectedSeriesIndex: -1,
                      selectedPointIndex: -1,
                      maxY: chartData.maxY ?? 100,
                    ),
                  );
                },
              )
            : const Center(
                child: Text(
                  'Waiting for data...',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 14,
                  ),
                ),
              ),
      ),
    );
  }
}
