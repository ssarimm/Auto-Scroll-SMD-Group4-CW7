# Auto Scroll Demo

A Flutter app and reusable library (`lib/auto_scroll/`) that adds **auto-scroll to any list** with:

- 🎛️ **User-adjustable speed** (10–400 pixels per second)
- ⏸️ **Pause on touch / hold** — scrolling stops while any finger is on the screen
- ▶️ **Auto-resume on release** — lift your finger and it continues
- ↕️ Direction toggle + bounce-at-end option
- 🧩 Drop-in: wrap any `ListView` / `GridView` / `CustomScrollView`

## Project Layout

```
auto_scroll_demo/
├── lib/
│   ├── main.dart                  ← Demo app
│   └── auto_scroll/               ← The reusable library
│       ├── auto_scroll.dart
│       ├── auto_scroll_controller.dart
│       ├── auto_scroll_wrapper.dart
│       └── auto_scroll_settings.dart
├── test/
│   └── auto_scroll_test.dart
├── android/                       ← Android Studio project
└── pubspec.yaml
```

## How to Run in Android Studio

### 1. Prerequisites

- **Android Studio** (Hedgehog 2023.1.1 or newer recommended)
- **Flutter SDK** (3.10 or newer) — install from https://flutter.dev
- The **Flutter plugin** for Android Studio (Preferences → Plugins → search "Flutter")

### 2. First-time setup

1. **Unzip** the project and open the folder `auto_scroll_demo/` in Android Studio.
2. **Create `android/local.properties`** with two lines pointing to your local Flutter and Android SDK installations:

   ```properties
   flutter.sdk=/absolute/path/to/your/flutter
   sdk.dir=/absolute/path/to/your/Android/sdk
   ```

   On Windows use forward slashes or escaped backslashes, e.g. `C:/dev/flutter`.

   > Android Studio's Flutter plugin will offer to auto-generate this file the first time you open the project — you can just accept that prompt instead of writing it yourself.

3. In the terminal (inside Android Studio or externally), run:

   ```bash
   flutter pub get
   ```

4. Plug in an Android device (or start an emulator) and press the green **▶ Run** button, or run:

   ```bash
   flutter run
   ```

### 3. Using the app

- Move the **speed slider** to change scroll speed (10–400 px/s).
- Press **Start** to begin auto-scrolling.
- **Touch and hold** anywhere on the list — scrolling pauses.
- **Release** — scrolling resumes automatically.
- Toggle **Direction ↓/↑** to flip scroll direction.
- Toggle **Bounce at end** to choose between "reverse at end" and "stop at end".

## Using the Library in Your Own App

Copy the `lib/auto_scroll/` folder into your project, then:

```dart
import 'auto_scroll/auto_scroll.dart';

class MyPage extends StatefulWidget {
  @override State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  late final _auto = AutoScrollController(
    scrollController: _scroll,
    vsync: this,
    settings: const AutoScrollSettings(pixelsPerSecond: 80),
  );

  @override
  void dispose() {
    _auto.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AutoScrollWrapper(
      controller: _auto,
      child: ListView.builder(
        controller: _scroll,
        itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
      ),
    );
  }
}
```

To change speed at runtime:

```dart
_auto.setSpeed(120);   // px per second
_auto.start();
_auto.stop();
_auto.toggle();
```

## Running Tests

```bash
flutter test
```

## License

MIT — see `LICENSE`.
