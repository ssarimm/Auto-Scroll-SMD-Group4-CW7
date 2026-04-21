import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_scroll_demo/auto_scroll/auto_scroll.dart';

class _TP extends StatefulWidget {
  const _TP({required this.onReady});
  final void Function(TickerProvider) onReady;
  @override
  State<_TP> createState() => _TPState();
}

class _TPState extends State<_TP> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onReady(this));
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  testWidgets('AutoScrollSettings copyWith + equality', (tester) async {
    const a = AutoScrollSettings(pixelsPerSecond: 60);
    final b = a.copyWith(pixelsPerSecond: 120);
    expect(a == b, isFalse);
    expect(b.pixelsPerSecond, 120);
    expect(a.copyWith() == a, isTrue);
  });

  testWidgets('start / stop / toggle flip running state', (tester) async {
    TickerProvider? tp;
    await tester.pumpWidget(_TP(onReady: (t) => tp = t));
    await tester.pump();
    final scroll = ScrollController();
    final auto = AutoScrollController(scrollController: scroll, vsync: tp!);

    expect(auto.isRunning, isFalse);
    auto.start();
    expect(auto.isRunning, isTrue);
    auto.stop();
    expect(auto.isRunning, isFalse);
    auto.toggle();
    expect(auto.isRunning, isTrue);

    auto.dispose();
    scroll.dispose();
  });

  testWidgets('stop(resumable: true) → paused; resume restarts', (tester) async {
    TickerProvider? tp;
    await tester.pumpWidget(_TP(onReady: (t) => tp = t));
    await tester.pump();
    final scroll = ScrollController();
    final auto = AutoScrollController(scrollController: scroll, vsync: tp!);

    auto.start();
    auto.stop(resumable: true);
    expect(auto.isRunning, isFalse);
    expect(auto.isPaused, isTrue);
    auto.resume();
    expect(auto.isRunning, isTrue);
    expect(auto.isPaused, isFalse);

    auto.dispose();
    scroll.dispose();
  });

  testWidgets('AutoScrollWrapper pauses on pointer down, resumes on up',
      (tester) async {
    TickerProvider? tp;
    await tester.pumpWidget(_TP(onReady: (t) => tp = t));
    await tester.pump();
    final scroll = ScrollController();
    final auto = AutoScrollController(scrollController: scroll, vsync: tp!);
    auto.start();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AutoScrollWrapper(
            controller: auto,
            child: ListView.builder(
              controller: scroll,
              itemCount: 20,
              itemBuilder: (_, i) => SizedBox(height: 40, child: Text('$i')),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Press down — should pause.
    final gesture = await tester.startGesture(const Offset(100, 100));
    await tester.pump();
    expect(auto.isPaused, isTrue, reason: 'pointer down should pause');
    expect(auto.isRunning, isFalse);

    // Release — should resume.
    await gesture.up();
    await tester.pump();
    expect(auto.isRunning, isTrue, reason: 'pointer up should resume');
    expect(auto.isPaused, isFalse);

    auto.dispose();
    scroll.dispose();
  });
}
