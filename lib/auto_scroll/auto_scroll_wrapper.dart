import 'package:flutter/widgets.dart';

import 'auto_scroll_controller.dart';

/// Wraps any scrollable child and pauses auto-scroll while the user is
/// touching the screen. When the user releases, auto-scroll resumes.
///
/// ```dart
/// AutoScrollWrapper(
///   controller: _auto,
///   child: ListView.builder(
///     controller: _auto.scrollController,
///     itemBuilder: (ctx, i) => ListTile(title: Text('$i')),
///   ),
/// )
/// ```
///
/// Implementation notes:
/// - Uses a [Listener] with [HitTestBehavior.translucent] so the scrollable
///   underneath still receives all gestures (tap, drag, etc.). The listener
///   only observes pointer events; it does not consume them.
/// - Tracks active pointers so multi-finger touches don't prematurely resume.
class AutoScrollWrapper extends StatefulWidget {
  const AutoScrollWrapper({
    super.key,
    required this.controller,
    required this.child,
    this.pauseOnHold = true,
  });

  final AutoScrollController controller;
  final Widget child;

  /// When true (default), auto-scroll pauses while a finger is on the screen
  /// and resumes when the last finger lifts. When false, behaves passively.
  final bool pauseOnHold;

  @override
  State<AutoScrollWrapper> createState() => _AutoScrollWrapperState();
}

class _AutoScrollWrapperState extends State<AutoScrollWrapper> {
  int _activePointers = 0;

  void _handlePointerDown(PointerDownEvent _) {
    if (!widget.pauseOnHold) return;
    _activePointers++;
    if (_activePointers == 1 && widget.controller.isRunning) {
      // Mark as resumable so the UI knows it was a user-pause, not a toggle.
      widget.controller.stop(resumable: true);
    }
  }

  void _handlePointerUp(PointerEvent _) {
    if (!widget.pauseOnHold) return;
    if (_activePointers > 0) _activePointers--;
    if (_activePointers == 0 && widget.controller.isPaused) {
      widget.controller.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerUp: _handlePointerUp,
      onPointerCancel: _handlePointerUp,
      child: widget.child,
    );
  }
}
