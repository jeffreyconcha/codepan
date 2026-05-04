# Misc Modules

Smaller, focused modules under codepan that don't warrant their own document but ship important capabilities: storage (`SharedPreferencesManager`), security (`KeyManager`), isolates (`IsolateHandler`), route transitions, time (`Time`, `TimeRange`, `PeriodicTimer`), media typedefs, and resources.

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [Storage — `SharedPreferencesManager`](#storage--sharedpreferencesmanager)
3. [Security — `KeyManager`](#security--keymanager)
4. [Isolate — `IsolateHandler`, `MainPort`](#isolate--isolatehandler-mainport)
5. [Transitions — `SlideRoute`, `FadeRoute`, `BottomModalRoute`](#transitions--sliderotate-faderoute-bottommodalroute)
6. [Time — `Time`, `TimeRange`, `TimePeriod`](#time--time-timerange-timeperiod)
7. [Periodic Timer — `PeriodicTimer`](#periodic-timer--periodictimer)
8. [Media Typedefs](#media-typedefs)
9. [Resources — `Strings` and Color Palette](#resources--strings-and-color-palette)

---

## File Registry

| File | Symbols | Purpose |
| :--- | :--- | :--- |
| `codepan/storage/shared_preferences.dart` | `SharedPreferencesManager` | Typed wrapper around `shared_preferences`. |
| `codepan/security/key_manager.dart` | `KeyManager`, `ByteLengthChecker` | AES-GCM encrypt/decrypt with seed-derived keys. |
| `codepan/isolate/isolate_handler.dart` | `IsolateHandler`, `MainPort`, `IsolateRunner`, `PortCreator` | Background isolate with bidirectional ports. |
| `codepan/transitions/route_transition.dart` | `SlideRoute`, `FadeRoute`, `BottomModalRoute` | Custom `PageRouteBuilder`s. |
| `codepan/time/time.dart` | `Time`, `defaultDate`, `defaultTime`, `dateFormat`, `timeFormat` | Date/time wrapper with formatting and arithmetic. |
| `codepan/time/time_range.dart` | `TimeRange`, `TimePeriod`, `TimePeriodExt` | Date range + canned period (today, this week, etc.). |
| `codepan/time/periodic_timer.dart` | `PeriodicTimer` | Timer with start/stop/reset and a tick counter. |
| `codepan/media/media.dart` | `OnProgressChanged`, `OnCompleted`, `OnError`, `invalidArgument` | Shared typedefs for audio/video player widgets. |
| `codepan/resources/colors.dart` | `PanColors` | Neutral palette (also covered in widgets.md). |
| `codepan/resources/dimensions.dart` | `Dimension` | Responsive sizing (also covered in widgets.md). |
| `codepan/resources/strings.dart` | `Strings`, `Errors`, `PermissionInfo`, `PermissionName`, `PermissionValue` | Localizable user-facing strings. |

---

## Storage — `SharedPreferencesManager`

Light wrapper around `shared_preferences` that handles type coercion and bulk-write.

```dart
final prefs = await SharedPreferencesManager.create();

prefs.set(key: 'token', value: 'abc.def.ghi');
prefs.set(key: 'isLoggedIn', value: true);
prefs.set(key: 'tags', value: <String>['a', 'b']);

final token = prefs.get<String>('token');
final isOn = prefs.get<bool>('isLoggedIn');

prefs.setAll({
  'authority': 'api.example.com',
  'apiPath': '/v2',
});

final mode = prefs.getEnum<ThemeMode>(key: 'mode', values: ThemeMode.values);
```

Behavior:

- `set<T>` dispatches on runtime type: `int`, `bool`, `double`, `String`, `List<String>`, plus enums (stored as capitalized words).
- `get<T>(key)` returns `null` if missing or type doesn't match.
- `getEnum<T>` matches by snake-case comparison so any string variant works.
- The underlying `SharedPreferences` instance is exposed via `prefs.prefs`.

Use it for small flags and tokens. For anything sensitive (auth tokens, session keys), prefer encrypting via `KeyManager` first.

---

## Security — `KeyManager`

AES-GCM (256-bit) encryption with a key derived from a seed string. Use it to protect tokens, secrets, and sensitive payloads stored in `SharedPreferences` or files.

```dart
final manager = KeyManager('my-app-secret-seed');

final cipherText = await manager.encrypt('hello world');
final mac = base64.encode(/* derive from secret box, see source */);

// Decrypt:
final plain = await manager.decrypt(text: cipherText, mac: mac);

// Or from raw byte arrays:
final plain2 = await manager.decryptBytes(text: cipherBytes, mac: macBytes);
```

Notes:

- Key material is `sha256(seed.utf8)`; nonce/IV is the same digest truncated to 12 bytes.
- The cipher is `AesGcm.with256bits()` from `package:cryptography`.
- `manager.prepare(input)` produces a constant-line, alternating-byte literal you can paste into source code as a hardcoded seed (used by codepan's app-bootstrap layer).
- Two factories: `KeyManager(seed)` and `KeyManager.fromBytes(bytes)`.

Pair with `SharedPreferencesManager`:

```dart
final encToken = await keys.encrypt(token);
prefs.set(key: 'token', value: encToken);
```

> Always pair seeds with secure delivery (build-time obfuscation, native-side storage, hardware-backed keystore). `KeyManager` is the encrypt/decrypt primitive — not a key-distribution mechanism.

---

## Isolate — `IsolateHandler`, `MainPort`

Spawn a background isolate with two-way messaging.

```dart
class SyncMainPort extends MainPort {
  final SqliteAdapter db;
  const SyncMainPort({required super.msp, required this.db});
}

void _runner(SyncMainPort port) {
  final irp = ReceivePort();
  port.send(irp.sendPort);   // hand the inbound port back to main
  irp.listen((msg) {
    // do work, then port.send(...) results back
  });
}

class SyncHandler extends IsolateHandler<SyncMainPort> {
  SyncHandler({required super.creator})
      : super(name: 'sync', onConnected: (sp) {});

  @override IsolateRunner<SyncMainPort> get runner => _runner;

  @override
  void receiveFromIsolate(dynamic data) {
    // handle results that came back on the main isolate's ReceivePort
  }
}

// Bootstrap:
final handler = SyncHandler(
  creator: (msp) async => SyncMainPort(msp: msp, db: db),
);
await handler.start();
handler.sendToIsolate({'op': 'pull', 'page': 1});
```

Key points:

- The handler creates its own `ReceivePort` (`_mrp`); when the isolate sends `SendPort` first, that port is stored as `_isp` for outbound messages.
- `bindPort(sp)` (or `sp.bindIsolate(name)` from extensions) lets multiple isolates discover the same port via `IsolateNameServer`.
- `stop()` kills the isolate.
- `IsolateRunner<T>` and `PortCreator<T>` are typedefs for `void Function(T)` and `Future<T> Function(SendPort)` respectively.

---

## Transitions — `SlideRoute`, `FadeRoute`, `BottomModalRoute`

Custom `PageRouteBuilder`s. Use them via the `BuildContext` extension methods (`context.push`, `context.replace`, `context.fadeIn`, `context.slideToTop`) — see [extensions.md](./extensions.md).

| Class | Effect | Default duration |
| :--- | :--- | :--- |
| `SlideRoute` | Two-way horizontal slide (exit slides left, enter slides right). | 250 ms |
| `FadeRoute` | Fade-in over translucent black barrier. | 250 ms |
| `BottomModalRoute` | Slide up from bottom + dimmed barrier. | 250 ms |

```dart
Navigator.of(context).push(SlideRoute(
  enter: NextPage(),
  exit: this.widget,
  duration: const Duration(milliseconds: 350),
));
```

Most code should not instantiate these directly — `context.push/replace/fadeIn/slideToTop` are the conventional entry points.

---

## Time — `Time`, `TimeRange`, `TimePeriod`

`Time` is codepan's date/time wrapper. It separates **date** (`yyyy-MM-dd`) and **time** (`HH:mm:ss`) strings, exposes a `DateTime` via `value`, and has a fleet of display getters.

```dart
final t = Time.now();          // current time
final t2 = Time.today();       // today at 00:00
final t3 = Time(date: '2026-05-04', time: '13:00:00');
final t4 = Time.value(DateTime.now());

t.date;             // '2026-05-04'
t.time;             // '13:00:00'
t.value;            // DateTime
t.milliseconds;
t.display;          // 'May 4, 2026, 1:00 PM'
t.displayDate;      // 'May 4, 2026'
t.displayWeekday;   // 'Monday'  (or 'Today')
t.displayMonth;
t.displayMonthYear;
t.displayNumeric;   // '5/4/26 - 1:00 PM'

t.isToday;
t.isYesterday;
t.isBetween(other);
t.toMonth();        // beginning to end of this month → TimeRange
```

`Time` is `Equatable` keyed on `milliseconds`. Treat it as immutable; mutate via `add(Duration)` / `subtract(Duration)`.

### `TimeRange`

```dart
final range = TimeRange(start: Time.today(), end: Time.now());
range.start;
range.end;
range.displayDate;       // 'May 1 - 4, 2026'
range.includes(time);
```

Convenience constructors: `TimeRange.today()`, `TimeRange.value(DateTimeRange?)`, etc.

### `TimePeriod`

Canned ranges that pair well with reports/filters:

```dart
enum TimePeriod {
  today, yesterday,
  thisWeek, thisMonth, monthToDate,
  lastWeek, lastMonth,
  last7Days, last30Days, last3Months, last6Months,
  thisYear, yearToDate,
  fromTheBeginning, custom,
}
```

`TimePeriodExt.title` returns the localized name. Build a menu with codepan's `MenuDialog<TimePeriod>` and convert the selection to a `TimeRange`:

```dart
TimeRange rangeFor(TimePeriod p) {
  switch (p) {
    case TimePeriod.today: return TimeRange.today();
    case TimePeriod.thisWeek: return TimeRange.thisWeek();
    // ...
    case TimePeriod.custom: return /* custom picker result */;
  }
}
```

---

## Periodic Timer — `PeriodicTimer`

```dart
final timer = PeriodicTimer(
  interval: const Duration(seconds: 1),
  runner: (timer) => print('tick'),
  autoStart: true,
);

timer.tick;     // current tick count (0 on start)
timer.isActive;
timer.time;     // Time when it was created
timer.stop();
timer.start();
timer.reset();  // tick = 0; restarts unless `autoStart=false`
```

Use it for periodic refreshes, lightweight clocks, or a "we still have work to do" heartbeat. It's `Timer.periodic` with a tick counter and re-enter safety.

---

## Media Typedefs

Located in `codepan/media/media.dart`:

```dart
typedef OnProgressChanged = void Function(double current, double max);
typedef OnCompleted = void Function();
typedef OnError = void Function(String error);

const invalidArgument = 'Data can only be a type of String(url) or File';
```

These are reused by `AudioPlayer`, `VideoPlayer`, and `MediaProgressIndicator` so that callers can consume any of them with the same callback shape. Pass `OnProgressChanged` to bind UI to playback position; `OnCompleted` for end-of-media; `OnError` for failure handling.

---

## Resources — `Strings` and Color Palette

`codepan/resources/strings.dart` exposes:

- **`Strings`** — common labels (`Strings.today`, `Strings.loading`, `Strings.users`, etc.). Use these in dialogs/buttons rather than hard-coding.
- **`Errors`** — common error templates: `Errors.unableToConnectToServer`, `Errors.requestTimedOut`, `Errors.failedToLoad$`, `Errors.failedToCreate$`, `Errors.failedToDownload$`. The `$` is a placeholder substituted via `String.complete(...)`:

  ```dart
  Errors.failedToLoad$.complete(Strings.users);
  // → 'Failed to load users'
  Errors.failedToLoad$.complete(Strings.user, withQuotes: true);
  // → 'Failed to load "user"'
  ```

- **`PermissionInfo`** — title + message used by `PermissionState` disclosures.
- **`PermissionName`** / **`PermissionValue`** — the localized name for each permission and its `Permission.value` integer.

Project-specific strings should live in your project's `lib/resources/strings.dart` (or i18n bundle) — keep `codepan`'s strings for the cross-cutting messages it produces internally.

For color and dimension reference, see [widgets.md](./widgets.md#resources--dimension-pancolors).
