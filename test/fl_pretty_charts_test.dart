import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_pretty_charts/fl_pretty_charts.dart';

void main() {
  // ── ChartUtils ─────────────────────────────────────────────────────────────
  group('ChartUtils', () {
    group('niceMax', () {
      test('returns 10 for zero or negative input', () {
        expect(ChartUtils.niceMax(0), equals(10.0));
        expect(ChartUtils.niceMax(-5), equals(10.0));
      });

      test('rounds up to nearest nice number with headroom', () {
        expect(ChartUtils.niceMax(87.0), equals(100.0));
        expect(ChartUtils.niceMax(43.0), equals(50.0));
        expect(ChartUtils.niceMax(10.0), equals(20.0));
        expect(ChartUtils.niceMax(100.0), equals(200.0));
      });

      test('result is always greater than input', () {
        final values = [1.0, 25.0, 50.0, 99.0, 150.0, 999.0];
        for (final v in values) {
          expect(ChartUtils.niceMax(v), greaterThan(v));
        }
      });
    });

    group('valueToY', () {
      test('maps min value to chartHeight (bottom)', () {
        expect(ChartUtils.valueToY(0, 0, 100, 300), equals(300.0));
      });

      test('maps max value to 0 (top)', () {
        expect(ChartUtils.valueToY(100, 0, 100, 300), equals(0.0));
      });

      test('maps midpoint value to half chartHeight', () {
        expect(ChartUtils.valueToY(50, 0, 100, 300), equals(150.0));
      });

      test('returns chartHeight when maxY equals minY', () {
        expect(ChartUtils.valueToY(50, 50, 50, 300), equals(300.0));
      });
    });

    group('formatValue', () {
      test('whole numbers have no decimal point', () {
        expect(ChartUtils.formatValue(42.0), equals('42'));
        expect(ChartUtils.formatValue(0.0), equals('0'));
        expect(ChartUtils.formatValue(100.0), equals('100'));
      });

      test('decimal numbers show one decimal place', () {
        expect(ChartUtils.formatValue(3.567), equals('3.6'));
        expect(ChartUtils.formatValue(0.1), equals('0.1'));
        expect(ChartUtils.formatValue(99.95), equals('100.0'));
      });
    });

    group('gridPaint', () {
      test('returns a Paint with stroke style', () {
        final paint = ChartUtils.gridPaint(Colors.grey, 0.3);
        expect(paint.style, equals(PaintingStyle.stroke));
        expect(paint.strokeWidth, equals(1.0));
      });
    });
  });

  // ── BarData ────────────────────────────────────────────────────────────────
  group('BarData', () {
    test('stores value and label correctly', () {
      const bar = BarData(value: 42.0, label: 'Jan');
      expect(bar.value, equals(42.0));
      expect(bar.label, equals('Jan'));
      expect(bar.color, isNull);
    });

    test('stores optional color override', () {
      const bar = BarData(value: 10.0, label: 'Feb', color: Colors.red);
      expect(bar.color, equals(Colors.red));
    });
  });

  // ── BarStyle ───────────────────────────────────────────────────────────────
  group('BarStyle', () {
    test('has correct defaults', () {
      const style = BarStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.barWidthFraction, equals(0.55));
      expect(style.gradient, isNull);
    });

    test('accepts custom values', () {
      const style = BarStyle(borderRadius: 12.0, barWidthFraction: 0.7);
      expect(style.borderRadius, equals(12.0));
      expect(style.barWidthFraction, equals(0.7));
    });
  });

  // ── AxisStyle ──────────────────────────────────────────────────────────────
  group('AxisStyle', () {
    test('has correct defaults', () {
      const style = AxisStyle();
      expect(style.showGrid, isTrue);
      expect(style.yAxisDivisions, equals(5));
      expect(style.gridOpacity, equals(0.2));
    });
  });

  // ── TooltipStyle ───────────────────────────────────────────────────────────
  group('TooltipStyle', () {
    test('has correct defaults', () {
      const style = TooltipStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.backgroundColor, equals(const Color(0xDD000000)));
    });
  });

  // ── BarChartData ───────────────────────────────────────────────────────────
  group('BarChartData', () {
    test('stores bars and defaults correctly', () {
      const chartData = BarChartData(
        bars: [
          BarData(value: 10, label: 'A'),
          BarData(value: 20, label: 'B'),
        ],
      );
      expect(chartData.bars.length, equals(2));
      expect(chartData.minY, equals(0.0));
      expect(chartData.maxY, isNull);
      expect(chartData.defaultColor, equals(const Color(0xFF5C6BC0)));
    });

    test('accepts custom maxY and minY', () {
      const chartData = BarChartData(
        bars: [BarData(value: 50, label: 'X')],
        maxY: 200.0,
        minY: 10.0,
      );
      expect(chartData.maxY, equals(200.0));
      expect(chartData.minY, equals(10.0));
    });
  });

  // ── ChartAnimation ─────────────────────────────────────────────────────────
  group('ChartAnimation', () {
    test('default has correct values', () {
      const anim = ChartAnimation();
      expect(anim.enabled, isTrue);
      expect(anim.duration, equals(const Duration(milliseconds: 900)));
      expect(anim.curve, equals(Curves.easeOutCubic));
    });

    test('elegant preset has 1200ms duration', () {
      final anim = ChartAnimation.elegant();
      expect(anim.duration, equals(const Duration(milliseconds: 1200)));
      expect(anim.enabled, isTrue);
    });

    test('snappy preset has 400ms duration', () {
      final anim = ChartAnimation.snappy();
      expect(anim.duration, equals(const Duration(milliseconds: 400)));
    });

    test('bouncy preset has 800ms duration', () {
      final anim = ChartAnimation.bouncy();
      expect(anim.duration, equals(const Duration(milliseconds: 800)));
    });

    test('none preset is disabled', () {
      final anim = ChartAnimation.none();
      expect(anim.enabled, isFalse);
      expect(anim.duration, equals(Duration.zero));
    });
  });

  // ── ChartTheme ─────────────────────────────────────────────────────────────
  group('ChartTheme', () {
    test('defaultTheme has 8 colors', () {
      final theme = ChartTheme.defaultTheme();
      expect(theme.colors.length, equals(8));
    });

    test('colorAt wraps around for out-of-range index', () {
      final theme = ChartTheme.defaultTheme();
      expect(theme.colorAt(0), equals(theme.colorAt(8)));
      expect(theme.colorAt(1), equals(theme.colorAt(9)));
    });

    test('ocean preset has correct first color', () {
      final theme = ChartTheme.ocean();
      expect(theme.colors.first, equals(const Color(0xFF0077B6)));
    });

    test('sunset preset has correct first color', () {
      final theme = ChartTheme.sunset();
      expect(theme.colors.first, equals(const Color(0xFFFF4D6D)));
    });

    test('forest preset has correct first color', () {
      final theme = ChartTheme.forest();
      expect(theme.colors.first, equals(const Color(0xFF2D6A4F)));
    });

    test('custom theme stores background and legendTextStyle', () {
      const theme = ChartTheme(
        colors: [Colors.red, Colors.blue],
        background: Colors.black,
        legendTextStyle: TextStyle(fontSize: 14),
      );
      expect(theme.background, equals(Colors.black));
      expect(theme.colors.length, equals(2));
    });
  });

  // ── FlBarChart Widget ──────────────────────────────────────────────────────
  group('FlBarChart widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: BarChartData(
                bars: [
                  BarData(value: 30, label: 'Mon'),
                  BarData(value: 80, label: 'Tue'),
                  BarData(value: 55, label: 'Wed'),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlBarChart), findsOneWidget);
    });

    testWidgets('renders with elegant animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 100, label: 'A'),
                  BarData(value: 200, label: 'B'),
                ],
              ),
              animation: ChartAnimation.elegant(),
            ),
          ),
        ),
      );
      expect(find.byType(FlBarChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 50, label: 'X'),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlBarChart), findsOneWidget);
    });

    testWidgets('onBarTapped callback fires on tap', (tester) async {
      int? tappedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 30, label: 'Mon'),
                  BarData(value: 80, label: 'Tue'),
                  BarData(value: 55, label: 'Wed'),
                ],
              ),
              animation: ChartAnimation.none(),
              onBarTapped: (bar, index) => tappedIndex = index,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tapAt(tester.getCenter(find.byType(FlBarChart)));
      expect(tappedIndex, isNotNull);
    });
  });

  // ── LinePoint ──────────────────────────────────────────────────────────────
  group('LinePoint', () {
    test('stores x, y and label correctly', () {
      const point = LinePoint(x: 0, y: 42.0, label: 'Jan');
      expect(point.x, equals(0));
      expect(point.y, equals(42.0));
      expect(point.label, equals('Jan'));
    });
  });

  // ── LineStyle ──────────────────────────────────────────────────────────────
  group('LineStyle', () {
    test('has correct defaults', () {
      const style = LineStyle();
      expect(style.color, equals(const Color(0xFF5C6BC0)));
      expect(style.strokeWidth, equals(3.0));
      expect(style.showFill, isTrue);
      expect(style.fillOpacity, equals(0.2));
      expect(style.showDots, isTrue);
      expect(style.dotRadius, equals(4.5));
      expect(style.smooth, isTrue);
      expect(style.gradient, isNull);
    });

    test('accepts custom values', () {
      const style = LineStyle(
        strokeWidth: 5.0,
        smooth: false,
        showFill: false,
        showDots: false,
        dotRadius: 8.0,
        fillOpacity: 0.5,
      );
      expect(style.strokeWidth, equals(5.0));
      expect(style.smooth, isFalse);
      expect(style.showFill, isFalse);
      expect(style.showDots, isFalse);
      expect(style.dotRadius, equals(8.0));
      expect(style.fillOpacity, equals(0.5));
    });
  });

  // ── LineData ───────────────────────────────────────────────────────────────
  group('LineData', () {
    test('stores points and label correctly', () {
      const data = LineData(
        points: [
          LinePoint(x: 0, y: 10, label: 'A'),
          LinePoint(x: 1, y: 20, label: 'B'),
        ],
        label: 'Revenue',
      );
      expect(data.points.length, equals(2));
      expect(data.label, equals('Revenue'));
    });

    test('uses default LineStyle when not provided', () {
      const data = LineData(
        points: [LinePoint(x: 0, y: 10, label: 'A')],
        label: 'Test',
      );
      expect(data.style.strokeWidth, equals(3.0));
      expect(data.style.smooth, isTrue);
    });

    test('accepts custom LineStyle', () {
      const data = LineData(
        points: [LinePoint(x: 0, y: 10, label: 'A')],
        label: 'Test',
        style: LineStyle(color: Colors.red, strokeWidth: 4.0),
      );
      expect(data.style.color, equals(Colors.red));
      expect(data.style.strokeWidth, equals(4.0));
    });
  });

  // ── AxisLineStyle ──────────────────────────────────────────────────────────
  group('AxisLineStyle', () {
    test('has correct defaults', () {
      const style = AxisLineStyle();
      expect(style.showGrid, isTrue);
      expect(style.yAxisDivisions, equals(5));
      expect(style.gridOpacity, equals(0.2));
    });

    test('accepts custom values', () {
      const style = AxisLineStyle(
        showGrid: false,
        yAxisDivisions: 3,
        gridOpacity: 0.5,
      );
      expect(style.showGrid, isFalse);
      expect(style.yAxisDivisions, equals(3));
      expect(style.gridOpacity, equals(0.5));
    });
  });

  // ── LineTooltipStyle ───────────────────────────────────────────────────────
  group('LineTooltipStyle', () {
    test('has correct defaults', () {
      const style = LineTooltipStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.backgroundColor, equals(const Color(0xDD000000)));
    });
  });

  // ── LineChartData ──────────────────────────────────────────────────────────
  group('LineChartData', () {
    test('stores lines and defaults correctly', () {
      const data = LineChartData(
        lines: [
          LineData(
            points: [
              LinePoint(x: 0, y: 10, label: 'A'),
              LinePoint(x: 1, y: 20, label: 'B'),
            ],
            label: 'Series 1',
          ),
        ],
      );
      expect(data.lines.length, equals(1));
      expect(data.minY, equals(0.0));
      expect(data.maxY, isNull);
    });

    test('stores multiple line series', () {
      const data = LineChartData(
        lines: [
          LineData(
            points: [LinePoint(x: 0, y: 10, label: 'A')],
            label: 'Series 1',
          ),
          LineData(
            points: [LinePoint(x: 0, y: 20, label: 'A')],
            label: 'Series 2',
          ),
        ],
      );
      expect(data.lines.length, equals(2));
      expect(data.lines[0].label, equals('Series 1'));
      expect(data.lines[1].label, equals('Series 2'));
    });

    test('accepts custom maxY and minY', () {
      const data = LineChartData(
        lines: [
          LineData(
            points: [LinePoint(x: 0, y: 50, label: 'X')],
            label: 'Test',
          ),
        ],
        maxY: 200.0,
        minY: 10.0,
      );
      expect(data.maxY, equals(200.0));
      expect(data.minY, equals(10.0));
    });
  });

  // ── FlLineChart Widget ─────────────────────────────────────────────────────
  group('FlLineChart widget', () {
    testWidgets('renders single line without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'Jan'),
                      LinePoint(x: 1, y: 80, label: 'Feb'),
                      LinePoint(x: 2, y: 55, label: 'Mar'),
                    ],
                    label: 'Revenue',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('renders multi-line without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'Jan'),
                      LinePoint(x: 1, y: 60, label: 'Feb'),
                    ],
                    label: 'Revenue',
                    style: LineStyle(color: Color(0xFF5C6BC0)),
                  ),
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 20, label: 'Jan'),
                      LinePoint(x: 1, y: 40, label: 'Feb'),
                    ],
                    label: 'Expenses',
                    style: LineStyle(color: Color(0xFFFF7043)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: const LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 50, label: 'A'),
                      LinePoint(x: 1, y: 80, label: 'B'),
                    ],
                    label: 'Test',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('renders straight lines without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 40, label: 'Q1'),
                      LinePoint(x: 1, y: 70, label: 'Q2'),
                      LinePoint(x: 2, y: 90, label: 'Q3'),
                    ],
                    label: 'Target',
                    style: LineStyle(smooth: false, showFill: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('onPointTapped callback is accepted by widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: const LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'Jan'),
                      LinePoint(x: 1, y: 80, label: 'Feb'),
                      LinePoint(x: 2, y: 55, label: 'Mar'),
                    ],
                    label: 'Revenue',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
              onPointTapped: (point, lineIndex, pointIndex) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Widget renders correctly with callback attached
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('FlLineChart renders with custom height and decoration',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: const LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'Jan'),
                      LinePoint(x: 1, y: 80, label: 'Feb'),
                    ],
                    label: 'Revenue',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
              height: 320,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlLineChart), findsOneWidget);
    });
  });

  // ── PieSegment ─────────────────────────────────────────────────────────────
  group('PieSegment', () {
    test('stores value, label and color correctly', () {
      const segment = PieSegment(
        value: 40,
        label: 'Flutter',
        color: Color(0xFF5C6BC0),
      );
      expect(segment.value, equals(40));
      expect(segment.label, equals('Flutter'));
      expect(segment.color, equals(const Color(0xFF5C6BC0)));
      expect(segment.gradient, isNull);
    });

    test('accepts optional gradient', () {
      const segment = PieSegment(
        value: 30,
        label: 'React',
        color: Color(0xFF26A69A),
        gradient: SweepGradient(
          colors: [Color(0xFF26A69A), Color(0xFF5C6BC0)],
        ),
      );
      expect(segment.gradient, isNotNull);
    });
  });

  // ── LegendStyle ────────────────────────────────────────────────────────────
  group('LegendStyle', () {
    test('has correct defaults', () {
      const style = LegendStyle();
      expect(style.show, isTrue);
      expect(style.position, equals(LegendPosition.bottom));
      expect(style.dotSize, equals(10.0));
      expect(style.spacing, equals(16.0));
    });

    test('accepts custom values', () {
      const style = LegendStyle(
        show: false,
        dotSize: 14.0,
        spacing: 24.0,
        position: LegendPosition.top,
      );
      expect(style.show, isFalse);
      expect(style.dotSize, equals(14.0));
      expect(style.spacing, equals(24.0));
      expect(style.position, equals(LegendPosition.top));
    });
  });

  // ── CenterLabelStyle ───────────────────────────────────────────────────────
  group('CenterLabelStyle', () {
    test('has correct defaults', () {
      const style = CenterLabelStyle();
      expect(style.title, isNull);
      expect(style.value, isNull);
    });

    test('accepts title and value', () {
      const style = CenterLabelStyle(
        title: 'Total',
        value: '1,250',
      );
      expect(style.title, equals('Total'));
      expect(style.value, equals('1,250'));
    });
  });

  // ── PieTooltipStyle ────────────────────────────────────────────────────────
  group('PieTooltipStyle', () {
    test('has correct defaults', () {
      const style = PieTooltipStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.backgroundColor, equals(const Color(0xDD000000)));
    });
  });

  // ── PieChartData ───────────────────────────────────────────────────────────
  group('PieChartData', () {
    test('stores segments and defaults correctly', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 40, label: 'A', color: Color(0xFF5C6BC0)),
          PieSegment(value: 60, label: 'B', color: Color(0xFF26A69A)),
        ],
      );
      expect(data.segments.length, equals(2));
      expect(data.donut, isFalse);
      expect(data.donutRadius, equals(0.55));
      expect(data.segmentGap, equals(1.5));
      expect(data.expandOffset, equals(10.0));
      expect(data.startAngle, equals(-90));
    });

    test('donut mode stores correct values', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 50, label: 'A', color: Color(0xFF5C6BC0)),
          PieSegment(value: 50, label: 'B', color: Color(0xFF26A69A)),
        ],
        donut: true,
        donutRadius: 0.6,
      );
      expect(data.donut, isTrue);
      expect(data.donutRadius, equals(0.6));
    });

    test('accepts custom segmentGap and expandOffset', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 100, label: 'A', color: Colors.blue),
        ],
        segmentGap: 4.0,
        expandOffset: 16.0,
      );
      expect(data.segmentGap, equals(4.0));
      expect(data.expandOffset, equals(16.0));
    });

    test('accepts centerLabel in donut mode', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 100, label: 'A', color: Colors.blue),
        ],
        donut: true,
        centerLabel: CenterLabelStyle(title: 'Total', value: '100'),
      );
      expect(data.centerLabel, isNotNull);
      expect(data.centerLabel!.title, equals('Total'));
      expect(data.centerLabel!.value, equals('100'));
    });

    test('accepts custom startAngle', () {
      const data = PieChartData(
        segments: [
          PieSegment(value: 100, label: 'A', color: Colors.blue),
        ],
        startAngle: 0,
      );
      expect(data.startAngle, equals(0));
    });
  });

  // ── FlPieChart Widget ──────────────────────────────────────────────────────
  group('FlPieChart widget', () {
    testWidgets('renders basic pie chart without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: PieChartData(
                segments: [
                  PieSegment(value: 40, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 30, label: 'B', color: Color(0xFF26A69A)),
                  PieSegment(value: 30, label: 'C', color: Color(0xFFFF7043)),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('renders donut chart without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: PieChartData(
                segments: [
                  PieSegment(value: 50, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 50, label: 'B', color: Color(0xFF26A69A)),
                ],
                donut: true,
                donutRadius: 0.55,
                centerLabel: CenterLabelStyle(
                  title: 'Total',
                  value: '100',
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: const PieChartData(
                segments: [
                  PieSegment(value: 60, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 40, label: 'B', color: Color(0xFF26A69A)),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('renders legend when show is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlPieChart(
                data: PieChartData(
                  segments: [
                    PieSegment(
                        value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
                    PieSegment(
                        value: 60, label: 'React', color: Color(0xFF26A69A)),
                  ],
                  legendStyle: LegendStyle(show: true),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Flutter (40.0%)'), findsOneWidget);
      expect(find.text('React (60.0%)'), findsOneWidget);
    });

    testWidgets('does not render legend when show is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: PieChartData(
                segments: [
                  PieSegment(
                      value: 40, label: 'Flutter', color: Color(0xFF5C6BC0)),
                  PieSegment(
                      value: 60, label: 'React', color: Color(0xFF26A69A)),
                ],
                legendStyle: LegendStyle(show: false),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Flutter (40.0%)'), findsNothing);
      expect(find.text('React (60.0%)'), findsNothing);
    });

    testWidgets('onSegmentTapped callback is accepted by widget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: const PieChartData(
                segments: [
                  PieSegment(value: 40, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 60, label: 'B', color: Color(0xFF26A69A)),
                ],
              ),
              animation: ChartAnimation.none(),
              onSegmentTapped: (segment, index) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('renders with elegant animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: const PieChartData(
                segments: [
                  PieSegment(value: 40, label: 'A', color: Color(0xFF5C6BC0)),
                  PieSegment(value: 60, label: 'B', color: Color(0xFF26A69A)),
                ],
              ),
              animation: ChartAnimation.elegant(),
            ),
          ),
        ),
      );
      expect(find.byType(FlPieChart), findsOneWidget);
    });
  });
  // ── RadarDatasetStyle ──────────────────────────────────────────────────────
  group('RadarDatasetStyle', () {
    test('has correct defaults', () {
      const style = RadarDatasetStyle();
      expect(style.color, equals(const Color(0xFF5C6BC0)));
      expect(style.strokeWidth, equals(2.5));
      expect(style.fillOpacity, equals(0.25));
      expect(style.showDots, isTrue);
      expect(style.dotRadius, equals(4.0));
    });

    test('accepts custom values', () {
      const style = RadarDatasetStyle(
        color: Colors.red,
        strokeWidth: 4.0,
        fillOpacity: 0.5,
        showDots: false,
        dotRadius: 6.0,
      );
      expect(style.color, equals(Colors.red));
      expect(style.strokeWidth, equals(4.0));
      expect(style.fillOpacity, equals(0.5));
      expect(style.showDots, isFalse);
      expect(style.dotRadius, equals(6.0));
    });
  });

  // ── RadarDataset ───────────────────────────────────────────────────────────
  group('RadarDataset', () {
    test('stores values and label correctly', () {
      const dataset = RadarDataset(
        values: [80, 90, 70, 85, 60],
        label: 'Hero A',
      );
      expect(dataset.values.length, equals(5));
      expect(dataset.label, equals('Hero A'));
      expect(dataset.values[0], equals(80));
      expect(dataset.values[4], equals(60));
    });

    test('uses default style when not provided', () {
      const dataset = RadarDataset(
        values: [50, 60, 70],
        label: 'Test',
      );
      expect(dataset.style.strokeWidth, equals(2.5));
      expect(dataset.style.showDots, isTrue);
    });

    test('accepts custom style', () {
      const dataset = RadarDataset(
        values: [50, 60, 70],
        label: 'Test',
        style: RadarDatasetStyle(
          color: Colors.purple,
          strokeWidth: 3.5,
        ),
      );
      expect(dataset.style.color, equals(Colors.purple));
      expect(dataset.style.strokeWidth, equals(3.5));
    });
  });

  // ── RadarGridStyle ─────────────────────────────────────────────────────────
  group('RadarGridStyle', () {
    test('has correct defaults', () {
      const style = RadarGridStyle();
      expect(style.showGrid, isTrue);
      expect(style.gridLevels, equals(5));
      expect(style.gridOpacity, equals(0.25));
      expect(style.spokeOpacity, equals(0.3));
    });

    test('accepts custom values', () {
      const style = RadarGridStyle(
        showGrid: false,
        gridLevels: 3,
        gridOpacity: 0.5,
        spokeOpacity: 0.6,
      );
      expect(style.showGrid, isFalse);
      expect(style.gridLevels, equals(3));
      expect(style.gridOpacity, equals(0.5));
      expect(style.spokeOpacity, equals(0.6));
    });
  });

  // ── RadarLegendStyle ───────────────────────────────────────────────────────
  group('RadarLegendStyle', () {
    test('has correct defaults', () {
      const style = RadarLegendStyle();
      expect(style.show, isTrue);
      expect(style.dotSize, equals(10.0));
      expect(style.spacing, equals(16.0));
    });

    test('accepts custom values', () {
      const style = RadarLegendStyle(
        show: false,
        dotSize: 14.0,
        spacing: 24.0,
      );
      expect(style.show, isFalse);
      expect(style.dotSize, equals(14.0));
      expect(style.spacing, equals(24.0));
    });
  });

  // ── RadarChartData ─────────────────────────────────────────────────────────
  group('RadarChartData', () {
    test('stores labels and datasets correctly', () {
      const data = RadarChartData(
        labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
        datasets: [
          RadarDataset(
            values: [80, 90, 70, 85, 60],
            label: 'Hero A',
          ),
        ],
      );
      expect(data.labels.length, equals(5));
      expect(data.datasets.length, equals(1));
      expect(data.maxValue, equals(100.0));
      expect(data.minValue, equals(0.0));
    });

    test('stores multiple datasets correctly', () {
      const data = RadarChartData(
        labels: ['A', 'B', 'C', 'D'],
        datasets: [
          RadarDataset(values: [50, 60, 70, 80], label: 'Series 1'),
          RadarDataset(values: [80, 70, 60, 50], label: 'Series 2'),
        ],
      );
      expect(data.datasets.length, equals(2));
      expect(data.datasets[0].label, equals('Series 1'));
      expect(data.datasets[1].label, equals('Series 2'));
    });

    test('accepts custom maxValue and minValue', () {
      const data = RadarChartData(
        labels: ['A', 'B', 'C'],
        datasets: [
          RadarDataset(values: [50, 60, 70], label: 'Test'),
        ],
        maxValue: 200.0,
        minValue: 10.0,
      );
      expect(data.maxValue, equals(200.0));
      expect(data.minValue, equals(10.0));
    });

    test('accepts custom grid and legend styles', () {
      const data = RadarChartData(
        labels: ['A', 'B', 'C'],
        datasets: [
          RadarDataset(values: [50, 60, 70], label: 'Test'),
        ],
        gridStyle: RadarGridStyle(gridLevels: 3, showGrid: false),
        legendStyle: RadarLegendStyle(show: false),
      );
      expect(data.gridStyle.gridLevels, equals(3));
      expect(data.gridStyle.showGrid, isFalse);
      expect(data.legendStyle.show, isFalse);
    });
  });

  // ── FlRadarChart Widget ────────────────────────────────────────────────────
  group('FlRadarChart widget', () {
    testWidgets('renders single dataset without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: RadarChartData(
                labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
                datasets: [
                  RadarDataset(
                    values: [80, 90, 70, 85, 60],
                    label: 'Hero A',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('renders multi-dataset without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: RadarChartData(
                labels: ['Speed', 'Power', 'Agility', 'Defense', 'Stamina'],
                datasets: [
                  RadarDataset(
                    values: [80, 90, 70, 85, 60],
                    label: 'Hero A',
                    style: RadarDatasetStyle(color: Color(0xFF5C6BC0)),
                  ),
                  RadarDataset(
                    values: [60, 70, 85, 60, 90],
                    label: 'Hero B',
                    style: RadarDatasetStyle(color: Color(0xFF26A69A)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: const RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Test',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('renders legend when show is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlRadarChart(
                data: RadarChartData(
                  labels: ['A', 'B', 'C', 'D', 'E'],
                  datasets: [
                    RadarDataset(
                      values: [60, 70, 80, 90, 50],
                      label: 'Hero A',
                    ),
                    RadarDataset(
                      values: [80, 60, 70, 50, 90],
                      label: 'Hero B',
                    ),
                  ],
                  legendStyle: RadarLegendStyle(show: true),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hero A'), findsOneWidget);
      expect(find.text('Hero B'), findsOneWidget);
    });

    testWidgets('does not render legend when show is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Hero A',
                  ),
                ],
                legendStyle: RadarLegendStyle(show: false),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hero A'), findsNothing);
    });

    testWidgets('renders with elegant animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: const RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Test',
                  ),
                ],
              ),
              animation: ChartAnimation.elegant(),
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('onDatasetTapped callback is accepted by widget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: const RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Test',
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
              onDatasetTapped: (dataset, index) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    testWidgets('renders with 8 axes without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: RadarChartData(
                labels: [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                ],
                datasets: [
                  RadarDataset(
                    values: [65, 80, 55, 90, 70, 85, 60, 75],
                    label: 'Monthly',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });
  });

  // ── LegendItem ─────────────────────────────────────────────────────────────
  group('LegendItem', () {
    test('stores color and label correctly', () {
      const item = LegendItem(
        color: Color(0xFF5C6BC0),
        label: 'Revenue',
      );
      expect(item.color, equals(const Color(0xFF5C6BC0)));
      expect(item.label, equals('Revenue'));
      expect(item.textStyle, isNull);
    });

    test('accepts optional textStyle', () {
      const item = LegendItem(
        color: Colors.red,
        label: 'Expenses',
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      );
      expect(item.textStyle, isNotNull);
      expect(item.textStyle!.fontWeight, equals(FontWeight.bold));
    });
  });

  // ── LegendWidget ───────────────────────────────────────────────────────────
  group('LegendWidget', () {
    test('has correct defaults', () {
      const widget = LegendWidget(items: []);
      expect(widget.dotSize, equals(10.0));
      expect(widget.spacing, equals(16.0));
      expect(widget.runSpacing, equals(8.0));
      expect(widget.alignment, equals(WrapAlignment.center));
      expect(widget.dotShape, equals(BoxShape.circle));
    });

    testWidgets('renders all legend items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LegendWidget(
              items: [
                LegendItem(color: Color(0xFF5C6BC0), label: 'Revenue'),
                LegendItem(color: Color(0xFF26A69A), label: 'Expenses'),
                LegendItem(color: Color(0xFFFF7043), label: 'Profit'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Profit'), findsOneWidget);
    });

    testWidgets('renders with empty items list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LegendWidget(items: []),
          ),
        ),
      );
      expect(find.byType(LegendWidget), findsOneWidget);
    });

    testWidgets('renders with square dot shape', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LegendWidget(
              dotShape: BoxShape.rectangle,
              dotSize: 12,
              items: [
                LegendItem(color: Color(0xFF5C6BC0), label: 'Series 1'),
                LegendItem(color: Color(0xFF26A69A), label: 'Series 2'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Series 1'), findsOneWidget);
      expect(find.text('Series 2'), findsOneWidget);
    });

    testWidgets('renders with custom spacing and alignment', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LegendWidget(
              spacing: 24,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              items: [
                LegendItem(color: Colors.blue, label: 'A'),
                LegendItem(color: Colors.red, label: 'B'),
              ],
            ),
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('renders with per-item textStyle override', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LegendWidget(
              items: [
                LegendItem(
                  color: Colors.blue,
                  label: 'Bold Item',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                LegendItem(
                  color: Colors.red,
                  label: 'Normal Item',
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Bold Item'), findsOneWidget);
      expect(find.text('Normal Item'), findsOneWidget);
    });
  });

  // ── ChartTheme integration ─────────────────────────────────────────────────
  group('ChartTheme integration', () {
    testWidgets('FlBarChart applies theme color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 30, label: 'A'),
                  BarData(value: 60, label: 'B'),
                ],
              ),
              theme: ChartTheme.ocean(),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      expect(find.byType(FlBarChart), findsOneWidget);
    });

    testWidgets('FlLineChart applies theme colors to series', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlLineChart(
              data: const LineChartData(
                lines: [
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 30, label: 'A'),
                      LinePoint(x: 1, y: 60, label: 'B'),
                    ],
                    label: 'Series 1',
                  ),
                  LineData(
                    points: [
                      LinePoint(x: 0, y: 20, label: 'A'),
                      LinePoint(x: 1, y: 40, label: 'B'),
                    ],
                    label: 'Series 2',
                  ),
                ],
              ),
              theme: ChartTheme.sunset(),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      expect(find.byType(FlLineChart), findsOneWidget);
    });

    testWidgets('FlPieChart applies theme colors to segments', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlPieChart(
              data: const PieChartData(
                segments: [
                  PieSegment(value: 40, label: 'A', color: Colors.grey),
                  PieSegment(value: 60, label: 'B', color: Colors.grey),
                ],
              ),
              theme: ChartTheme.forest(),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      expect(find.byType(FlPieChart), findsOneWidget);
    });

    testWidgets('FlRadarChart applies theme colors to datasets',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlRadarChart(
              data: const RadarChartData(
                labels: ['A', 'B', 'C', 'D', 'E'],
                datasets: [
                  RadarDataset(
                    values: [60, 70, 80, 90, 50],
                    label: 'Series 1',
                  ),
                  RadarDataset(
                    values: [80, 60, 70, 50, 90],
                    label: 'Series 2',
                  ),
                ],
              ),
              theme: ChartTheme.ocean(),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      expect(find.byType(FlRadarChart), findsOneWidget);
    });

    test('ChartTheme.colorAt wraps correctly for all presets', () {
      for (final theme in [
        ChartTheme.defaultTheme(),
        ChartTheme.ocean(),
        ChartTheme.sunset(),
        ChartTheme.forest(),
      ]) {
        expect(theme.colorAt(0), equals(theme.colors.first));
        expect(
          theme.colorAt(theme.colors.length),
          equals(theme.colors.first),
        );
      }
    });
  });

  // ── FlHorizontalBarChart Widget ────────────────────────────────────────────
  group('FlHorizontalBarChart widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                  BarData(value: 50, label: 'Vue'),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('renders with elegant animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                ],
              ),
              animation: ChartAnimation.elegant(),
            ),
          ),
        ),
      );
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('renders with gradient bar style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                  BarData(value: 50, label: 'Vue'),
                ],
                barStyle: BarStyle(
                  borderRadius: 10,
                  gradient: LinearGradient(
                    colors: [Color(0xFF5C6BC0), Color(0xFF26A69A)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('renders with per-bar colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: BarChartData(
                bars: [
                  BarData(value: 80, label: 'A', color: Color(0xFF5C6BC0)),
                  BarData(value: 65, label: 'B', color: Color(0xFF26A69A)),
                  BarData(value: 50, label: 'C', color: Color(0xFFFF7043)),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('renders with custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                ],
              ),
              animation: ChartAnimation.none(),
              height: 200,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('renders with ChartTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                  BarData(value: 50, label: 'Vue'),
                ],
              ),
              theme: ChartTheme.ocean(),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('renders with decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                ],
              ),
              animation: ChartAnimation.none(),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('onBarTapped callback is accepted by widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: const BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                  BarData(value: 50, label: 'Vue'),
                ],
              ),
              animation: ChartAnimation.none(),
              onBarTapped: (bar, index) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });

    testWidgets('renders with maxY override', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlHorizontalBarChart(
              data: BarChartData(
                bars: [
                  BarData(value: 80, label: 'Flutter'),
                  BarData(value: 65, label: 'React'),
                ],
                maxY: 200,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlHorizontalBarChart), findsOneWidget);
    });
  });

  // ── StackedBarSeries ───────────────────────────────────────────────────────
  group('StackedBarSeries', () {
    test('stores label, color and values correctly', () {
      const series = StackedBarSeries(
        label: 'Revenue',
        color: Color(0xFF5C6BC0),
        values: [30, 50, 40, 60],
      );
      expect(series.label, equals('Revenue'));
      expect(series.color, equals(const Color(0xFF5C6BC0)));
      expect(series.values.length, equals(4));
      expect(series.values[0], equals(30));
      expect(series.values[3], equals(60));
    });
  });

  // ── StackedBarStyle ────────────────────────────────────────────────────────
  group('StackedBarStyle', () {
    test('has correct defaults', () {
      const style = StackedBarStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.barWidthFraction, equals(0.6));
    });

    test('accepts custom values', () {
      const style = StackedBarStyle(
        borderRadius: 12.0,
        barWidthFraction: 0.8,
      );
      expect(style.borderRadius, equals(12.0));
      expect(style.barWidthFraction, equals(0.8));
    });
  });

  // ── StackedAxisStyle ───────────────────────────────────────────────────────
  group('StackedAxisStyle', () {
    test('has correct defaults', () {
      const style = StackedAxisStyle();
      expect(style.showGrid, isTrue);
      expect(style.yAxisDivisions, equals(5));
      expect(style.gridOpacity, equals(0.2));
    });

    test('accepts custom values', () {
      const style = StackedAxisStyle(
        showGrid: false,
        yAxisDivisions: 3,
        gridOpacity: 0.4,
      );
      expect(style.showGrid, isFalse);
      expect(style.yAxisDivisions, equals(3));
      expect(style.gridOpacity, equals(0.4));
    });
  });

  // ── StackedTooltipStyle ────────────────────────────────────────────────────
  group('StackedTooltipStyle', () {
    test('has correct defaults', () {
      const style = StackedTooltipStyle();
      expect(style.borderRadius, equals(6.0));
      expect(style.backgroundColor, equals(const Color(0xDD000000)));
    });
  });

  // ── StackedBarChartData ────────────────────────────────────────────────────
  group('StackedBarChartData', () {
    test('stores groups and series correctly', () {
      const data = StackedBarChartData(
        groups: ['Q1', 'Q2', 'Q3', 'Q4'],
        series: [
          StackedBarSeries(
            label: 'Revenue',
            color: Color(0xFF5C6BC0),
            values: [30, 50, 40, 60],
          ),
          StackedBarSeries(
            label: 'Expenses',
            color: Color(0xFF26A69A),
            values: [20, 30, 25, 35],
          ),
        ],
      );
      expect(data.groups.length, equals(4));
      expect(data.series.length, equals(2));
      expect(data.series[0].label, equals('Revenue'));
      expect(data.series[1].label, equals('Expenses'));
    });

    test('has correct defaults', () {
      const data = StackedBarChartData(
        groups: ['A', 'B'],
        series: [
          StackedBarSeries(
            label: 'S1',
            color: Colors.blue,
            values: [10, 20],
          ),
        ],
      );
      expect(data.percentageMode, isFalse);
      expect(data.maxY, isNull);
    });

    test('accepts percentageMode', () {
      const data = StackedBarChartData(
        groups: ['A', 'B'],
        series: [
          StackedBarSeries(
            label: 'S1',
            color: Colors.blue,
            values: [60, 70],
          ),
          StackedBarSeries(
            label: 'S2',
            color: Colors.red,
            values: [40, 30],
          ),
        ],
        percentageMode: true,
      );
      expect(data.percentageMode, isTrue);
    });

    test('accepts custom maxY', () {
      const data = StackedBarChartData(
        groups: ['A', 'B'],
        series: [
          StackedBarSeries(
            label: 'S1',
            color: Colors.blue,
            values: [10, 20],
          ),
        ],
        maxY: 200.0,
      );
      expect(data.maxY, equals(200.0));
    });

    test('accepts custom barStyle and axisStyle', () {
      const data = StackedBarChartData(
        groups: ['A', 'B'],
        series: [
          StackedBarSeries(
            label: 'S1',
            color: Colors.blue,
            values: [10, 20],
          ),
        ],
        barStyle: StackedBarStyle(borderRadius: 12, barWidthFraction: 0.7),
        axisStyle: StackedAxisStyle(showGrid: false, yAxisDivisions: 3),
      );
      expect(data.barStyle.borderRadius, equals(12.0));
      expect(data.barStyle.barWidthFraction, equals(0.7));
      expect(data.axisStyle.showGrid, isFalse);
      expect(data.axisStyle.yAxisDivisions, equals(3));
    });
  });

  // ── FlStackedBarChart Widget ───────────────────────────────────────────────
  group('FlStackedBarChart widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlStackedBarChart(
              data: StackedBarChartData(
                groups: ['Q1', 'Q2', 'Q3', 'Q4'],
                series: [
                  StackedBarSeries(
                    label: 'Revenue',
                    color: Color(0xFF5C6BC0),
                    values: [30, 50, 40, 60],
                  ),
                  StackedBarSeries(
                    label: 'Expenses',
                    color: Color(0xFF26A69A),
                    values: [20, 30, 25, 35],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlStackedBarChart), findsOneWidget);
    });

    testWidgets('renders with percentage mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlStackedBarChart(
              data: StackedBarChartData(
                groups: ['Jan', 'Feb', 'Mar'],
                series: [
                  StackedBarSeries(
                    label: 'Mobile',
                    color: Color(0xFF5C6BC0),
                    values: [60, 55, 65],
                  ),
                  StackedBarSeries(
                    label: 'Desktop',
                    color: Color(0xFF26A69A),
                    values: [40, 45, 35],
                  ),
                ],
                percentageMode: true,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlStackedBarChart), findsOneWidget);
    });

    testWidgets('renders with no animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlStackedBarChart(
              data: const StackedBarChartData(
                groups: ['A', 'B', 'C'],
                series: [
                  StackedBarSeries(
                    label: 'S1',
                    color: Color(0xFF5C6BC0),
                    values: [10, 20, 30],
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlStackedBarChart), findsOneWidget);
    });

    testWidgets('renders legend when showLegend is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlStackedBarChart(
                data: StackedBarChartData(
                  groups: ['Q1', 'Q2'],
                  series: [
                    StackedBarSeries(
                      label: 'Revenue',
                      color: Color(0xFF5C6BC0),
                      values: [30, 50],
                    ),
                    StackedBarSeries(
                      label: 'Expenses',
                      color: Color(0xFF26A69A),
                      values: [20, 30],
                    ),
                  ],
                ),
                showLegend: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('does not render legend when showLegend is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlStackedBarChart(
              data: StackedBarChartData(
                groups: ['Q1', 'Q2'],
                series: [
                  StackedBarSeries(
                    label: 'Revenue',
                    color: Color(0xFF5C6BC0),
                    values: [30, 50],
                  ),
                ],
              ),
              showLegend: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Revenue'), findsNothing);
    });

    testWidgets('renders with ChartTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlStackedBarChart(
              data: const StackedBarChartData(
                groups: ['Q1', 'Q2', 'Q3'],
                series: [
                  StackedBarSeries(
                    label: 'S1',
                    color: Colors.grey,
                    values: [30, 40, 50],
                  ),
                  StackedBarSeries(
                    label: 'S2',
                    color: Colors.grey,
                    values: [20, 30, 40],
                  ),
                ],
              ),
              theme: ChartTheme.ocean(),
              animation: ChartAnimation.none(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(FlStackedBarChart), findsOneWidget);
    });

    testWidgets('renders with four series', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlStackedBarChart(
              data: StackedBarChartData(
                groups: ['W1', 'W2', 'W3', 'W4'],
                series: [
                  StackedBarSeries(
                    label: 'Design',
                    color: Color(0xFFAB47BC),
                    values: [15, 20, 18, 22],
                  ),
                  StackedBarSeries(
                    label: 'Dev',
                    color: Color(0xFF5C6BC0),
                    values: [40, 35, 45, 38],
                  ),
                  StackedBarSeries(
                    label: 'QA',
                    color: Color(0xFF26A69A),
                    values: [10, 15, 12, 18],
                  ),
                  StackedBarSeries(
                    label: 'PM',
                    color: Color(0xFFFF7043),
                    values: [8, 10, 9, 12],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlStackedBarChart), findsOneWidget);
    });

    testWidgets('onSegmentTapped callback is accepted by widget',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlStackedBarChart(
              data: const StackedBarChartData(
                groups: ['Q1', 'Q2', 'Q3'],
                series: [
                  StackedBarSeries(
                    label: 'Revenue',
                    color: Color(0xFF5C6BC0),
                    values: [30, 50, 40],
                  ),
                  StackedBarSeries(
                    label: 'Expenses',
                    color: Color(0xFF26A69A),
                    values: [20, 30, 25],
                  ),
                ],
              ),
              animation: ChartAnimation.none(),
              onSegmentTapped: (series, gi, si) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FlStackedBarChart), findsOneWidget);
    });
  });
}
