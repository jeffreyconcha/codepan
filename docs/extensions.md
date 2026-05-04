# Extensions Module

How to use the Dart extension methods that codepan exposes from `codepan/extensions/*`. Most of these are quietly invoked across the library (e.g. `MapUtils.clean()` inside HTTP requests) and you'll want them in your own code too. They're the difference between idiomatic codepan code and verbose plumbing.

> Single import for everything: `import 'package:codepan/extensions/extensions.dart';` re-exports every file in this module.

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [`BuildContextUtils`](#buildcontextutils-extensionscontextdart)
3. [`MapUtils` and `MapStringUtils`](#maputils-and-mapstringutils-extensionsmapdart)
4. [`StringUtils`](#stringutils-extensionsstringdart)
5. [`ListUtils` and `MasterListUtils`](#listutils-and-masterlistutils-extensionslistdart)
6. [`DynamicUtils`](#dynamicutils-extensionsdynamicdart)
7. [`IntegerUtils`](#integerutils-extensionsintdart)
8. [`NumExt`](#numext-extensionsnumdart)
9. [`DoubleUtils`](#doubleutils-extensionsdoubledart)
10. [`DurationUtils`](#durationutils-extensionsdurationdart)
11. [`DirectoryUtils`](#directoryutils-extensionsdirectorydart)
12. [`FileSystemEntityUtils` and `ImageUtils`](#filesystementityutils-and-imageutils-extensionsfiledart)
13. [`CustomPainterUtils`](#custompainterutils-extensionspainterdart)
14. [`SendPortUtils`](#sendportutils-extensionsisolatedart)

---

## File Registry

| File | Extension targets | What it adds |
| :--- | :--- | :--- |
| `codepan/extensions/extensions.dart` | (barrel) | Re-exports all extensions. |
| `codepan/extensions/context.dart` | `BuildContext` | Navigation, keyboard, `blocOf<T>()`. |
| `codepan/extensions/map.dart` | `Map<String,dynamic>`, `Map` | Typed getters (`getInt`, `getBool`…), prefixing, `clean()`. |
| `codepan/extensions/string.dart` | `String` | Casing, parsing, color, formatting helpers. |
| `codepan/extensions/list.dart` | `List<T>`, `List<MasterData>` | `loop`, `transform`, `find`, `idList`, etc. |
| `codepan/extensions/dynamic.dart` | `dynamic` | Enum helpers (`enumValue`, `snake`, `toWords`). |
| `codepan/extensions/int.dart` | `int` | `toBool()`. |
| `codepan/extensions/num.dart` | `num` | `isBetween(a, b)`. |
| `codepan/extensions/double.dart` | `double` | Money / compact / generic formatting. |
| `codepan/extensions/duration.dart` | `Duration` | `format(...)`, `difference(...)`. |
| `codepan/extensions/directory.dart` | `Directory` | `file(name)`, `of(name)`. |
| `codepan/extensions/file.dart` | `FileSystemEntity`, `File` | Cropping, watermarking, compression, encoding. |
| `codepan/extensions/painter.dart` | `CustomPainter` | `renderImage(width:, height:)`. |
| `codepan/extensions/isolate.dart` | `SendPort` | `bindIsolate(name)`. |

---

## `BuildContextUtils` (`extensions/context.dart`)

```dart
extension BuildContextUtils on BuildContext {
  void popAllRoutes();
  void pop<T>([T? result]);
  void popUntil(RoutePredicate predicate);
  void push({required Widget page, ValueChanged<Object?>? onExit, RouteSettings? settings});
  void replace({required Widget page, Duration? duration, ValueChanged<Object?>? onExit, RouteSettings? settings});
  void fadeIn({required Widget page, Duration? duration, ValueChanged<Object?>? onExit, RouteSettings? settings});
  void slideToTop({required Widget page, Duration? duration, ValueChanged<Object?>? onExit, RouteSettings? settings});
  void hideKeyboard();
  T blocOf<T extends ParentBloc>();
}
```

| Method | Behavior | Notes |
| :--- | :--- | :--- |
| `pop([result])` | Calls `Navigator.of(this).pop(result)` if it can. | Safe to call even if there's nothing to pop. |
| `popAllRoutes()` | Pops every route until empty. | Useful before a hard logout. |
| `popUntil(pred)` | Standard `Navigator.popUntil`. | |
| `push({page})` | Pushes a `CupertinoPageRoute`. | `onExit(value)` runs after the route closes with `value`. |
| `replace({page})` | Pushes via `FadeRoute` and replaces. | Default 250 ms. |
| `fadeIn({page})` | Same `FadeRoute`, but `push` (modal). | Use for overlays. |
| `slideToTop({page})` | `BottomModalRoute` slide-up. | Use for bottom sheets. |
| `hideKeyboard()` | `FocusScope.of(this).unfocus()`. | |
| `blocOf<T>()` | `BlocProvider.of<T>(this)` typed against `ParentBloc`. | The standard way to read blocs in this codebase — see [bloc.md](./bloc.md). |

```dart
context.push(page: ProfilePage(userId: 1), onExit: (refresh) {
  if (refresh == true) context.blocOf<HomeBloc>().add(const RefreshHome());
});
```

---

## `MapUtils` and `MapStringUtils` (`extensions/map.dart`)

This is the single most important extension for parsing JSON. It powers every `fromJson` factory in the project.

### Typed getters

| Method | Returns | Behavior |
| :--- | :--- | :--- |
| `getInt(key)` | `int?` | Parses int from string/int. |
| `getDouble(key)` | `double?` | Parses double. |
| `getBool(key)` | `bool?` | Accepts `true/false`, `"yes"/"no"`, `"1"/"0"`. |
| `getList<T>(key)` | `List<T>?` | Casts each element. |
| `getEnum<T>({key, values})` | `T?` | Matches against an enum's snake-case name. |
| `get(key)` | `dynamic` | Trims strings, parses bool when key starts with `is`/`has`/`with`/`did`/`can`, returns raw value otherwise. |

### Optional getters (try multiple keys)

| Method | Returns | Behavior |
| :--- | :--- | :--- |
| `optInt(keys)` | `int?` | First key whose value parses to int. |
| `optDouble(keys)` | `double?` | Same for double. |
| `optBool(keys)` | `bool?` | Same for bool. |
| `optList<T>(keys)` | `List<T>?` | Same for list. |
| `opt(keys)` | `dynamic` | First non-null value across keys. |

### Prefixing

For prefixed JSON, set a prefix once and read non-prefixed keys:

```dart
json.setPrefix('user', separator: '_');
final id = json.getInt('id');     // reads 'user_id'
final name = json.get('name');     // reads 'user_name'

// Fallback prefixes — try with prefix first, then without (or another prefix).
json.setPrefixFallback(['employee', 'staff']);
```

| Method | Behavior |
| :--- | :--- |
| `setPrefix(prefix, {index, separator='.'})` | Stash a prefix on the map; subsequent `get*` calls auto-prepend it. |
| `addPrefix(additional)` | Append to the existing prefix (e.g. for join indices). |
| `setPrefixFallback(prefix, {separator})` | Comma-separated list of prefixes to try if the primary fails. |

### Other

| Method | Behavior |
| :--- | :--- |
| `hasKey(key)` | Honors the active prefix/fallback. |
| `hasKeyWithValue(key)` | Same, but also requires the value to be non-null. |
| `isNull(key)` / `isNotNull(key)` | Respect the prefixing logic. |
| `getValue(key)` | Raw value with prefix applied (no parsing). |
| `getKey(key)` | The actual key string after prefixing. |
| `copy()` | Shallow `Map.of(this)`. |
| `asyncLoop(fn)` | `for-await` over entries. |

### `MapStringUtils.clean()`

```dart
extension MapStringUtils on Map {
  void clean() => removeWhere((k, v) => v == null);
}
```

`SqliteBinder.insertData`, `GetRequest.params`, and `TransmitRequest.params` all call `clean()` automatically. Call it manually whenever you build a request map yourself.

---

## `StringUtils` (`extensions/string.dart`)

Heavily used by the codepan widgets (color parsing, casing, search). Highlights:

| Method/Getter | Result |
| :--- | :--- |
| `getInitials([max=2])` | `'Jeff Concha'.getInitials() → 'JC'`. |
| `equalsIgnoreCase(other)` | Case-insensitive equality. |
| `equalsIgnoringWordOrder(other)` | Compare normalized (sorted) words. |
| `normalized` | Whitespace-collapsed, words sorted alphabetically. |
| `capitalize([isSentence])` | Title-case (excluding `of/and/or/is/are/a/with`) by default. |
| `decapitalize()` | Lowercases the first character. |
| `nullify()` | `'' / 'null' → null`, otherwise self. |
| `complete(input, {identifier='\$', withQuotes, isSpannable})` | Replace `$` placeholders in the string with one or more values. Used by `Errors.failedToLoad$.complete(Strings.users)`. |
| `toSnake()` / `toPlural()` / `toSingular()` | Inflection helpers. |
| `noun(qty)` / `verb(qty)` | Singular vs plural based on quantity. |
| `toBool()` | `'true'/'yes'/'on'/'1'` → `true`; `'false'/'no'/'off'/'0'` → `false`. |
| `count(separator)` | Number of separators in the string. |
| `hideCharAt({index, count, replacement='*'})` | Mask part of a string — useful for credit-card / phone display. |
| `alphaNumeric` / `alphabets` / `numbers` / `decimalNumbers` | Strip non-matching characters. |
| `hasLetters` / `hasNumbers` / `hasSymbols` | Booleans. |
| `containsKeys(list)` | Case-insensitive substring match against any key. |
| `last` | Last character (or `''`). |
| `unescaped` | HTML-decoded plus a few common escape fixes. |
| `hexColor` | `'#FF8800'.hexColor` → `Color`. Supports 6- and 8-char hex. |
| `isPhoneNumber` / `isNumeric` | Heuristics. |
| `toMultiline(maxLength)` | Word-wrap to lines no wider than `maxLength`. |

```dart
final greeting = 'Failed to load $'.complete('users', withQuotes: true);
// → 'Failed to load "users"'
```

---

## `ListUtils` and `MasterListUtils` (`extensions/list.dart`)

```dart
extension ListUtils<T> on List<T>
extension MasterListUtils<T extends MasterData> on List<T>
```

| Method | Behavior |
| :--- | :--- |
| `loop((item, index) {})` | Indexed forEach. |
| `asyncLoop(action)` | `for-await` indexed. |
| `transform<N>((item, idx) => …)` | Map with implicit `null` filtering. Optional `sort: true`. |
| `unevenTransform<N>(...)` | Same but flattens results that are themselves `List<N>`. |
| `asyncTransform<N>(...)` | Async version. |
| `find(test)` | First element matching predicate, or `null`. |
| `max(validator)` / `min(validator)` | Element with max/min `num` according to `validator`. |
| `addIfAbsent(element)` | No-op if already present. |
| `update(element)` | Replace the existing element using `indexOf`. |
| `replace(element)` | Same as `update` but checks `contains` first. |
| `maxOf(length)` | Sublist of first `length` items. |
| `text` / `toText([sep=', '])` | Join — `MasterData.name` for masters; `toString()` otherwise. |
| `idList` (for `List<TransactionData>`) | List of non-null `id`s. |
| `toCachedMap<K>(identifier)` (for `List<MasterData>`) | Build `Map<K, T>` keyed by `identifier(item)`. |

```dart
items.loop((item, i) => print('$i: ${item.name}'));

final names = users.transform<String>((u, _) => u.name);
final ids = users.idList;
final byEmail = users.toCachedMap<String>((u) => u.email);
```

---

## `DynamicUtils` (`extensions/dynamic.dart`)

Mostly for working with enum values:

| Member | Behavior |
| :--- | :--- |
| `isEnum` | Tests `data.toString().split('.').length == 2 && parts[0] == runtimeType`. |
| `enumValue` | `MyEnum.foo.enumValue → 'foo'`. |
| `snake` | `MyEnum.fooBar.snake → 'foo_bar'`. |
| `toWords({allCaps=false, separator=' '})` | `'foo_bar' → 'foo bar'` or `'FOO BAR'`. |
| `toCapitalizedWords()` | `'fooBar' → 'Foo Bar'`. |

```dart
print(JoinType.left.toWords(allCaps: true));   // 'LEFT'
```

---

## `IntegerUtils` (`extensions/int.dart`)

```dart
extension IntegerUtils on int {
  bool toBool() => this == 1;
}
```

`SqliteStatement` stores `bool` as `1`/`0`; this is how you read it back.

---

## `NumExt` (`extensions/num.dart`)

```dart
extension NumExt on num {
  bool isBetween(num start, num end);
}
```

Inclusive bounds, order-agnostic — `5.isBetween(10, 1) == true`.

---

## `DoubleUtils` (`extensions/double.dart`)

| Method | Result |
| :--- | :--- |
| `toMoneyFormat([currencyCode])` | `1234.5.toMoneyFormat('USD') → '$1,234.50'`. |
| `toCompact([decimalDigits=0])` | `1500000.toCompact() → '$2M'` (currency-prefixed). |
| `format([decimalDigits=2, alwaysWithDecimal=false])` | Locale-aware. Drops decimals when whole. |

---

## `DurationUtils` (`extensions/duration.dart`)

```dart
String format({bool isReadable=false, bool withSeconds=true, bool isAbbreviated=false});
Duration difference(Duration other);
```

```dart
const Duration(hours: 2, minutes: 5).format();                         // '02:05:00'
const Duration(hours: 2, minutes: 5).format(isReadable: true);         // '2 hrs 5 mins'
const Duration(hours: 2, minutes: 5).format(isAbbreviated: true);      // '2h 5m'
```

---

## `DirectoryUtils` (`extensions/directory.dart`)

Used internally by `PanUtils.getFile`/`getDirectory`. Fluent file/directory composition:

```dart
final root = await PanUtils.getAppDirectory();
final file = root.of('photos').file('today.jpg');   // Directory + nested File
```

---

## `FileSystemEntityUtils` and `ImageUtils` (`extensions/file.dart`)

`FileSystemEntity.name` returns just the basename.

`ImageUtils on File` — image processing (uses `package:image` and `package:image_compression`):

| Method | Behavior |
| :--- | :--- |
| `cropImage({preferredWidth, preferredHeight})` | Center-crop to the given aspect ratio; writes JPEG back. |
| `stampImage({builder, context})` | Render a `CustomPainter` watermark at the image's resolution and overlay it. Honors EXIF rotation. |
| `getRotatedImage()` | Decode + bake EXIF rotation. |
| `jpegData` / `pngData` | Re-encoded bytes after orientation baking. |
| `compressImage({quality=90})` | In-place JPEG compression. |
| `appendImage({attachment})` | Stitch another image vertically below the source. |

These are the helpers behind codepan's `MediaData` upload flow.

---

## `CustomPainterUtils` (`extensions/painter.dart`)

```dart
extension CustomPainterUtils on CustomPainter {
  Future<ui.Image> renderImage({required int width, required int height});
}
```

Render a painter to an offscreen `ui.Image`. Used by `File.stampImage` to build watermarks.

---

## `SendPortUtils` (`extensions/isolate.dart`)

```dart
extension SendPortUtils on SendPort {
  void bindIsolate(String name);
}
```

Registers the port under `name` via `IsolateNameServer`. If a port is already bound to that name, it's removed and the new one takes its place. Used by codepan's `IsolateHandler` and by your own background-isolate plumbing — see [misc.md](./misc.md#isolate).
