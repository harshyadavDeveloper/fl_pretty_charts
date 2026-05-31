import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';

class ExportDemoPage extends StatefulWidget {
  const ExportDemoPage({super.key});

  @override
  State<ExportDemoPage> createState() => _ExportDemoPageState();
}

class _ExportDemoPageState extends State<ExportDemoPage> {
  // One export key per chart
  final _barKey = GlobalKey();
  final _lineKey = GlobalKey();
  final _pieKey = GlobalKey();
  final _radarKey = GlobalKey();

  String _status = 'Tap Export on any chart to preview it as a PNG image.';
  bool _isExporting = false;

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _barData = BarChartData(
    bars: [
      BarData(value: 60, label: 'Mon'),
      BarData(value: 90, label: 'Tue'),
      BarData(value: 45, label: 'Wed'),
      BarData(value: 75, label: 'Thu'),
      BarData(value: 85, label: 'Fri'),
    ],
    barStyle: BarStyle(
      borderRadius: 10,
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
          LinePoint(x: 4, y: 65, label: 'May'),
        ],
        label: 'Revenue',
        style: LineStyle(
          color: Color(0xFF5C6BC0),
          strokeWidth: 3,
          showFill: true,
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

  // ── Export helpers ─────────────────────────────────────────────────────────

  Future<void> _exportChart(GlobalKey key, String name) async {
    setState(() {
      _isExporting = true;
      _status = 'Capturing $name...';
    });

    final success = await ChartExporter.showPreview(
      context,
      key,
      chartName: name,
      pixelRatio: 3.0,
    );

    setState(() {
      _isExporting = false;
      _status = success
          ? '$name exported successfully!'
          : 'Export failed. Try again.';
    });
  }

  Future<void> _exportToBytes(GlobalKey key, String name) async {
    setState(() {
      _isExporting = true;
      _status = 'Capturing $name as bytes...';
    });

    final bytes = await ChartExporter.toBytes(key, pixelRatio: 3.0);

    setState(() {
      _isExporting = false;
      _status = bytes != null
          ? '$name → ${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB captured!'
          : 'Export failed.';
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildStatusBanner(),
        _buildSection(
          title: '📊 Bar Chart Export',
          subtitle: 'Tap Export to preview as PNG',
          child: ExportableChart(
            exportKey: _barKey,
            chartName: 'Weekly Activity',
            child: FlBarChart(
              data: _barData,
              animation: ChartAnimation.none(),
            ),
          ),
        ),
        _buildSection(
          title: '📈 Line Chart Export',
          subtitle: 'Built-in export button · 3x pixel ratio',
          child: ExportableChart(
            exportKey: _lineKey,
            chartName: 'Monthly Revenue',
            child: FlLineChart(
              data: _lineData,
              animation: ChartAnimation.none(),
            ),
          ),
        ),
        _buildSection(
          title: '🥧 Pie Chart Export',
          subtitle: 'Custom position · top-left button',
          child: ExportableChart(
            exportKey: _pieKey,
            chartName: 'Market Share',
            exportButtonAlignment: Alignment.topLeft,
            child: FlPieChart(
              data: _pieData,
              animation: ChartAnimation.none(),
            ),
          ),
        ),
        _buildSection(
          title: '🕸️ Radar Chart Export',
          subtitle: 'Custom onExported callback → captures bytes',
          child: ExportableChart(
            exportKey: _radarKey,
            chartName: 'Hero Comparison',
            onExported: (bytes) {
              setState(() {
                _status =
                    'Radar chart captured → ${(bytes.length / 1024).toStringAsFixed(1)} KB';
              });
            },
            child: FlRadarChart(
              data: _radarData,
              animation: ChartAnimation.none(),
            ),
          ),
        ),
        _buildManualExportSection(),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildStatusBanner() {
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
      child: Row(
        children: [
          _isExporting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.download_outlined,
                  color: Color(0xFF5C6BC0),
                  size: 18,
                ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _status,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF424242),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualExportSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
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
          const Text(
            '🔧 Manual Export API',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Use ChartExporter directly without the built-in button',
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildManualButton(
                label: 'Preview Bar',
                icon: Icons.bar_chart,
                onTap: () => _exportChart(_barKey, 'Bar Chart'),
              ),
              _buildManualButton(
                label: 'Bytes Line',
                icon: Icons.show_chart,
                onTap: () => _exportToBytes(_lineKey, 'Line Chart'),
              ),
              _buildManualButton(
                label: 'Preview Pie',
                icon: Icons.pie_chart,
                onTap: () => _exportChart(_pieKey, 'Pie Chart'),
              ),
              _buildManualButton(
                label: 'Bytes Radar',
                icon: Icons.radar,
                onTap: () => _exportToBytes(_radarKey, 'Radar Chart'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManualButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF5C6BC0).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF5C6BC0)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5C6BC0),
              ),
            ),
          ],
        ),
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
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212121),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
