import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';
import '../widgets/chart_section.dart';

class ThemeDemoPage extends StatefulWidget {
  const ThemeDemoPage({super.key});

  @override
  State<ThemeDemoPage> createState() => _ThemeDemoPageState();
}

class _ThemeDemoPageState extends State<ThemeDemoPage> {
  ChartTheme _selectedTheme = ChartTheme.defaultTheme();
  String _selectedThemeName = 'Default';

  // ── Datasets ───────────────────────────────────────────────────────────────

  static const _barData = BarChartData(
    bars: [
      BarData(value: 60, label: 'Mon'),
      BarData(value: 90, label: 'Tue'),
      BarData(value: 45, label: 'Wed'),
      BarData(value: 75, label: 'Thu'),
      BarData(value: 85, label: 'Fri'),
    ],
  );

  static const _lineData = LineChartData(
    lines: [
      LineData(
        points: [
          LinePoint(x: 0, y: 30, label: 'Jan'),
          LinePoint(x: 1, y: 70, label: 'Feb'),
          LinePoint(x: 2, y: 50, label: 'Mar'),
          LinePoint(x: 3, y: 90, label: 'Apr'),
          LinePoint(x: 4, y: 65, label: 'May'),
        ],
        label: 'Series 1',
        style: LineStyle(strokeWidth: 3, showFill: true),
      ),
      LineData(
        points: [
          LinePoint(x: 0, y: 20, label: 'Jan'),
          LinePoint(x: 1, y: 50, label: 'Feb'),
          LinePoint(x: 2, y: 35, label: 'Mar'),
          LinePoint(x: 3, y: 65, label: 'Apr'),
          LinePoint(x: 4, y: 45, label: 'May'),
        ],
        label: 'Series 2',
        style: LineStyle(strokeWidth: 3, showFill: true, fillOpacity: 0.15),
      ),
    ],
  );

  static const _pieData = PieChartData(
    segments: [
      PieSegment(value: 40, label: 'A', color: Colors.grey),
      PieSegment(value: 25, label: 'B', color: Colors.grey),
      PieSegment(value: 20, label: 'C', color: Colors.grey),
      PieSegment(value: 15, label: 'D', color: Colors.grey),
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
        style: RadarDatasetStyle(fillOpacity: 0.3),
      ),
      RadarDataset(
        values: [60, 70, 85, 60, 90],
        label: 'Hero B',
        style: RadarDatasetStyle(fillOpacity: 0.3),
      ),
    ],
  );

  // ── Theme picker ───────────────────────────────────────────────────────────

  final _themes = {
    'Default': ChartTheme.defaultTheme(),
    'Ocean': ChartTheme.ocean(),
    'Sunset': ChartTheme.sunset(),
    'Forest': ChartTheme.forest(),
  };

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildThemePicker(),
        ChartSection(
          title: '📊 Bar Chart',
          subtitle: 'Theme: $_selectedThemeName',
          child: FlBarChart(
            data: _barData,
            theme: _selectedTheme,
            animation: ChartAnimation.snappy(),
          ),
        ),
        ChartSection(
          title: '📈 Line Chart',
          subtitle: 'Theme: $_selectedThemeName · Two series',
          child: FlLineChart(
            data: _lineData,
            theme: _selectedTheme,
            animation: ChartAnimation.snappy(),
          ),
        ),
        ChartSection(
          title: '🥧 Pie Chart',
          subtitle: 'Theme: $_selectedThemeName · Donut variant',
          child: FlPieChart(
            data: _pieData,
            theme: _selectedTheme,
            animation: ChartAnimation.snappy(),
          ),
        ),
        ChartSection(
          title: '🕸️ Radar Chart',
          subtitle: 'Theme: $_selectedThemeName · Two datasets',
          child: FlRadarChart(
            data: _radarData,
            theme: _selectedTheme,
            animation: ChartAnimation.snappy(),
          ),
        ),
        _buildLegendSection(),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildThemePicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            '🎨 Pick a Theme',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _themes.entries.map((entry) {
              final isSelected = entry.key == _selectedThemeName;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedTheme = entry.value;
                  _selectedThemeName = entry.key;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF5C6BC0)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF5C6BC0)
                          : const Color(0xFFE0E0E0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Color dots preview
                      ...entry.value.colors.take(3).map(
                            (c) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      const SizedBox(width: 4),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF424242),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendSection() {
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
            '🏷️ Standalone LegendWidget',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Use LegendWidget independently anywhere in your layout',
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 16),
          LegendWidget(
            items: List.generate(
              _selectedTheme.colors.length,
              (i) => LegendItem(
                color: _selectedTheme.colorAt(i),
                label: 'Series ${i + 1}',
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Square dots variant:',
            style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const SizedBox(height: 8),
          LegendWidget(
            dotShape: BoxShape.rectangle,
            dotSize: 12,
            items: List.generate(
              4,
              (i) => LegendItem(
                color: _selectedTheme.colorAt(i),
                label: 'Category ${i + 1}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
