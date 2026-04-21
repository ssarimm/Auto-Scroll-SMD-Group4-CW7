import 'package:flutter/foundation.dart';

/// Immutable configuration for [AutoScrollController].
@immutable
class AutoScrollSettings {
  /// Scroll speed in logical pixels per second. Must be > 0.
  /// Typical comfortable reading speed: 40–100 px/s.
  final double pixelsPerSecond;

  /// When true, direction is forward (scrolling down). When false, reverse (up).
  final bool forward;

  /// When true, scrolling flips direction at the ends of the list.
  /// When false, scrolling simply stops at the end.
  final bool reverseAtEnd;

  const AutoScrollSettings({
    this.pixelsPerSecond = 60.0,
    this.forward = true,
    this.reverseAtEnd = true,
  }) : assert(pixelsPerSecond > 0, 'pixelsPerSecond must be > 0');

  AutoScrollSettings copyWith({
    double? pixelsPerSecond,
    bool? forward,
    bool? reverseAtEnd,
  }) {
    return AutoScrollSettings(
      pixelsPerSecond: pixelsPerSecond ?? this.pixelsPerSecond,
      forward: forward ?? this.forward,
      reverseAtEnd: reverseAtEnd ?? this.reverseAtEnd,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoScrollSettings &&
          other.pixelsPerSecond == pixelsPerSecond &&
          other.forward == forward &&
          other.reverseAtEnd == reverseAtEnd;

  @override
  int get hashCode => Object.hash(pixelsPerSecond, forward, reverseAtEnd);
}
