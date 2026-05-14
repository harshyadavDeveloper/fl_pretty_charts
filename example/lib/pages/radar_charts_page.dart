import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';
import '../widgets/chart_section.dart';

class RadarChartsPage extends StatefulWidget {
  const RadarChartsPage({super.key});

  @override
  State<RadarChartsPage> createState() => _RadarChartsPageState();
}

class _RadarChartsPageState extends State<RadarChartsPage> {
  String _lastTapped = 'Tap any dataset!';

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _heroData = RadarChartData(
    labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
    datasets: [
      RadarDataset(
        values: [80, 90, 70, 85, 60],
        label: 'Hero A',
        style: RadarDatasetStyle(
          color: Color(0xFF5C6BC0),
          fillOpacity: 0.3,
          strokeWidth: 2.5,
        ),
      ),
      RadarDataset(
        values: [60, 70, 85, 60, 90],
        label: 'Hero B',
        style: RadarDatasetStyle(
          color: Color(0xFF26A69A),
          fillOpacity: 0.3,
          strokeWidth: 2.5,
        ),
      ),
    ],
  );

  static const _skillsData = RadarChartData(
    labels: ['Flutter', 'Dart', 'Firebase', 'UI/UX', 'Testing', 'CI/CD'],
    datasets: [
      RadarDataset(
        values: [95, 90, 75, 80, 70, 85],
        label: 'Current',
        style: RadarDatasetStyle(
          color: Color(0xFF5C6BC0),
          fillOpacity: 0.25,
          strokeWidth: 3,
          dotRadius: 5,
        ),
      ),
      RadarDataset(
        values: [100, 100, 90, 95, 90, 95],
        label: 'Target',
        style: RadarDatasetStyle(
          color: Color(0xFFFF7043),
          fillOpacity: 0.1,
          strokeWidth: 2,
          showDots: false,
        ),
      ),
    ],
  );

  static const _productData = RadarChartData(
    labels: ['Price', 'Quality', 'Support', 'Features', 'Speed'],
    datasets: [
      RadarDataset(
        values: [70, 90, 85, 95, 80],
        label: 'Product A',
        style: RadarDatasetStyle(
          color: Color(0xFF5C6BC0),
          fillOpacity: 0.3,
        ),
      ),
      RadarDataset(
        values: [85, 75, 70, 80, 90],
        label: 'Product B',
        style: RadarDatasetStyle(
          color: Color(0xFF26A69A),
          fillOpacity: 0.3,
        ),
      ),
      RadarDataset(
        values: [60, 85, 90, 70, 75],
        label: 'Product C',
        style: RadarDatasetStyle(
          color: Color(0xFFFF7043),
          fillOpacity: 0.3,
        ),
      ),
    ],
  );

  static const _singleData = RadarChartData(
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'],
    datasets: [
      RadarDataset(
        values: [65, 80, 55, 90, 70, 85, 60, 75],
        label: 'Monthly Sales',
        style: RadarDatasetStyle(
          color: Color(0xFFAB47BC),
          fillOpacity: 0.35,
          strokeWidth: 3,
          dotRadius: 5,
        ),
      ),
    ],
    gridStyle: RadarGridStyle(
      gridLevels: 4,
      gridOpacity: 0.3,
    ),
  );

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildTapBanner(),
        ChartSection(
          title: '🕸️ Hero Comparison',
          subtitle: 'Two datasets · Elegant animation · Tap a dataset!',
          child: FlRadarChart(
            data: _heroData,
            animation: ChartAnimation.elegant(),
            onDatasetTapped: (dataset, index) => setState(
              () => _lastTapped = '${dataset.label} selected',
            ),
          ),
        ),
        ChartSection(
          title: '💻 Developer Skills',
          subtitle: 'Current vs Target · Snappy animation · No dots on target',
          child: FlRadarChart(
            data: _skillsData,
            animation: ChartAnimation.snappy(),
            onDatasetTapped: (dataset, index) => setState(
              () => _lastTapped = '${dataset.label} selected',
            ),
          ),
        ),
        ChartSection(
          title: '📦 Product Comparison',
          subtitle: 'Three datasets · Bouncy animation · Tap to highlight',
          child: FlRadarChart(
            data: _productData,
            animation: ChartAnimation.bouncy(),
            size: 300,
            onDatasetTapped: (dataset, index) => setState(
              () => _lastTapped = '${dataset.label} selected',
            ),
          ),
        ),
        ChartSection(
          title: '📅 Monthly Sales',
          subtitle: 'Single dataset · 8 axes · No animation',
          child: FlRadarChart(
            data: _singleData,
            animation: ChartAnimation.none(),
            size: 300,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildTapBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFAB47BC).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFAB47BC).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app, color: Color(0xFFAB47BC), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _lastTapped,
              style: const TextStyle(
                color: Color(0xFFAB47BC),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
