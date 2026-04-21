/// Auto Scroll library.
///
/// A drop-in auto-scroll solution for any Flutter [Scrollable] (ListView,
/// GridView, CustomScrollView, SingleChildScrollView, …).
///
/// - [AutoScrollController] drives the scroll programmatically at a
///   user-adjustable speed (pixels per second) using a [Ticker].
/// - [AutoScrollWrapper] wraps any scrollable and pauses auto-scroll while
///   the user is touching / holding the screen, resuming when they let go.
library auto_scroll;

export 'auto_scroll_controller.dart';
export 'auto_scroll_wrapper.dart';
export 'auto_scroll_settings.dart';
