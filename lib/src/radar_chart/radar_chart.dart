import 'package:flutter/material.dart';
import 'radar_chart_data.dart';
import 'radar_chart_painter.dart';
import '../common/chart_animation.dart';

/// A beautiful, animated radar/spider chart widget.
///
/// Drop [FlRadarChart] anywhere in your widget tree. Supports multiple
/// datasets overlaid on the same chart, animated polygon reveal,
/// tap-to-highlight, dot indicators, and a legend.
///
/// Basic example:
/// ```dart
/// FlRadarChart(
///   data: RadarChartData(
///     labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
///     datasets: [
///       RadarDataset(
///         values: [80, 90, 70, 85, 60],
///         label: 'Hero A',
///         style: RadarDatasetStyle(color: Color(0xFF5C6BC0)),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// Multi-dataset comparison:
/// ```dart
/// FlRadarChart(
///   data: RadarChartData(
///     labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
///     datasets: [
///       RadarDataset(
///         values: [80, 90, 70, 85, 60],
///         label: 'Hero A',
///         style: RadarDatasetStyle(color: Color(0xFF5C6BC0)),
///       ),
///       RadarDataset(
///         values: [60, 70, 85, 60, 90],
///         label: 'Hero B',
///         style: RadarDatasetStyle(color: Color(0xFF26A69A)),
///       ),
///     ],
///   ),
///   animation: ChartAnimation.elegant(),
/// )
/// ```
class FlRadarChart extends StatefulWidget {
  /// The data and style configuration for this chart.
  final RadarChartData data;

  /// Controls the reveal animation speed and curve.
  final ChartAnimation animation;

  /// Size of the chart canvas (width and height). Defaults to `280.0`.
  final double size;

  /// Padding around the chart container.
  final EdgeInsets padding;

  /// Optional background decoration for the chart container.
  final BoxDecoration? decoration;

  /// Callback fired when a dataset is tapped.
  /// Receives the tapped [RadarDataset] and its index.
  final void Function(RadarDataset dataset, int index)? onDatasetTapped;

  const FlRadarChart({
    super.key,
    required this.data,
    this.animation = const ChartAnimation(),
    this.size = 280.0,
    this.padding = const EdgeInsets.all(16),
    this.decoration,
    this.onDatasetTapped,
  });

  @override
  State<FlRadarChart> createState() => _FlRadarChartState();
}

class _FlRadarChartState extends State<FlRadarChart>
    with SingleTickerProviderStateMixin, ChartAnimationMixin {
  int _selectedIndex = -1;
  Size _chartSize = Size.zero;

  @override
  void initState() {
    super.initState();
    assert(
      widget.data.labels.length >= 3,
      'RadarChartData.labels must have at least 3 items',
    );
    assert(
      widget.data.datasets.isNotEmpty,
      'RadarChartData.datasets must not be empty',
    );
    for (final ds in widget.data.datasets) {
      assert(
        ds.values.length == widget.data.labels.length,
        'RadarDataset.values length must match labels length',
      );
    }
    initAnimation(widget.animation, this);
  }

  @override
  void didUpdateWidget(FlRadarChart oldWidget) {
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

    final painter = RadarChartPainter(
      data: widget.data,
      animationProgress: 1.0,
      selectedIndex: -1,
    );

    final index = painter.indexFromTap(details.localPosition, _chartSize);

    setState(() {
      _selectedIndex = _selectedIndex == index ? -1 : index;
    });

    if (index >= 0) {
      widget.onDatasetTapped?.call(widget.data.datasets[index], index);
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
                  _chartSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  return CustomPaint(
                    size: _chartSize,
                    painter: RadarChartPainter(
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
            const SizedBox(height: 12),
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
      children: List.generate(widget.data.datasets.length, (i) {
        final dataset = widget.data.datasets[i];
        final isSelected = i == _selectedIndex;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = _selectedIndex == i ? -1 : i;
            });
            widget.onDatasetTapped?.call(dataset, i);
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
                    color: dataset.style.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(dataset.label, style: style.textStyle),
              ],
            ),
          ),
        );
      }),
    );
  }
}
