import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'auto_scroll_settings.dart';

/// Drives a [ScrollController] forward/backward at a constant pixels-per-second
/// speed using a [Ticker]. Safe to start/stop/resume many times; exposes
/// [ValueListenable]s so the UI can rebuild reactively.
///
/// ```dart
/// final auto = AutoScrollController(
///   scrollController: ScrollController(),
///   vsync: this,
///   settings: const AutoScrollSettings(pixelsPerSecond: 80),
/// );
/// auto.start();
/// ```
class AutoScrollController {
  AutoScrollController({
    required this.scrollController,
    required TickerProvider vsync,
    AutoScrollSettings settings = const AutoScrollSettings(),
  })  : _settings = ValueNotifier<AutoScrollSettings>(settings),
        _isRunning = ValueNotifier<bool>(false),
        _isPaused = ValueNotifier<bool>(false) {
    _ticker = vsync.createTicker(_onTick);
  }

  /// The scroll controller this auto-scroller drives. Must be attached to the
  /// scrollable widget.
  final ScrollController scrollController;
  late final Ticker _ticker;

  final ValueNotifier<AutoScrollSettings> _settings;
  final ValueNotifier<bool> _isRunning;
  final ValueNotifier<bool> _isPaused;

  Duration? _lastElapsed;

  ValueListenable<AutoScrollSettings> get settingsListenable => _settings;
  ValueListenable<bool> get isRunningListenable => _isRunning;
  ValueListenable<bool> get isPausedListenable => _isPaused;

  AutoScrollSettings get settings => _settings.value;
  bool get isRunning => _isRunning.value;
  bool get isPaused => _isPaused.value;

  /// Update the full settings object.
  void updateSettings(AutoScrollSettings next) => _settings.value = next;

  /// Convenience: change the speed (pixels / second).
  void setSpeed(double pixelsPerSecond) {
    updateSettings(_settings.value.copyWith(pixelsPerSecond: pixelsPerSecond));
  }

  /// Convenience: set scroll direction (true = down, false = up).
  void setForward(bool forward) {
    updateSettings(_settings.value.copyWith(forward: forward));
  }

  /// Begin auto-scrolling. No-op if already running.
  void start() {
    if (_isRunning.value) return;
    _isPaused.value = false;
    _isRunning.value = true;
    _lastElapsed = null;
    if (!_ticker.isActive) _ticker.start();
  }

  /// Stop auto-scrolling. If [resumable] is true, records that scrolling was
  /// paused (so the UI can distinguish user-hold from user-toggle) — a call
  /// to [resume] will restart scrolling.
  void stop({bool resumable = false}) {
    if (!_isRunning.value && !resumable) {
      _isPaused.value = false;
      return;
    }
    _isRunning.value = false;
    _isPaused.value = resumable;
    if (_ticker.isActive) _ticker.stop();
    _lastElapsed = null;
  }

  /// Resume a previously-paused auto-scroll. No-op if not currently paused.
  void resume() {
    if (!_isPaused.value) return;
    start();
  }

  /// Toggle between running and stopped.
  void toggle() => _isRunning.value ? stop() : start();

  void _onTick(Duration elapsed) {
    final delta =
        _lastElapsed == null ? Duration.zero : elapsed - _lastElapsed!;
    _lastElapsed = elapsed;

    if (delta == Duration.zero) return;
    if (!scrollController.hasClients) return;

    final position = scrollController.position;
    final seconds = delta.inMicroseconds / 1000000.0;
    final pixelsDelta = _settings.value.pixelsPerSecond * seconds;

    final current = position.pixels;
    final min = position.minScrollExtent;
    final max = position.maxScrollExtent;

    double next = _settings.value.forward
        ? current + pixelsDelta
        : current - pixelsDelta;

    if (next >= max) {
      next = max;
      position.jumpTo(next);
      if (_settings.value.reverseAtEnd) {
        setForward(false);
      } else {
        stop();
      }
      return;
    }
    if (next <= min) {
      next = min;
      position.jumpTo(next);
      if (_settings.value.reverseAtEnd) {
        setForward(true);
      } else {
        stop();
      }
      return;
    }

    position.jumpTo(next);
  }

  /// Dispose all internal resources. Call from the owning widget's dispose().
  void dispose() {
    _ticker.dispose();
    _settings.dispose();
    _isRunning.dispose();
    _isPaused.dispose();
  }
}
