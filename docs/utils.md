# Utils Module

Lower-level helpers from `codepan/utils/*` — plus a few cross-cutting classes that don't fit anywhere else. These are the small, reusable building blocks that show up everywhere in production code: file I/O, debouncing, search filtering, image caching, motion detection, etc.

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [`PanUtils`](#panutils-utilscodepan_utilsdart)
3. [`Debouncer`](#debouncer-utilsdebouncerdart)
4. [`Searchable` and `SearchHandlerMixin`](#searchable-and-searchhandlermixin-utilssearch_handlerdart)
5. [`CacheManager` and `CacheAsyncManager`](#cachemanager-and-cacheasyncmanager-utilscache_managerdart)
6. [`StoredNetworkImage`](#storednetworkimage-utilsstored_network_imagedart)
7. [`MotionDetector`](#motiondetector-utilsmotin_detectordart)
8. [Top-level Helpers](#top-level-helpers)

---

## File Registry

| File | Symbols | Purpose |
| :--- | :--- | :--- |
| `codepan/utils/codepan_utils.dart` | `PanUtils`, `printError`, `printPost`, `printLarge`, `range(min,max)`, `isDesktop`, `AddressAttribute` | Cross-cutting helpers: paths, geocoding, parsing, pickers. |
| `codepan/utils/debouncer.dart` | `Debouncer` | Coalesce rapid calls into a single delayed call. |
| `codepan/utils/search_handler.dart` | `Searchable`, `SearchHandlerMixin` | Mixin for `StatefulWidget` to add filterable search. |
| `codepan/utils/cache_manager.dart` | `CacheManager<K,V>`, `CacheAsyncManager<K,V>` | Lazy in-memory cache. |
| `codepan/utils/stored_network_image.dart` | `StoredNetworkImage` | `ImageProvider` that downloads + caches to disk with LRU eviction. |
| `codepan/utils/motin_detector.dart` | `MotionDetector` | Accelerometer-driven device-orientation watcher (note: filename keeps original spelling). |

---

## `PanUtils` (`utils/codepan_utils.dart`)

Static utilities used throughout codepan. Most projects need only a handful of these — the rest are quietly used by other modules.

### File system

| Method | Returns | Notes |
| :--- | :--- | :--- |
| `getAppDirectory()` | `Future<Directory>` | `getApplicationDocumentsDirectory()` on mobile, `getApplicationSupportDirectory()` on desktop. The DB lives under here. |
| `getFile({fileName, folder, folders})` | `Future<File>` | Auto-creates the folder chain if missing. |
| `getDirectory(folder)` | `Future<Directory>` | Same, for directories. |

```dart
final pdf = await PanUtils.getFile(
  fileName: 'invoice.pdf',
  folders: ['exports', '2026'],
);
```

### Networking

| Method | Notes |
| :--- | :--- |
| `hasInternet()` | True if any of wifi / mobile / ethernet is connected (uses `connectivity_plus`). |
| `isValidUrl(url)` | Regex check for `http(s)://...`. |
| `redirect(link)` | Launches in external app via `url_launcher`. Auto-prefixes `https://` if missing. |

### Parsing

| Method | Notes |
| :--- | :--- |
| `parseInt(input)` | `int` or `int.tryParse` against `toString()`. |
| `parseDouble(input)` | Same for double. |
| `parseBool(input)` | Accepts `bool`, `int (0/1)`, or `'true'/'yes'/'on'/'1'`. |
| `getPercentage(progress, max)` | `'45%'` (rounded). |

### Enums

| Method | Notes |
| :--- | :--- |
| `isEnum(data)` | Same logic as `dynamic.isEnum`. |
| `enumValue(data)` | Tail of `runtimeType.toString()` — i.e. the bare value. |

### Geolocation

| Method | Notes |
| :--- | :--- |
| `getCoordinatesFromAddress(address)` | Returns `latlong2.LatLng?`. Wraps geocoding `locationFromAddress`. |
| `getAddressFromCoordinates(lat, lng, {attrs})` | Returns the formatted address. `attrs` selects components: `street, subLocality, locality, administrativeArea, country`. |
| `getAddress(point, {attrs})` | Accepts `Position` (geolocator), `LatLng` (google_maps_flutter), or `latlong2.LatLng`. |
| `isLatLngValid(lat, lng)` | Bounds check `[-90,90]` × `[-180,180]`. |

### Date/time pickers

| Method | Notes |
| :--- | :--- |
| `showDatePicker(context, {initialDate})` | Returns `Time` (codepan's). Themed with `t.primaryColor` + `PanColors.text`. Range: ±100 years. |
| `showDateRangePicker(context, {initialDateRange})` | Returns `TimeRange`. Same theme. |

### Misc

| Method | Notes |
| :--- | :--- |
| `bindIsolatePort(sp, name)` | Registers `sp` under `name` via `IsolateNameServer`. Self-recovers if the name is taken. |
| `printError(error, stack)` | Single-line error log. |
| `printPost(url, params)` | Pretty-prints a request URL plus its JSON body. |
| `printLarge(text)` | Splits into 800-char chunks (workaround for `print` truncation on long strings). |

### Constants and getters

| Symbol | Value |
| :--- | :--- |
| `isDesktop` | `Platform.isWindows || isMacOS || isLinux`. |
| `century` | `Duration(days: 365 * 100)` — used as bounds in pickers. |
| `range(min, max)` | `List<int>` from min to max inclusive. |

### `AddressAttribute`

Enum used by `getAddressFromCoordinates`:

```dart
enum AddressAttribute {
  street, subLocality, locality, administrativeArea, country,
}
```

Pass `attrs: [AddressAttribute.locality, AddressAttribute.country]` for terse "City, Country" output.

---

## `Debouncer` (`utils/debouncer.dart`)

```dart
class Debouncer {
  final ValueChanged<bool>? statusNotifier;
  final int milliseconds;
  Debouncer({this.milliseconds = 500, this.statusNotifier});
  void run([VoidCallback? action]);
  void cancel();
}
```

Schedule an action; if `run` is called again before the timer fires, the prior action is cancelled. `statusNotifier` flips to `true` on first scheduling and `false` after firing — useful to drive a "saving…" indicator.

```dart
final debouncer = Debouncer(milliseconds: 400);
TextField(
  onChanged: (text) => debouncer.run(() => bloc.add(SearchChanged(text))),
);
```

Always call `debouncer.cancel()` from `dispose()` to avoid late callbacks on a defunct `State`.

---

## `Searchable` and `SearchHandlerMixin` (`utils/search_handler.dart`)

```dart
abstract class Searchable {
  List<String?> get searchable;
}

mixin SearchHandlerMixin<S extends StatefulWidget, M extends Searchable> on State<S> {
  List<M> get allItems;
  List<M> get items;          // suggestions when searching, otherwise allItems
  bool get showSuggestions;
  void onSearch(String text);
}
```

`MasterData` already implements `Searchable` (with `[name]`); override on your data classes to extend the search pool.

Apply the mixin to a stateful widget:

```dart
class _UsersPageState extends State<UsersPage>
    with SearchHandlerMixin<UsersPage, UserData> {
  List<UserData> _users = [];

  @override
  List<UserData> get allItems => _users;

  Widget _searchField() => PanTextField(
        hint: 'Search users',
        onChanged: onSearch,
      );

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          _searchField(),
          ...items.map((u) => UserTile(u)),
        ],
      );
}
```

The mixin debounces input by 500 ms via `Debouncer`. Behavior:

- Empty query ⇒ `items == allItems`.
- Non-empty query ⇒ `items == allItems.where((m) => any(m.searchable).contains(query))`.

`setState` is called automatically after each filter pass.

---

## `CacheManager` and `CacheAsyncManager` (`utils/cache_manager.dart`)

Tiny "create once, store forever" caches keyed by anything.

```dart
class CacheManager<K, V> {
  CacheManager({required Creator<K, V> creator});
  V getCached(K key);   // create if missing, return cached value
  V? get(K key);
  void add(K key, V value);
  void clear();
  bool contains(K key);
}

class CacheAsyncManager<K, V> {
  CacheAsyncManager({required AsyncCreator<K, V> creator});
  Future<V> getCached(K key);
  V? tryGet(K key, ValueChanged<V?> onCreated);  // sync return + later notification
  // ... same misc API
}
```

Use it for derived assets (decoded textstyles, color palettes, parsed templates):

```dart
final styleCache = CacheManager<int, TextStyle>(
  creator: (size) => TextStyle(fontSize: size.toDouble(), color: PanColors.text),
);

final s = styleCache.getCached(14);   // cached after the first call
```

`CacheAsyncManager.tryGet` returns the value immediately if cached, otherwise schedules the async creator and notifies via `onCreated`. Use it inside a `StatelessWidget` `build` when you want a synchronous return without `FutureBuilder`.

---

## `StoredNetworkImage` (`utils/stored_network_image.dart`)

A drop-in `ImageProvider` that caches network images to disk under a folder you choose, with size-bounded LRU-style eviction.

```dart
Image(
  image: StoredNetworkImage(
    'https://cdn.example.com/photos/abc.jpg',
    folder: 'profile',     // default 'StoredImages'
    fileLimit: 500,        // default 1000
    debouncer: _evictDebouncer,
  ),
);
```

Behavior:

- File name = `Uuid.v5(NAMESPACE_URL, imageUrl)` so the same URL always maps to the same file.
- Loads from disk if the file exists; otherwise fetches via `RetryClient(Client())` and saves.
- Each save schedules a `Debouncer.run` (if you provided one) that prunes the folder when it exceeds `fileLimit`.
- Logs total tile count and on-disk size on each prune.

This is what powers offline-tolerant image rendering across codepan-using apps.

---

## `MotionDetector` (`utils/motin_detector.dart`)

> Filename uses the original spelling `motin_detector.dart`; keep imports as-is.

Watches the accelerometer and notifies when device orientation changes:

```dart
final motion = MotionDetector(
  sensitivity: 0.5,                      // movement threshold (m/s²)
  allowanceTime: 300,                    // ms hysteresis
  onOrientationChanged: (orientation) {
    debugPrint('Now: $orientation');
  },
);
// ...
motion.close();   // remember to dispose
```

Maps acceleration vectors to `DeviceOrientation` values: `portraitUp`, `portraitDown`, `landscapeLeft`, `landscapeRight`. Used by photo-capture UIs that need to rotate overlays without enabling full Flutter orientation changes.

---

## Top-level Helpers

These are simple top-level constants/functions exported by `codepan/utils/codepan_utils.dart`:

| Symbol | Purpose |
| :--- | :--- |
| `range(min, max)` | Inclusive `List<int>`. |
| `isDesktop` | True on Windows/macOS/Linux. |
| `printError(err, stack)` | Compact error log. |
| `printPost(url, params)` | URL + indented JSON body. |
| `printLarge(text)` | Split-and-print long strings. |
| `century` | `Duration(days: 365 * 100)`. |
