import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';

class LiveChartsPage extends StatefulWidget {
  const LiveChartsPage({super.key});

  @override
  State<LiveChartsPage> createState() => _LiveChartsPageState();
}

class _LiveChartsPageState extends State<LiveChartsPage> {
  final _random = Random();

  // ── Controllers ────────────────────────────────────────────────────────────
  final _lineController = LiveDataController<double>();
  final _multiLineController = LiveDataController<List<double>>();
  final _areaController = LiveDataController<double>();
  final _barController = LiveDataController<List<BarData>>();

  // ── Tickers ────────────────────────────────────────────────────────────────
  LiveTicker? _ticker;

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isPlaying = false;
  String _speed = 'Normal';
  double _lineValue = 50;
  double _areaValue = 40;
  List<double> _barValues = [30, 80, 55, 65, 40];
  List<double> _multiValues = [50, 40];

  static const _speeds = {
    'Slow': Duration(milliseconds: 1200),
    'Normal': Duration(milliseconds: 700),
    'Fast': Duration(milliseconds: 300),
  };

  // ── Bar labels ─────────────────────────────────────────────────────────────
  static const _barLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  @override
  void dispose() {
    _ticker?.dispose();
    _lineController.dispose();
    _multiLineController.dispose();
    _areaController.dispose();
    _barController.dispose();
    super.dispose();
  }

  // ── Ticker control ─────────────────────────────────────────────────────────

  void _startTicker() {
    _ticker?.dispose();
    _ticker = LiveTicker(
      interval: _speeds[_speed]!,
      onTick: _tick,
    );
  }

  void _tick() {
    // Line — random walk
    _lineValue = (_lineValue + (_random.nextDouble() * 20 - 10)).clamp(0, 100);
    _lineController.add(_lineValue);

    // Multi-line — two independent random walks
    _multiValues = [
      (_multiValues[0] + (_random.nextDouble() * 16 - 8)).clamp(0, 100),
      (_multiValues[1] + (_random.nextDouble() * 16 - 8)).clamp(0, 100),
    ];
    _multiLineController.add(_multiValues);

    // Area — random walk
    _areaValue = (_areaValue + (_random.nextDouble() * 18 - 9)).clamp(0, 100);
    _areaController.add(_areaValue);

    // Bar — randomize all bars
    _barValues = List.generate(
      5,
      (i) => (_barValues[i] + (_random.nextDouble() * 30 - 15)).clamp(5, 100),
    );
    _barController.add(
      List.generate(
        5,
        (i) => BarData(value: _barValues[i], label: _barLabels[i]),
      ),
    );
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startTicker();
    } else {
      _ticker?.dispose();
      _ticker = null;
    }
  }

  void _changeSpeed(String speed) {
    setState(() => _speed = speed);
    if (_isPlaying) _startTicker();
  }

  void _reset() {
    setState(() {
      _isPlaying = false;
      _lineValue = 50;
      _areaValue = 40;
      _barValues = [30, 80, 55, 65, 40];
      _multiValues = [50, 40];
    });
    _ticker?.dispose();
    _ticker = null;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildControls(),
        _buildSection(
          title: '📈 Live Line Chart',
          subtitle: 'Single series · Random walk · Rolling 20 points',
          child: FlLiveLineChart(
            controller: _lineController,
            label: 'Value',
            color: const Color(0xFF5C6BC0),
            maxPoints: 20,
            maxY: 100,
            minY: 0,
            showFill: true,
          ),
        ),
        _buildSection(
          title: '📊 Multi-Line Live Chart',
          subtitle: 'Two series · Independent random walks',
          child: FlLiveLineChart.multi(
            controller: _multiLineController,
            labels: const ['Series A', 'Series B'],
            colors: const [Color(0xFF5C6BC0), Color(0xFF26A69A)],
            maxPoints: 20,
            maxY: 100,
            minY: 0,
            showFill: true,
          ),
        ),
        _buildSection(
          title: '📉 Live Area Chart',
          subtitle: 'Single series · Gradient fill · Rolling window',
          child: FlLiveAreaChart(
            controller: _areaController,
            label: 'Usage',
            color: const Color(0xFFFF7043),
            maxPoints: 20,
            maxY: 100,
            minY: 0,
            fillOpacity: 0.35,
          ),
        ),
        _buildSection(
          title: '📊 Live Bar Chart',
          subtitle: 'Tween transitions · All bars update simultaneously',
          child: FlLiveBarChart(
            controller: _barController,
            initialData: List.generate(
              5,
              (i) => BarData(value: _barValues[i], label: _barLabels[i]),
            ),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildControls() {
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
            '🎛️ Live Controls',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Play/Pause
              GestureDetector(
                onTap: _togglePlay,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? const Color(0xFFEF5350)
                        : const Color(0xFF5C6BC0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPlaying ? 'Pause' : 'Play',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Reset
              GestureDetector(
                onTap: _reset,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Color(0xFF616161), size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Reset',
                        style: TextStyle(
                          color: Color(0xFF616161),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Speed selector
          Row(
            children: [
              const Text(
                'Speed:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF616161),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              ..._speeds.keys.map((speed) {
                final isSelected = speed == _speed;
                return GestureDetector(
                  onTap: () => _changeSpeed(speed),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                    child: Text(
                      speed,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : const Color(0xFF616161),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 8),
          // Status indicator
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isPlaying
                      ? const Color(0xFF66BB6A)
                      : const Color(0xFF9E9E9E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _isPlaying ? 'Live · $_speed' : 'Paused — press Play to start',
                style: TextStyle(
                  fontSize: 12,
                  color: _isPlaying
                      ? const Color(0xFF66BB6A)
                      : const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
