import 'package:flutter/material.dart';
import 'bar_charts_page.dart';
import 'line_charts_page.dart';
import 'pie_charts_page.dart';
import 'radar_charts_page.dart';
import 'area_charts_page.dart';
import 'theme_demo_page.dart';
import 'live_charts_page.dart';
import 'annotations_page.dart';
import 'export_demo_page.dart';
import 'responsive_demo_page.dart';
import 'zoom_demo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;

  static const _pages = [
    BarChartsPage(),
    LineChartsPage(),
    AreaChartsPage(),
    PieChartsPage(),
    RadarChartsPage(),
    LiveChartsPage(),
    ThemeDemoPage(),
    AnnotationsPage(),
    ExportDemoPage(),
    ResponsiveDemoPage(),
    ZoomDemoPage(),
  ];

  static const _navItems = [
    _NavItem(icon: Icons.bar_chart, label: 'Bar Charts'),
    _NavItem(icon: Icons.show_chart, label: 'Line Charts'),
    _NavItem(icon: Icons.area_chart, label: 'Area Charts'),
    _NavItem(icon: Icons.pie_chart, label: 'Pie Charts'),
    _NavItem(icon: Icons.radar, label: 'Radar Charts'),
    _NavItem(icon: Icons.sensors, label: 'Live Charts'),
    _NavItem(icon: Icons.palette, label: 'Themes'),
    _NavItem(icon: Icons.architecture, label: 'Annotations'),
    _NavItem(icon: Icons.download, label: 'Export'),
    _NavItem(icon: Icons.phonelink, label: 'Responsive'),
    _NavItem(icon: Icons.zoom_in, label: 'Zoom & Pan'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('fl_pretty_charts'),
        centerTitle: true,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: _pages[_currentTab],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF5C6BC0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'fl_pretty_charts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Beautiful Flutter Charts',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ── Nav items ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = index == _currentTab;
                return _DrawerItem(
                  icon: item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _currentTab = index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),

          // ── Footer ────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEEE)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.public, size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 6),
                const Text(
                  'fl-pretty-charts.netlify.app',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5C6BC0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'v2.4.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5C6BC0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF5C6BC0).withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? const Color(0xFF5C6BC0)
                      : const Color(0xFF616161),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.normal,
                    color: isSelected
                        ? const Color(0xFF5C6BC0)
                        : const Color(0xFF424242),
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5C6BC0),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
