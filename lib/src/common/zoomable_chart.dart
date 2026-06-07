import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Configuration for [FlZoomableChart] zoom and pan behavior.
///
/// Example:
/// ```dart
/// ZoomConfig(
///   minScale: 1.0,
///   maxScale: 5.0,
///   enablePan: true,
///   enableZoom: true,
///   doubleTapToReset: true,
///   animationDuration: Duration(milliseconds: 200),
/// )
/// ```
class ZoomConfig {
  /// Minimum zoom scale. Defaults to `1.0` (original size).
  final double minScale;

  /// Maximum zoom scale. Defaults to `4.0`.
  final double maxScale;

  /// Whether pan (drag) is enabled. Defaults to `true`.
  final bool enablePan;

  /// Whether pinch-to-zoom is enabled. Defaults to `true`.
  final bool enableZoom;

  /// Whether mouse wheel zoom is enabled (web/desktop). Defaults to `true`.
  final bool enableMouseWheelZoom;

  /// Whether double tap resets zoom to original. Defaults to `true`.
  final bool doubleTapToReset;

  /// Animation duration for double-tap reset. Defaults to `300ms`.
  final Duration animationDuration;

  /// Animation curve for double-tap reset. Defaults to [Curves.easeOutCubic].
  final Curve animationCurve;

  /// Zoom sensitivity for mouse wheel. Defaults to `0.1`.
  final double mouseWheelSensitivity;

  const ZoomConfig({
    this.minScale = 1.0,
    this.maxScale = 4.0,
    this.enablePan = true,
    this.enableZoom = true,
    this.enableMouseWheelZoom = true,
    this.doubleTapToReset = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
    this.mouseWheelSensitivity = 0.1,
  });
}

/// A wrapper that adds pinch-to-zoom and pan to any chart widget.
///
/// Wrap any fl_pretty_charts widget with [FlZoomableChart] to make it
/// zoomable and pannable. Works on touch, trackpad, and mouse wheel.
///
/// Basic example:
/// ```dart
/// FlZoomableChart(
///   child: FlBarChart(data: myData),
/// )
/// ```
///
/// With custom config:
/// ```dart
/// FlZoomableChart(
///   config: ZoomConfig(
///     maxScale: 6.0,
///     enableMouseWheelZoom: true,
///     doubleTapToReset: true,
///   ),
///   showControls: true,
///   child: FlLineChart(data: myLineData),
/// )
/// ```
class FlZoomableChart extends StatefulWidget {
  /// The chart widget to make zoomable.
  final Widget child;

  /// Zoom and pan behavior configuration.
  final ZoomConfig config;

  /// Whether to show the zoom control buttons overlay.
  /// Shows `+`, `-`, and reset buttons. Defaults to `true`.
  final bool showControls;

  /// Alignment of the zoom controls. Defaults to [Alignment.bottomRight].
  final Alignment controlsAlignment;

  /// Callback fired when zoom scale changes.
  final void Function(double scale)? onScaleChanged;

  const FlZoomableChart({
    super.key,
    required this.child,
    this.config = const ZoomConfig(),
    this.showControls = true,
    this.controlsAlignment = Alignment.bottomRight,
    this.onScaleChanged,
  });

  @override
  State<FlZoomableChart> createState() => _FlZoomableChartState();
}

class _FlZoomableChartState extends State<FlZoomableChart>
    with SingleTickerProviderStateMixin {
  // ── Transform state ────────────────────────────────────────────────────────
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _focalPoint = Offset.zero;

  // ── Animation ──────────────────────────────────────────────────────────────
  late AnimationController _animController;
  Animation<double>? _scaleAnim;
  Animation<Offset>? _offsetAnim;

  // ── Size ───────────────────────────────────────────────────────────────────
  Size _containerSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Gesture handlers ───────────────────────────────────────────────────────

  void _onScaleStart(ScaleStartDetails details) {
    _animController.stop();
    _previousScale = _scale;
    _focalPoint = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (widget.config.enableZoom && details.scale != 1.0) {
        final newScale = (_previousScale * details.scale)
            .clamp(widget.config.minScale, widget.config.maxScale);

        // Zoom toward focal point
        final focalDelta = _focalPoint - _offset;
        final scaleFactor = newScale / _scale;
        _offset = _focalPoint - focalDelta * scaleFactor;
        _scale = newScale;
        widget.onScaleChanged?.call(_scale);
      }

      if (widget.config.enablePan) {
        _offset += details.focalPointDelta;
      }

      _clampOffset();
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _previousScale = _scale;
  }

  void _onDoubleTap() {
    if (!widget.config.doubleTapToReset) return;
    _animateReset();
  }

  void _onMouseWheelZoom(PointerSignalEvent event) {
    if (!widget.config.enableMouseWheelZoom) return;
    if (event is! PointerScrollEvent) return;

    final delta = -event.scrollDelta.dy * widget.config.mouseWheelSensitivity;
    final newScale =
        (_scale + delta).clamp(widget.config.minScale, widget.config.maxScale);

    setState(() {
      final focalDelta = event.localPosition - _offset;
      final scaleFactor = newScale / _scale;
      _offset = event.localPosition - focalDelta * scaleFactor;
      _scale = newScale;
      _clampOffset();
      widget.onScaleChanged?.call(_scale);
    });
  }

  // ── Zoom controls ──────────────────────────────────────────────────────────

  void _zoomIn() {
    final newScale =
        (_scale + 0.5).clamp(widget.config.minScale, widget.config.maxScale);
    _animateToScale(newScale, _centerOffset(newScale));
  }

  void _zoomOut() {
    final newScale =
        (_scale - 0.5).clamp(widget.config.minScale, widget.config.maxScale);
    _animateToScale(newScale, _centerOffset(newScale));
  }

  void _reset() => _animateReset();

  // ── Animation helpers ──────────────────────────────────────────────────────

  void _animateReset() {
    _animateToScale(1.0, Offset.zero);
  }

  void _animateToScale(double targetScale, Offset targetOffset) {
    _scaleAnim = Tween<double>(begin: _scale, end: targetScale).animate(
      CurvedAnimation(
        parent: _animController,
        curve: widget.config.animationCurve,
      ),
    );
    _offsetAnim = Tween<Offset>(begin: _offset, end: targetOffset).animate(
      CurvedAnimation(
        parent: _animController,
        curve: widget.config.animationCurve,
      ),
    );

    _animController.forward(from: 0).then((_) {
      setState(() {
        _scale = targetScale;
        _offset = targetOffset;
        _previousScale = _scale;
      });
    });

    _animController.addListener(() {
      if (_scaleAnim != null && _offsetAnim != null) {
        setState(() {
          _scale = _scaleAnim!.value;
          _offset = _offsetAnim!.value;
          widget.onScaleChanged?.call(_scale);
        });
      }
    });
  }

  Offset _centerOffset(double scale) {
    if (_containerSize == Size.zero) return Offset.zero;
    final center = Offset(
      _containerSize.width / 2,
      _containerSize.height / 2,
    );
    return center - (center - _offset) * (scale / _scale);
  }

  void _clampOffset() {
    if (_containerSize == Size.zero) return;
    final maxOffsetX = _containerSize.width * (_scale - 1) / 2;
    final maxOffsetY = _containerSize.height * (_scale - 1) / 2;
    _offset = Offset(
      _offset.dx.clamp(-maxOffsetX, maxOffsetX),
      _offset.dy.clamp(-maxOffsetY, maxOffsetY),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _containerSize = Size(constraints.maxWidth, constraints.maxHeight);

        return ClipRect(
          child: Stack(
            children: [
              // ── Chart with transform ─────────────────────────────────
              Listener(
                onPointerSignal: _onMouseWheelZoom,
                child: GestureDetector(
                  onScaleStart: _onScaleStart,
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  onDoubleTap: _onDoubleTap,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translateByDouble(_offset.dx, _offset.dy, 0, 1)
                      ..scaleByDouble(_scale, _scale, 1, 1),
                    child: widget.child,
                  ),
                ),
              ),

              // ── Zoom controls ────────────────────────────────────────
              if (widget.showControls)
                Positioned.fill(
                  child: Align(
                    alignment: widget.controlsAlignment,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: _ZoomControls(
                        scale: _scale,
                        minScale: widget.config.minScale,
                        maxScale: widget.config.maxScale,
                        onZoomIn: _zoomIn,
                        onZoomOut: _zoomOut,
                        onReset: _reset,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// The zoom control buttons shown in the corner of [FlZoomableChart].
class _ZoomControls extends StatelessWidget {
  final double scale;
  final double minScale;
  final double maxScale;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const _ZoomControls({
    required this.scale,
    required this.minScale,
    required this.maxScale,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final isAtMin = scale <= minScale;
    final isAtMax = scale >= maxScale;
    final isDefault = (scale - 1.0).abs() < 0.01;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom in
          _ZoomButton(
            icon: Icons.add,
            onTap: isAtMax ? null : onZoomIn,
            tooltip: 'Zoom in',
          ),
          // Scale indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              '${(scale * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5C6BC0),
              ),
            ),
          ),
          // Zoom out
          _ZoomButton(
            icon: Icons.remove,
            onTap: isAtMin ? null : onZoomOut,
            tooltip: 'Zoom out',
          ),
          // Divider
          if (!isDefault)
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: const Color(0xFFEEEEEE),
            ),
          // Reset
          if (!isDefault)
            _ZoomButton(
              icon: Icons.center_focus_strong,
              onTap: onReset,
              tooltip: 'Reset zoom',
            ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 16,
            color: onTap == null
                ? const Color(0xFFBDBDBD)
                : const Color(0xFF5C6BC0),
          ),
        ),
      ),
    );
  }
}

/// Extension on [FlZoomableChart] providing convenience factory methods.
extension ZoomableChartX on FlZoomableChart {
  /// Creates a zoomable chart with mouse wheel disabled.
  /// Useful for mobile-only apps.
  static FlZoomableChart touchOnly({
    Key? key,
    required Widget child,
    bool showControls = true,
  }) {
    return FlZoomableChart(
      key: key,
      config: const ZoomConfig(enableMouseWheelZoom: false),
      showControls: showControls,
      child: child,
    );
  }

  /// Creates a zoomable chart with pan disabled — zoom only.
  static FlZoomableChart zoomOnly({
    Key? key,
    required Widget child,
    bool showControls = true,
  }) {
    return FlZoomableChart(
      key: key,
      config: const ZoomConfig(enablePan: false),
      showControls: showControls,
      child: child,
    );
  }
}
