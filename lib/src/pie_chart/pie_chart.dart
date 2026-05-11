import 'package:flutter/material.dart';
import 'pie_chart_data.dart';
import 'pie_chart_painter.dart';
import '../common/chart_animation.dart';

/// A beautiful, animated pie and donut chart widget.
///
/// Drop [FlPieChart] anywhere in your widget tree. Supports pie and donut
/// variants, tap-to-expand segments, legend, and center label (donut mode).
///
/// Basic pie chart:
/// ```dart
/// FlPieChart(
///   data: PieChartData(
///     segments: [
///       PieSegment(value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
///       PieSegment(value: 30, label: 'React',   color: Color(0xFF26A69A)),
///       PieSegment(value: 20, label: 'Vue',      color: Color(0xFFFFCA28)),
///       PieSegment(value: 10, label: 'Other',   color: Color(0xFFEF5350)),
///     ],
///   ),
/// )
/// ```
///
/// Donut chart with center label:
/// ```dart
/// FlPieChart(
///   data: PieChartData(
///     segments: [...],
///     donut: true,
///     donutRadius: 0.55,
///     centerLabel: CenterLabelStyle(
///       title: 'Total',
///       value: '100',
///     ),
///   ),
/// )
/// ```
class FlPieChart extends StatefulWidget {
  /// The data and style configuration for this chart.
  final PieChartData data;

  /// Controls the reveal animation speed and curve.
  final ChartAnimation animation;

  /// Size of the chart canvas (width and height). Defaults to `260.0`.
  final double size;

  /// Padding around the chart container.
  final EdgeInsets padding;

  /// Optional background decoration for the chart container.
  final BoxDecoration? decoration;

  /// Callback fired when a segment is tapped.
  /// Receives the tapped [PieSegment] and its index.
  final void Function(PieSegment segment, int index)? onSegmentTapped;

  const FlPieChart({
    super.key,
    required this.data,
    this.animation = const ChartAnimation(),
    this.size = 260.0,
    this.padding = const EdgeInsets.all(16),
    this.decoration,
    this.onSegmentTapped,
  });

  @override
  State<FlPieChart> createState() => _FlPieChartState();
}

class _FlPieChartState extends State<FlPieChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  int _selectedIndex = -1;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    assert(
      widget.data.segments.isNotEmpty,
      'PieChartData.segments must not be empty',
    );
    initAnimation(widget.animation, this);
  }

  @override
  void didUpdateWidget(FlPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _selectedIndex = -1;
      replayAnimation();
    }
  }

  @override
  void dispose() {
    disposeAnimation();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_chartSize == Size.zero) return;

    final painter = PieChartPainter(
      data: widget.data,
      animationProgress: 1.0,
      selectedIndex: -1,
    );

    final index = painter.indexFromTap(details.localPosition, _chartSize);

    setState(() {
      // Tap same segment again to deselect
      _selectedIndex = _selectedIndex == index ? -1 : index;
    });

    if (index >= 0) {
      widget.onSegmentTapped?.call(widget.data.segments[index], index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Chart canvas ────────────────────────────────────────────────
          Container(
            width: widget.size,
            height: widget.size,
            decoration: widget.decoration,
            child: GestureDetector(
              onTapDown: _onTapDown,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _chartSize =
                      Size(constraints.maxWidth, constraints.maxHeight);
                  return CustomPaint(
                    size: _chartSize,
                    painter: PieChartPainter(
                      data: widget.data,
                      animationProgress: animationValue,
                      selectedIndex: _selectedIndex,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Legend ──────────────────────────────────────────────────────
          if (widget.data.legendStyle.show) ...[
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final style = widget.data.legendStyle;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: style.spacing,
      runSpacing: 8,
      children: List.generate(widget.data.segments.length, (i) {
        final segment = widget.data.segments[i];
        final isSelected = i == _selectedIndex;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = _selectedIndex == i ? -1 : i;
            });
            widget.onSegmentTapped?.call(segment, i);
          },
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _selectedIndex == -1 || isSelected ? 1.0 : 0.4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: style.dotSize,
                  height: style.dotSize,
                  decoration: BoxDecoration(
                    color: segment.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${segment.label} (${_percentage(segment.value)}%)',
                  style: style.textStyle,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _percentage(double value) {
    final total = widget.data.segments.fold(0.0, (s, e) => s + e.value);
    if (total <= 0) return '0';
    return ((value / total) * 100).toStringAsFixed(1);
  }
}
