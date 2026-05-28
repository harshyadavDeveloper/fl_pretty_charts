import 'package:flutter/material.dart';
import '../line_chart/line_chart_data.dart';
import '../line_chart/line_chart_painter.dart';
import '../common/chart_animation.dart';
import '../common/chart_theme.dart';
import '../common/chart_utils.dart';
import 'live_data_controller.dart';

/// A live, scrolling line chart with a rolling window.
///
/// New data points are appended from the right. When the number of points
/// exceeds [maxPoints], the oldest point slides out from the left.
/// Each new point animates in smoothly.
///
/// Basic example:
/// ```dart
/// final controller = LiveDataController<double>();
///
/// FlLiveLineChart(
///   controller: controller,
///   label: 'Heart Rate',
///   maxPoints: 20,
///   color: Color(0xFFEF5350),
/// )
///
/// // Push new data points
/// controller.add(72.0);
/// controller.add(75.0);
/// controller.add(68.0);
/// ```
///
/// Multi-line example:
/// ```dart
/// final controller = LiveDataController<List<double>>();
///
/// FlLiveLineChart.multi(
///   controller: controller,
///   labels: ['CPU', 'Memory'],
///   colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
///   maxPoints: 30,
/// )
///
/// controller.add([45.0, 62.0]);
/// ```
class FlLiveLineChart extends StatefulWidget {
  /// Controller for single-value updates.
  final LiveDataController<double>? singleController;

  /// Controller for multi-value updates (one value per line).
  final LiveDataController<List<double>>? multiController;

  /// Series labels — one per line.
  final List<String> labels;

  /// Colors for each line series.
  final List<Color> colors;

  /// Maximum number of data points to show at once (rolling window).
  /// Defaults to `20`.
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

  /// Whether to show dots at each data point. Defaults to `false`.
  final bool showDots;

  /// Stroke width of each line. Defaults to `2.5`.
  final double strokeWidth;

  /// Whether to show fill area below the line. Defaults to `true`.
  final bool showFill;

  /// X-axis label prefix — shown as index (e.g. 't-19', 't-18'...).
  final String xLabelPrefix;

  const FlLiveLineChart._({
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
    this.showDots = false,
    this.strokeWidth = 2.5,
    this.showFill = true,
    this.xLabelPrefix = 't',
  });

  /// Single-line live chart.
  factory FlLiveLineChart({
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
    bool showDots = false,
    double strokeWidth = 2.5,
    bool showFill = true,
    String xLabelPrefix = 't',
  }) {
    return FlLiveLineChart._(
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
      showDots: showDots,
      strokeWidth: strokeWidth,
      showFill: showFill,
      xLabelPrefix: xLabelPrefix,
    );
  }

  /// Multi-line live chart.
  factory FlLiveLineChart.multi({
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
    bool showDots = false,
    double strokeWidth = 2.5,
    bool showFill = true,
    String xLabelPrefix = 't',
  }) {
    return FlLiveLineChart._(
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
      showDots: showDots,
      strokeWidth: strokeWidth,
      showFill: showFill,
      xLabelPrefix: xLabelPrefix,
    );
  }

  @override
  State<FlLiveLineChart> createState() => _FlLiveLineChartState();
}

class _FlLiveLineChartState extends State<FlLiveLineChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  // Rolling window — one list of values per series
  late List<List<double>> _windows;

  // Stream subscriptions
  dynamic _singleSub;
  dynamic _multiSub;

  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    final seriesCount = widget.labels.length;
    _windows = List.generate(seriesCount, (_) => []);

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

  LineChartData get _buildChartData {
    final effectiveColors = widget.theme != null
        ? List.generate(widget.labels.length, (i) => widget.theme!.colorAt(i))
        : widget.colors;

    final lines = List.generate(_windows.length, (si) {
      final window = _windows[si];
      final color = si < effectiveColors.length
          ? effectiveColors[si]
          : effectiveColors.last;

      final points = List.generate(window.length, (i) {
        return LinePoint(
          x: i.toDouble(),
          y: window[i],
          label: _xLabel(i, window.length),
        );
      });

      return LineData(
        points: points,
        label: widget.labels[si],
        style: LineStyle(
          color: color,
          strokeWidth: widget.strokeWidth,
          showFill: widget.showFill,
          fillOpacity: 0.15,
          showDots: widget.showDots,
          smooth: true,
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

    return LineChartData(
      lines: lines,
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
                    painter: LineChartPainter(
                      data: chartData,
                      animationProgress: animationValue,
                      selectedLineIndex: -1,
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
