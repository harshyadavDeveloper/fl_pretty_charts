import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';

class ZoomDemoPage extends StatefulWidget {
  const ZoomDemoPage({super.key});

  @override
  State<ZoomDemoPage> createState() => _ZoomDemoPageState();
}

class _ZoomDemoPageState extends State<ZoomDemoPage> {
  double _barScale = 1.0;
  double _lineScale = 1.0;

  static const _barData = BarChartData(
    bars: [
      BarData(value: 30, label: 'Jan'),
      BarData(value: 80, label: 'Feb'),
      BarData(value: 55, label: 'Mar'),
      BarData(value: 90, label: 'Apr'),
      BarData(value: 40, label: 'May'),
      BarData(value: 75, label: 'Jun'),
      BarData(value: 60, label: 'Jul'),
      BarData(value: 85, label: 'Aug'),
      BarData(value: 45, label: 'Sep'),
      BarData(value: 70, label: 'Oct'),
      BarData(value: 95, label: 'Nov'),
      BarData(value: 50, label: 'Dec'),
    ],
    barStyle: BarStyle(
      borderRadius: 8,
      gradient: LinearGradient(
        colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ),
    ),
  );

  static const _lineData = LineChartData(
    lines: [
      LineData(
        points: [
          LinePoint(x: 0, y: 30, label: 'Jan'),
          LinePoint(x: 1, y: 80, label: 'Feb'),
          LinePoint(x: 2, y: 55, label: 'Mar'),
          LinePoint(x: 3, y: 90, label: 'Apr'),
          LinePoint(x: 4, y: 40, label: 'May'),
          LinePoint(x: 5, y: 75, label: 'Jun'),
          LinePoint(x: 6, y: 60, label: 'Jul'),
          LinePoint(x: 7, y: 85, label: 'Aug'),
          LinePoint(x: 8, y: 45, label: 'Sep'),
          LinePoint(x: 9, y: 70, label: 'Oct'),
          LinePoint(x: 10, y: 95, label: 'Nov'),
          LinePoint(x: 11, y: 50, label: 'Dec'),
        ],
        label: 'Revenue',
        style: LineStyle(
          color: Color(0xFF5C6BC0),
          strokeWidth: 2.5,
          showFill: true,
          fillOpacity: 0.15,
        ),
      ),
      LineData(
        points: [
          LinePoint(x: 0, y: 20, label: 'Jan'),
          LinePoint(x: 1, y: 60, label: 'Feb'),
          LinePoint(x: 2, y: 40, label: 'Mar'),
          LinePoint(x: 3, y: 70, label: 'Apr'),
          LinePoint(x: 4, y: 30, label: 'May'),
          LinePoint(x: 5, y: 55, label: 'Jun'),
          LinePoint(x: 6, y: 45, label: 'Jul'),
          LinePoint(x: 7, y: 65, label: 'Aug'),
          LinePoint(x: 8, y: 35, label: 'Sep'),
          LinePoint(x: 9, y: 50, label: 'Oct'),
          LinePoint(x: 10, y: 75, label: 'Nov'),
          LinePoint(x: 11, y: 40, label: 'Dec'),
        ],
        label: 'Expenses',
        style: LineStyle(
          color: Color(0xFFFF7043),
          strokeWidth: 2.5,
          showFill: true,
          fillOpacity: 0.15,
        ),
      ),
    ],
  );

  static const _pieData = PieChartData(
    segments: [
      PieSegment(value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
      PieSegment(value: 30, label: 'React', color: Color(0xFF26A69A)),
      PieSegment(value: 20, label: 'Vue', color: Color(0xFFFFCA28)),
      PieSegment(value: 10, label: 'Other', color: Color(0xFFEF5350)),
    ],
    donut: true,
    donutRadius: 0.55,
    centerLabel: CenterLabelStyle(title: 'Total', value: '100'),
  );

  static const _radarData = RadarChartData(
    labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
    datasets: [
      RadarDataset(
        values: [80, 90, 70, 85, 60],
        label: 'Hero A',
        style: RadarDatasetStyle(
          color: Color(0xFF5C6BC0),
          fillOpacity: 0.3,
        ),
      ),
      RadarDataset(
        values: [60, 70, 85, 60, 90],
        label: 'Hero B',
        style: RadarDatasetStyle(
          color: Color(0xFF26A69A),
          fillOpacity: 0.3,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildInfoBanner(),
        _buildSection(
          title: '📊 Bar Chart — Pinch to Zoom',
          subtitle: 'Pinch · Scroll wheel · Drag to pan · Double tap to reset',
          child: _buildScaleIndicator(
            scale: _barScale,
            child: SizedBox(
              height: 280,
              child: FlZoomableChart(
                config: const ZoomConfig(
                  maxScale: 5.0,
                  enableMouseWheelZoom: true,
                ),
                onScaleChanged: (s) => setState(() => _barScale = s),
                child: FlBarChart(
                  data: _barData,
                  animation: ChartAnimation.none(),
                  height: 280,
                ),
              ),
            ),
          ),
        ),
        _buildSection(
          title: '📈 Line Chart — Multi-series Zoom',
          subtitle: 'Zoom in to inspect individual data points',
          child: _buildScaleIndicator(
            scale: _lineScale,
            child: SizedBox(
              height: 280,
              child: FlZoomableChart(
                config: const ZoomConfig(
                  maxScale: 6.0,
                  enableMouseWheelZoom: true,
                ),
                onScaleChanged: (s) => setState(() => _lineScale = s),
                child: FlLineChart(
                  data: _lineData,
                  animation: ChartAnimation.none(),
                  height: 280,
                ),
              ),
            ),
          ),
        ),
        _buildSection(
          title: '🥧 Pie Chart — Zoom Only',
          subtitle: 'No pan · Zoom only · Double tap to reset',
          child: SizedBox(
            height: 360,
            child: ZoomableChartX.zoomOnly(
              child: FlPieChart(
                data: _pieData,
                animation: ChartAnimation.none(),
              ),
            ),
          ),
        ),
        _buildSection(
          title: '🕸️ Radar Chart — Touch Only',
          subtitle: 'Touch gestures only · No mouse wheel',
          child: SizedBox(
            height: 340,
            child: ZoomableChartX.touchOnly(
              child: FlRadarChart(
                data: _radarData,
                animation: ChartAnimation.none(),
              ),
            ),
          ),
        ),
        _buildSection(
          title: '📊 No Controls',
          subtitle: 'showControls: false · Gesture only interaction',
          child: SizedBox(
            height: 280,
            child: FlZoomableChart(
              showControls: false,
              child: FlBarChart(
                data: _barData,
                animation: ChartAnimation.none(),
                height: 280,
                theme: ChartTheme.sunset(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildScaleIndicator({
    required double scale,
    required Widget child,
  }) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF5C6BC0).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              '${(scale * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C6BC0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF5C6BC0).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF5C6BC0).withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.zoom_in, color: Color(0xFF5C6BC0), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pinch to zoom · Drag to pan · Double tap to reset · '
              'Scroll wheel on desktop/web · Use +/- buttons for precise control.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF616161),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121))),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
