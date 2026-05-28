import 'dart:async';
import 'package:flutter/material.dart';

/// Controls live data updates for fl_pretty_charts live widgets.
///
/// Create a [LiveDataController] and pass it to any live chart widget.
/// Use [add], [update], or [stream] to push new data into the chart.
///
/// The controller handles:
/// - Manual data pushes via [add] and [update]
/// - Stream-based data via [stream] setter
/// - Play/pause state
/// - Automatic disposal of stream subscriptions
///
/// Example — manual updates:
/// ```dart
/// final controller = LiveDataController<List<double>>();
///
/// // Push new data
/// controller.add([30, 80, 55, 65]);
///
/// // Dispose when done
/// controller.dispose();
/// ```
///
/// Example — stream based:
/// ```dart
/// final controller = LiveDataController<List<double>>();
/// controller.stream = myDataStream;
/// ```
class LiveDataController<T> {
  // ── Internal stream ────────────────────────────────────────────────────────

  final StreamController<T> _streamController = StreamController<T>.broadcast();

  StreamSubscription<T>? _externalSubscription;

  /// The stream of data updates. Listen to this in chart widgets.
  Stream<T> get dataStream => _streamController.stream;

  // ── State ──────────────────────────────────────────────────────────────────

  /// The most recently emitted data value.
  T? _lastValue;

  /// The most recently emitted data value.
  T? get lastValue => _lastValue;

  bool _paused = false;

  /// Whether the controller is currently paused.
  bool get isPaused => _paused;

  bool _disposed = false;

  /// Whether this controller has been disposed.
  bool get isDisposed => _disposed;

  // ── External stream ────────────────────────────────────────────────────────

  /// Attach an external [Stream<T>] as the data source.
  ///
  /// The controller will forward all events from this stream.
  /// Replaces any previously attached stream.
  ///
  /// Example:
  /// ```dart
  /// controller.stream = myTickerStream.map((_) => generateData());
  /// ```
  set stream(Stream<T> externalStream) {
    _externalSubscription?.cancel();
    _externalSubscription = externalStream.listen((data) {
      if (!_paused) add(data);
    });
  }

  // ── Data push ──────────────────────────────────────────────────────────────

  /// Pushes a new data value to all listening chart widgets.
  ///
  /// Does nothing if the controller is paused or disposed.
  ///
  /// Example:
  /// ```dart
  /// controller.add([30.0, 80.0, 55.0]);
  /// ```
  void add(T data) {
    if (_disposed || _paused) return;
    _lastValue = data;
    _streamController.add(data);
  }

  /// Alias for [add]. Semantically clearer when replacing all data.
  void update(T data) => add(data);

  // ── Playback control ───────────────────────────────────────────────────────

  /// Pauses all data updates. [add] calls are ignored while paused.
  void pause() => _paused = true;

  /// Resumes data updates after [pause].
  void resume() => _paused = false;

  /// Toggles between paused and playing state.
  void togglePause() => _paused = !_paused;

  // ── Disposal ───────────────────────────────────────────────────────────────

  /// Disposes the controller and cancels any external stream subscription.
  ///
  /// Always call this in your widget's [State.dispose] method.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _externalSubscription?.cancel();
    _streamController.close();
  }
}

/// A mixin that provides [LiveDataController] lifecycle management
/// to any chart [State] class.
///
/// Apply this mixin and call [initController] inside [initState].
/// The mixin automatically rebuilds the widget when new data arrives.
///
/// Example:
/// ```dart
/// class _FlLiveBarChartState extends State<FlLiveBarChart>
///     with LiveChartMixin<FlLiveBarChart, List<BarData>> {
///
///   @override
///   void initState() {
///     super.initState();
///     initController(widget.controller);
///   }
/// }
/// ```
mixin LiveChartMixin<W extends StatefulWidget, T> on State<W> {
  StreamSubscription<T>? _subscription;

  /// The latest data received from the controller.
  T? liveData;

  /// Subscribes to [controller]'s data stream and calls [setState]
  /// on every new emission.
  ///
  /// Pass an optional [onData] callback to transform or validate
  /// data before it is stored in [liveData].
  void initController(
    LiveDataController<T> controller, {
    void Function(T data)? onData,
  }) {
    // Seed with last value if available
    if (controller.lastValue != null) {
      liveData = controller.lastValue;
    }

    _subscription = controller.dataStream.listen((data) {
      if (!mounted) return;
      setState(() {
        liveData = data;
        onData?.call(data);
      });
    });
  }

  /// Cancels the stream subscription. Call inside [dispose].
  void disposeController() {
    _subscription?.cancel();
  }
}

/// A periodic timer helper for generating live data in examples and demos.
///
/// Creates a [Timer.periodic] that calls [onTick] at the given [interval].
/// Automatically cancelled on [dispose].
///
/// Example:
/// ```dart
/// final ticker = LiveTicker(
///   interval: Duration(milliseconds: 800),
///   onTick: () => controller.add(generateRandomData()),
/// );
///
/// // Later
/// ticker.dispose();
/// ```
class LiveTicker {
  Timer? _timer;

  /// Whether the ticker is currently running.
  bool get isRunning => _timer?.isActive ?? false;

  /// Creates and starts a periodic ticker.
  LiveTicker({
    required Duration interval,
    required VoidCallback onTick,
  }) {
    _timer = Timer.periodic(interval, (_) => onTick());
  }

  /// Cancels the ticker.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Pauses the ticker by cancelling it.
  /// Call [resume] with the same params to restart.
  void pause() {
    _timer?.cancel();
    _timer = null;
  }
}
