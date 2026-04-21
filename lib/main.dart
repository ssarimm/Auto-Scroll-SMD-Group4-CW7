import 'package:flutter/material.dart';

import 'auto_scroll/auto_scroll.dart';

void main() => runApp(const AutoScrollApp());

class AutoScrollApp extends StatelessWidget {
  const AutoScrollApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Scroll Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scroll;
  late final AutoScrollController _auto;
  double _speed = 60.0;

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _auto = AutoScrollController(
      scrollController: _scroll,
      vsync: this,
      settings: AutoScrollSettings(pixelsPerSecond: _speed),
    );
  }

  @override
  void dispose() {
    _auto.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Scroll Demo'),
        backgroundColor: scheme.inversePrimary,
      ),
      body: Column(
        children: [
          _SpeedControl(
            speed: _speed,
            onChanged: (v) {
              setState(() => _speed = v);
              _auto.setSpeed(v);
            },
          ),
          _DirectionRow(controller: _auto),
          const Divider(height: 1),
          _StatusBanner(controller: _auto),
          Expanded(
            child: AutoScrollWrapper(
              controller: _auto,
              child: ListView.builder(
                controller: _scroll,
                itemCount: 500,
                itemBuilder: (_, i) {
                  final color =
                      Colors.primaries[i % Colors.primaries.length].shade200;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color,
                      child: Text('$i'),
                    ),
                    title: Text('List item #$i'),
                    subtitle: Text(
                      'Item $i — hold the screen to pause, release to resume.',
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _auto.isRunningListenable,
        builder: (_, running, __) => FloatingActionButton.extended(
          onPressed: _auto.toggle,
          icon: Icon(running ? Icons.pause : Icons.play_arrow),
          label: Text(running ? 'Pause' : 'Start'),
        ),
      ),
    );
  }
}

class _SpeedControl extends StatelessWidget {
  const _SpeedControl({required this.speed, required this.onChanged});

  final double speed;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.speed),
          const SizedBox(width: 8),
          const Text('Speed'),
          Expanded(
            child: Slider(
              value: speed,
              min: 10,
              max: 400,
              divisions: 39,
              label: '${speed.toInt()} px/s',
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${speed.toInt()} px/s',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionRow extends StatelessWidget {
  const _DirectionRow({required this.controller});

  final AutoScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ValueListenableBuilder<AutoScrollSettings>(
        valueListenable: controller.settingsListenable,
        builder: (_, s, __) => Row(
          children: [
            FilterChip(
              label: Text(s.forward ? 'Direction ↓' : 'Direction ↑'),
              selected: true,
              onSelected: (_) => controller.setForward(!s.forward),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Bounce at end'),
              selected: s.reverseAtEnd,
              onSelected: (v) =>
                  controller.updateSettings(s.copyWith(reverseAtEnd: v)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.controller});

  final AutoScrollController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isPausedListenable,
      builder: (_, paused, __) => ValueListenableBuilder<bool>(
        valueListenable: controller.isRunningListenable,
        builder: (_, running, __) {
          String text;
          Color bg;
          IconData icon;
          if (paused) {
            text = 'Paused — release to resume';
            bg = Colors.orange.shade100;
            icon = Icons.pan_tool;
          } else if (running) {
            text = 'Scrolling — tap and hold to pause';
            bg = Colors.green.shade100;
            icon = Icons.play_arrow;
          } else {
            text = 'Stopped — press Start';
            bg = Colors.grey.shade200;
            icon = Icons.stop;
          }
          return Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: bg,
            child: Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(text),
              ],
            ),
          );
        },
      ),
    );
  }
}
