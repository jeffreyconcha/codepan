# Widgets Module

Reusable UI building blocks under `codepan/widgets/*` plus shared resources (`Dimension`, `PanColors`). Use these in every codepan-backed project. Custom widgets should compose codepan widgets first; only drop down to raw Flutter widgets when none of these fit.

> Two **mandatory** rules across every codepan UI:
>
> 1. **Use `Dimension`** (`final d = Dimension.of(context);`) and call `d.at(value)` everywhere instead of bare doubles.
> 2. **Use `PanText` / `PanIcon` / `PanButton` / `PanImage`** instead of their raw Flutter counterparts.
>
> The host project (e.g. Tarkie) usually wraps `PanText` further with `PriFont` / `SecFont` to inject the brand font weights — refer to that project's typography helpers if present.

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [Page Builders — `PageBlocBuilder`, `PageBuilder`, `WidgetBlocBuilder`](#page-builders--pageblocbuilder-pagebuilder-widgetblocbuilder)
3. [Typography — `PanText`, `SpannableText`](#typography--pantext-spannabletext)
4. [Icons & Images — `PanIcon`, `PanImage`](#icons--images--panicon-panimage)
5. [Buttons & Tappables — `PanButton`, `Tappable`](#buttons--tappables--panbutton-tappable)
6. [Layout & Visibility — `IfElseBuilder`, `WrapperBuilder`, `Elevated`, `LineDivider`, `HeaderBody`](#layout--visibility--ifelsebuilder-wrapperbuilder-elevated-linedivider-headerbody)
7. [Inputs — `PanTextField`](#inputs--pantextfield)
8. [Dialogs — `DialogContainer`, `InformationDialog`, `LoadingDialog`, `ProgressDialog`, `MenuDialog`](#dialogs--dialogcontainer-informationdialog-loadingdialog-progressdialog-menudialog)
9. [Lists & Scrolling — `PanScrollView`, `PullToRefresh`, `ReorderableAnimatedList`, `RefresherHeader`, `SliverDelegate`](#lists--scrolling--panscrollview-pulltorefresh-reorderableanimatedlist-refresherheader-sliverdelegate)
10. [Builders & Async — `DefaultBuilder`, `FutureCachedBuilder`, `IfElseBuilder`, `SizeListener`](#builders--async--defaultbuilder-futurecachedbuilder-ifelsebuilder-sizelistener)
11. [Indicators — `LoadingIndicator`, `PanActivityIndicator`, `LinearProgressBar`, `MediaProgressIndicator`, `LoadingPlaceholder`, `TextPlaceholder`, `Circular`, `CircularWave`, `Rotating`](#indicators--loadingindicator-panactivityindicator-linearprogressbar-mediaprogressindicator-loadingplaceholder-textplaceholder-circular-circularwave-rotating)
12. [Media — `AudioPlayer`, `VideoPlayer`, `VideoController`](#media--audioplayer-videoplayer-videocontroller)
13. [Page Lifecycle — `LifecycleState`, `PermissionState`, `MapState`](#page-lifecycle--lifecyclestate-permissionstate-mapstate)
14. [Resources — `Dimension`, `PanColors`](#resources--dimension-pancolors)
15. [Conventions](#conventions)

---

## File Registry

| File | Symbol(s) | Notes |
| :--- | :--- | :--- |
| `codepan/widgets/page_builder.dart` | `PageBlocBuilder`, `PageBuilder`, `WidgetBlocBuilder`, `BlocCreator`, `BlocObserver`, `BlocBuilder`, `PageScrollBehaviour` | Pages with/without bloc + matching `Scaffold`. |
| `codepan/widgets/text.dart` | `PanText`, `SpannableText`, `OverflowState`, `OnTextOverflow` | Drop-in replacement for `Text` w/ rich-text & spannables. |
| `codepan/widgets/icon.dart` | `PanIcon` | SVG asset loader. |
| `codepan/widgets/image.dart` | `PanImage` | Asset PNG loader. |
| `codepan/widgets/button.dart` | `PanButton` | Material `InkWell` button with text/child variants. |
| `codepan/widgets/tappable.dart` | `Tappable` | Splash-less tap detector around any widget. |
| `codepan/widgets/elevated.dart` | `Elevated` | Material card-style container with shadow. |
| `codepan/widgets/line_divider.dart` | `LineDivider` | Configurable horizontal/vertical line. |
| `codepan/widgets/header_body.dart` | `HeaderBody` | Sticky header + scrolling body composition. |
| `codepan/widgets/if_else_builder.dart` | `IfElseBuilder` | Inline conditional rendering. |
| `codepan/widgets/wrapper.dart` | `WrapperBuilder`, `SpannableText` | Conditional wrapper. |
| `codepan/widgets/text_field.dart` | `PanTextField` | Form input with the same Dimension/Pan conventions. |
| `codepan/widgets/dialogs/dialog.dart` | `DialogContainer` | Base dialog frame with dismiss-on-tap-outside. |
| `codepan/widgets/dialogs/information_dialog.dart` | `InformationDialog`, `InformationController` | Title + message + optional buttons. |
| `codepan/widgets/dialogs/loading_dialog.dart` | `LoadingDialog` | Inline-loading dialog. |
| `codepan/widgets/dialogs/progress_dialog.dart` | `ProgressDialog`, `ProgressController` | Determinate-progress dialog. |
| `codepan/widgets/dialogs/menu_dialog.dart` | `MenuDialog<T extends Selectable>`, `Selectable` | Searchable single/multi-select. |
| `codepan/widgets/scroll_view.dart` | `PanScrollView` | Scrollable view with optional pull-to-refresh. |
| `codepan/widgets/pull_to_refresh.dart` | `PullToRefresh` | Pull-to-refresh + load-more + loading/error/empty placeholders. |
| `codepan/widgets/refresher_header.dart` | Custom `RefresherHeader` | Codepan refresh header indicator. |
| `codepan/widgets/reorderable_animated_list.dart` | `ReorderableAnimatedList` | Drag-and-drop list. |
| `codepan/widgets/sliver_delegate.dart` | `SliverDelegate` (custom) | Persistent header sliver. |
| `codepan/widgets/default_builder.dart` | `DefaultBuilder` | StatefulWidget builder helper. |
| `codepan/widgets/future_cached_builder.dart` | `FutureCachedBuilder` | `FutureBuilder` with in-memory caching. |
| `codepan/widgets/size_listener.dart` | `SizeListener` | Notifies on layout-driven size changes. |
| `codepan/widgets/loading_indicator.dart` | `LoadingIndicator` | Codepan's spinner (auto-platform-aware). |
| `codepan/widgets/pan_activity_indicator.dart` | `PanActivityIndicator` | The custom spinner powering `LoadingIndicator`. |
| `codepan/widgets/linear_progress_bar.dart` | `LinearProgressBar` | Determinate horizontal progress. |
| `codepan/widgets/media_progress_indicator.dart` | `MediaProgressIndicator` | Audio/video buffering UI. |
| `codepan/widgets/loading_placeholder.dart` | `LoadingPlaceholder` | Skeleton block. |
| `codepan/widgets/text_placeholder.dart` | `TextPlaceholder` | Skeleton text. |
| `codepan/widgets/circular.dart` | `Circular` | Circle clipper. |
| `codepan/widgets/circular_wave.dart` | `CircularWave` | Pulse animation. |
| `codepan/widgets/rotating.dart` | `Rotating` | Continuous rotation wrapper. |
| `codepan/widgets/hero.dart` | `PanHero` | `Hero` shortcut. |
| `codepan/widgets/audio_player.dart` | `AudioPlayer`, controller | Audio playback widget. |
| `codepan/widgets/video_player.dart` | `VideoPlayer` | Video playback widget. |
| `codepan/widgets/video_controller.dart` | `VideoController` | Wraps a `video_player` controller. |
| `codepan/widgets/states/lifecycle_state.dart` | `LifecycleState`, `Lifecycle` | App-lifecycle hook for stateful widgets. |
| `codepan/widgets/states/permission_state.dart` | `PermissionState` | Permission-handling state. |
| `codepan/widgets/states/map_state.dart` | `MapState` | Helpers for Google Maps screens. |
| `codepan/resources/dimensions.dart` | `Dimension` | Responsive sizing. |
| `codepan/resources/colors.dart` | `PanColors` | Brand-neutral palette. |

---

## Page Builders — `PageBlocBuilder`, `PageBuilder`, `WidgetBlocBuilder`

Use these instead of writing your own `Scaffold` + `BlocProvider` boilerplate. They provide a consistent app-bar-less `Scaffold`, scroll behavior, and bloc plumbing.

### `PageBlocBuilder<E, B, S>`

```dart
PageBlocBuilder<HomeEvent, HomeBloc, HomeState>(
  creator: (context) => HomeBloc()..start(),
  observer: (context, state) { /* side effects */ },
  builder: (context, state) { return _content(state); },
  bottom: (context, state) => _bottomBar(state),     // optional persistent bottom
  background: PanColors.white,                        // default Colors.white
  behaviour: PageScrollBehaviour.whole,               // .none disables auto-scroll
  bottomNavigationBar: null,
  bottomSheet: null,
  bodyOnly: false,                                    // true → no Scaffold; raw body
  extendBody: true,
);
```

Three required callbacks:

| Param      | Signature                                       |
| :--------- | :---------------------------------------------- |
| `creator`  | `ParentBloc Function(BuildContext)`             |
| `observer` | `void Function(BuildContext, S)`                |
| `builder`  | `Widget Function(BuildContext, S)`              |

**Always** use `PageBlocBuilder` inside a `StatefulWidget` (so the bloc lifecycle ties to the widget). Setting `bodyOnly: true` strips the internal `Scaffold` — useful when nesting under another scaffolded page.

### `PageBuilder`

Same surface area minus the bloc — for static pages:

```dart
PageBuilder(
  builder: (context) => _content(),
);
```

### `WidgetBlocBuilder<E, B, S>`

`PageBlocBuilder` without the `Scaffold`, for nested bloc-backed widgets:

```dart
WidgetBlocBuilder<FilterEvent, FilterBloc, FilterState>(
  creator: (ctx) => FilterBloc()..start(),
  observer: (ctx, s) {},
  builder: (ctx, s) => _filtersUI(s),
);
```

### `PageScrollBehaviour`

- `whole` (default) — wraps the body in a `SingleChildScrollView`.
- `none` — no automatic scroll. Use when your builder already returns a `ListView`/`CustomScrollView`.

---

## Typography — `PanText`, `SpannableText`

```dart
PanText(
  text: 'Hello $name',
  fontSize: d.at(14),
  fontWeight: FontWeight.w500,
  fontColor: PanColors.text,
  textAlign: TextAlign.left,
  alignment: Alignment.centerLeft,
  margin: EdgeInsets.symmetric(horizontal: d.at(20)),
  padding: EdgeInsets.all(d.at(8)),
  background: PanColors.grey2,
  radius: d.at(6),
  border: Border.all(color: PanColors.border),
  hint: 'Default text shown when text is null',
  hintFontColor: PanColors.grey3,
  isRequired: true,    // appends a red asterisk
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
);
```

Highlights:

| Param | Behavior |
| :--- | :--- |
| `text` / `hint` | Hint shown when `text` is null/empty. |
| `isRequired` | Appends a red `*` span. |
| `spannable` | `SpannableText` for inline styling between markers. |
| `children` | Extra `InlineSpan`s appended after `text`. |
| `onTextOverflow` | Callback with the line count after layout — used to render "Show more". |
| `overflowState` | `initial` / `collapse` / `expand` — toggle to show full text. |
| `isScalable` | Set `false` to opt out of system text scale (font size locked). |
| `maxLength` | Truncates input string with `...` before painting. |

### `SpannableText`

```dart
PanText(
  text: 'You have <s>5</s> new messages',
  spannable: SpannableText(
    identifiers: ['<s>', '</s>'],
    style: TextStyle(fontWeight: FontWeight.bold, color: PanColors.red1),
  ),
);
```

Wrap any number of identifier pairs around the text you want styled. Supports per-character styling via `styles`:

```dart
SpannableText(
  identifiers: ['*'],
  style: TextStyle(fontWeight: FontWeight.bold),
  styles: {
    '_': TextStyle(fontStyle: FontStyle.italic),
  },
);
// In text: 'I am *bold* and _italic_'
```

> Tarkie convention: define `PriFont.reg/med/bold` and `SecFont.reg/med/bold` constructors that wrap `PanText` with the project's font family. Use those in pages, not `PanText` directly.

---

## Icons & Images — `PanIcon`, `PanImage`

```dart
PanIcon(
  icon: 'arrow_back',                      // assets/icons/arrow_back.svg
  width: d.at(24),
  height: d.at(24),
  color: PanColors.text,
  background: PanColors.none,
  margin: EdgeInsets.all(d.at(4)),
  isInternal: false,                       // true → resolve from codepan's package assets
  package: null,                           // override package source
  fit: BoxFit.contain,
  alignment: Alignment.center,
);
```

- Default lookup: `assets/icons/<icon>.svg` in your project.
- `isInternal: true` makes codepan look up its bundled asset (used by codepan's own widgets).
- Pass `package: 'tarkie_native'` etc. if your icons live in another package.

```dart
PanImage(
  image: 'logo',          // 'assets/images/logo.png'
  width: d.at(120),
  height: d.at(120),
  fit: BoxFit.contain,
);
```

- Extension defaults to `.png` when omitted: `'logo'` → `assets/images/logo.png`. Pass `'banner.jpg'` to keep your own extension.

---

## Buttons & Tappables — `PanButton`, `Tappable`

```dart
PanButton(
  text: 'Save',
  onTap: () => bloc.add(const Save()),
  fontColor: PanColors.white,
  fontSize: d.at(14),
  fontWeight: FontWeight.w600,
  background: t.primaryColor,
  radius: d.at(6),
  padding: EdgeInsets.symmetric(horizontal: d.at(20), vertical: d.at(10)),
  width: double.infinity,
  splashColor: PanColors.splash,
  highlightColor: PanColors.highlight,
  borderColor: PanColors.border,
  borderWidth: 1,
  child: ...,                  // wins over `text` when provided
);
```

`PanButton` builds a `Material` + `InkWell` + `Ink` chain so splash effects render correctly inside cards. Key rules:

- Use `child` for icon/text combos; use `text` for plain labels.
- `radius` is in logical pixels — wrap in `d.at(...)` for responsiveness.
- For "icon-only" tap targets where you don't want any splash, use `Tappable` instead.

`Tappable` is a splash-less detector you wrap around any widget — handy for full-row taps in lists.

---

## Layout & Visibility — `IfElseBuilder`, `WrapperBuilder`, `Elevated`, `LineDivider`, `HeaderBody`

### `IfElseBuilder`

```dart
IfElseBuilder(
  condition: state.isLoaded,
  ifBuilder: (ctx) => _list(state),
  elseBuilder: (ctx) => const LoadingIndicator(),
  margin: EdgeInsets.all(d.at(8)),
  padding: ...,
  width: ...,
  alignment: Alignment.center,
);
```

Use this **everywhere** instead of `if (cond) ... else ...` ternaries — it composes cleanly with parents and makes diffs greppable.

### `WrapperBuilder`

```dart
WrapperBuilder(
  condition: shouldWrap,
  child: PanText(text: 'Hello'),
  builder: (ctx, child) => Container(color: PanColors.grey2, child: child),
);
```

When `condition == false`, `child` is rendered as-is. When true, `builder` decides how to wrap it.

### `Elevated`

A `Container` with a built-in shadow (powered by `Material`'s `elevation`). Use as a card replacement:

```dart
Elevated(
  radius: d.at(8),
  margin: EdgeInsets.all(d.at(12)),
  padding: EdgeInsets.all(d.at(16)),
  color: Colors.white,
  child: Column(...),
);
```

Optional: `boxShape: BoxShape.circle`, custom `boxShadow` list, `shadowColor`, `shadowBlurRadius`, `spreadRadius`.

### `LineDivider`

Horizontal or vertical thin divider:

```dart
LineDivider();              // horizontal, default color
LineDivider(height: d.at(1), color: PanColors.divider);
LineDivider(isVertical: true, width: d.at(1));
```

### `HeaderBody`

Composes a non-scrolling header with a scrolling body. Use as a structural alternative when you need a sticky title within a `PageBlocBuilder` body.

---

## Inputs — `PanTextField`

A heavy widget — covers ~80 props. The most common subset:

```dart
PanTextField(
  controller: _ctrl,
  hint: 'Email',
  text: initialEmail,
  onChanged: (v) => bloc.add(EmailChanged(v)),
  onFieldSubmitted: (v) => focus.nextFocus(),
  fontSize: d.at(14),
  fontColor: PanColors.text,
  hintFontColor: PanColors.grey3,
  background: PanColors.grey2,
  borderColor: PanColors.border,
  focusedBorderColor: t.primaryColor,
  borderWidth: 1,
  radius: d.at(6),
  padding: EdgeInsets.symmetric(horizontal: d.at(12), vertical: d.at(10)),
  prefixIcon: PanIcon(icon: 'mail'),
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,
  textCapitalization: TextCapitalization.none,
  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\w@.-]'))],
  enabled: true,
  maxLines: 1,
  isPassword: false,
  obscureText: false,
  bottomBorderOnly: false,            // line under the field instead of full border
);
```

Flags worth noting:

- `bottomBorderOnly: true` strips left/right/top borders.
- `isPassword: true` enables peek toggle.
- `expands: true` + `maxLines: null` for a chat-style multi-line input.

---

## Dialogs

All dialogs sit on top of a shared `DialogContainer`, which:

- Adds an outer `WillPopScope` to honor `dismissible`.
- Adds a tap-outside-to-dismiss layer.
- On desktop, constrains width to ~320 dp; on mobile, fills width with margin.

Show via `showDialog`:

```dart
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => InformationDialog(...),
);
```

### `InformationDialog`

Title + message + optional buttons. Use for confirms, info messages, and any "single-shot" prompt.

```dart
InformationDialog(
  title: 'Discard changes?',
  message: 'Your edits will be lost.',
  positive: 'Discard',
  negative: 'Cancel',
  onPositiveTap: () => bloc.add(const Discard()),
  withDivider: true,
  dismissible: true,
  autoDismiss: true,                 // auto-pop on button tap
);
```

`InformationController` lets you mutate the `message` after the dialog is open:

```dart
final ctrl = InformationController(value: 'Connecting…');
showDialog(..., builder: (_) => InformationDialog(controller: ctrl, ...));
// later:
ctrl.setMessage('Authenticating…');
```

### `LoadingDialog`

Simple "spinner + message" dialog, no buttons:

```dart
LoadingDialog(
  message: 'Saving…',
  dismissible: false,
  fontColor: PanColors.text,
);
```

### `ProgressDialog`

Determinate progress with a `LinearProgressBar`. Drive via `ProgressController`:

```dart
final progress = ProgressController();
showDialog(..., builder: (_) => ProgressDialog(
  controller: progress,
  title: 'Uploading',
  message: 'Please wait…',
));
// later:
progress.setProgress(ProgressData(current: 12, max: 40));
// when done:
progress.reset();
```

The dialog automatically displays `12/40` and `30%`. See [data_models.md](./data_models.md#progressdata) for `ProgressData`.

### `MenuDialog<T extends Selectable>`

Searchable single/multi-select. Any object that implements `Selectable` can be a menu item — `MasterData` already does.

```dart
final pick = await showDialog<UserData>(
  context: context,
  builder: (_) => MenuDialog<UserData>(
    title: 'Pick a user',
    items: users,
    selectedItems: [currentUser],
    onSelectItem: (user) => Navigator.pop(context, user),
    isMultiple: false,
    showSelected: true,
  ),
);

// Multi-select:
MenuDialog<RoleData>(
  title: 'Roles',
  items: roles,
  isMultiple: true,
  positive: 'Apply',
  negative: 'Cancel',
  onSelectItems: (selection) => bloc.add(SetRoles(selection)),
);
```

Search is enabled automatically via `SearchHandlerMixin`. Customize the filter UI by passing `searchBuilder`.

---

## Lists & Scrolling

### `PanScrollView`

`SingleChildScrollView` + intrinsic-size body + optional pull-to-refresh:

```dart
PanScrollView(
  refreshController: _refresh,
  scrollController: _scroll,
  enablePullDown: true,
  onRefresh: () => bloc.add(const Refresh()),
  padding: EdgeInsets.all(d.at(12)),
  header: _topBanner(),
  child: Column(children: [...]),
);
```

### `PullToRefresh`

Full-featured list shell with pull-down + load-more + loading/error/empty placeholders. Built on `pull_to_refresh_flutter3`:

```dart
PullToRefresh(
  controller: _refresh,
  isLoading: state.isLoading,
  isError: state.isError,
  isCompleted: state.isCompleted,
  itemCount: state.items.length,
  enablePullDown: true,
  onRefresh: () => bloc.add(const Refresh()),
  onLoading: () => bloc.add(const LoadMore()),
  onScrollToMax: () { /* infinite scroll trigger */ },
  loadingBuilder: (ctx) => const LoadingIndicator(),
  errorBuilder: (ctx) => _retry(state.error),
  placeholderBuilder: (ctx) => const TextPlaceholder(text: 'No items'),
  builder: (ctx) => ListView.builder(
    itemCount: state.items.length,
    itemBuilder: (_, i) => UserTile(state.items[i]),
  ),
);
```

`floating` lets you stick a header that hides on scroll-down and reveals on scroll-up.

### `ReorderableAnimatedList`

Drag-to-reorder list. Supplies index-aware animation. Pair with a `ReorderingController` to react to reorder events.

### `RefresherHeader`

Codepan's branded "pull-down" header — drop-in for `SmartRefresher.header`:

```dart
PullToRefresh(controller: _refresh, header: const RefresherHeader(), ...);
```

### `SliverDelegate`

Persistent header `SliverPersistentHeaderDelegate` with codepan defaults — useful if you build a `CustomScrollView`.

---

## Builders & Async

### `DefaultBuilder`

Stateful-widget builder that exposes `initState`/`dispose` callbacks without writing a `StatefulWidget`. Useful for scoped controllers/animations inside a `StatelessWidget`.

### `FutureCachedBuilder`

`FutureBuilder` with an internal cache so the future is not re-run when the widget rebuilds:

```dart
FutureCachedBuilder<List<UserData>>(
  future: () => UserService(db).loadRecords(),
  builder: (ctx, snapshot) {
    if (snapshot.hasData) return _list(snapshot.data!);
    return const LoadingIndicator();
  },
);
```

Pass `cacheKey` to invalidate.

### `IfElseBuilder`

Already covered above — used as both a layout helper and a conditional rendering tool.

### `SizeListener`

Reports its child's rendered size up to a callback:

```dart
SizeListener(
  child: someCard,
  onSizeChange: (size, offset) => setState(() => _cardSize = size),
);
```

Used internally by `PullToRefresh` for floating headers.

---

## Indicators

| Widget | Use case |
| :--- | :--- |
| `LoadingIndicator` | One-stop spinner. Auto-uses `CircularProgressIndicator` on Android (when `isPlatformDependent: true`); otherwise a custom dotted ring. Pass `icon: 'sync'` to spin an SVG via `Rotating`. |
| `PanActivityIndicator` | The dotted ring used by `LoadingIndicator`. Configure `radius`, `activeColor`, `inactiveColor`. |
| `LinearProgressBar` | Determinate horizontal bar. Powers `ProgressDialog`. |
| `MediaProgressIndicator` | Buffering / play-progress UI for `AudioPlayer` / `VideoPlayer`. |
| `LoadingPlaceholder` | Skeleton block — animated shimmer placeholder. Composable. |
| `TextPlaceholder` | Empty/no-data text helper. |
| `Circular` | Clip-oval wrapper. |
| `CircularWave` | Pulse animation around a point. |
| `Rotating` | Wraps any widget in a constant rotation. |

---

## Media

### `AudioPlayer` / `VideoPlayer` / `VideoController`

Self-contained players that use `MediaProgressIndicator` for buffering and `LoadingIndicator` for waits. Give them a URL or a local `File`:

```dart
AudioPlayer(source: file);
VideoPlayer(controller: VideoController.network(url));
```

The `media.dart` typedefs (`OnProgressChanged`, `OnCompleted`, `OnError`) are reused across these widgets.

---

## Page Lifecycle

### `LifecycleState<T extends StatefulWidget>`

Mixin-style abstract class. Subclass instead of `State<T>` when you need lifecycle hooks:

```dart
class _MyPageState extends LifecycleState<MyPage> {
  @override void onResume() { super.onResume(); bloc.add(const Refresh()); }
  @override void onPause()  { super.onPause(); }
  @override void onInactive() {}
  @override void onDetach() {}
}
```

It handles `WidgetsBindingObserver` add/remove for you.

### `PermissionState<T>`

Subclass for screens that gate content behind a permission check. Override:

```dart
class _CameraPageState extends PermissionState<CameraPage> {
  @override List<Permission> get permissions => [Permission.camera];

  @override
  void onPermissionsGranted() => setState(() => _ready = true);

  @override
  bool onShowPermissionDisclosure(permission, title, message, onDetach, onContinue) {
    showDialog(context: context, builder: (_) => InformationDialog(
      title: title, message: message,
      positive: 'Continue', onPositiveTap: onContinue,
      onDispose: onDetach,
    ));
    return true;   // tells codepan a dialog is up
  }
}
```

Codepan auto-rechecks on app resume.

### `MapState`

Helpers for Google Maps screens — wraps `GoogleMapController` lifecycle, marker management, and re-centering. Use when you need to embed a map in a stateful widget.

---

## Resources — `Dimension`, `PanColors`

### `Dimension`

```dart
final d = Dimension.of(context);
d.at(14);                  // scaled value
d.scale(14);               // d.at(14) * textScaleFactor
d.viewPortFraction(0.8);   // for PageView
d.statusBarHeight;
d.bottomPadding;
d.size;                    // full screen size
d.maxWidth / d.maxHeight;
d.isLandscape;
d.orientation;
d.deviceRatio;             // long edge / short edge
d.pixelRatio;
```

`d.at(value)` linearly scales by `min(width,height) / 360` (the codepan baseline) up to `boundary = 480`. Anything beyond the boundary is clamped — keeps tablet UIs from getting absurdly large.

> Always declare `final d = Dimension.of(context);` as the **first** line of every `build` method.

### `PanColors`

A neutral palette to fall back to when the project's brand palette doesn't define a color:

| Color | Hex |
| :--- | :--- |
| `PanColors.white` | `#FFFFFF` |
| `PanColors.black` | `#000000` |
| `PanColors.none` | `transparent` |
| `PanColors.font` | `#414141` |
| `PanColors.text` | `#454F63` |
| `PanColors.border` | `#E8E9EA` |
| `PanColors.divider` | `#EDEEF4` |
| `PanColors.grey1`–`grey4` | various neutrals |
| `PanColors.splash` / `highlight` | semi-transparent overlays |
| `PanColors.red1` | `#D32F2F` |
| `PanColors.green1` | `#39AC4C` |

Use these in dialogs, dividers, hint colors. Brand-specific colors live in your project's resources file.

---

## Conventions

| Rule | Why |
| :--- | :--- |
| Always `final d = Dimension.of(context);` first in `build`. | Responsive scaling. |
| Wrap every literal `double` for size/padding/font in `d.at(...)`. | Same. |
| Use `PanText` (or your project's `PriFont`/`SecFont`) — never bare `Text`. | Typography consistency. |
| Use `PanIcon` — never bare `Icon` for app icons. | Vector + theming consistency. |
| Use `PanButton` for tappable rectangles, `Tappable` for non-splash taps. | Splash + ink material correctness. |
| Use `IfElseBuilder` instead of inline ternaries for substantial conditionals. | Greppable diffs and consistent layout. |
| Wrap dialogs with `DialogContainer` (already done by every `*Dialog` codepan widget). | Tap-outside-to-dismiss + consistent margin. |
| Don't put a `Scaffold` inside a `PageBlocBuilder`/`PageBuilder`. | They already include one; nesting causes double app-bars. |
| For pages without a bloc, use `PageBuilder`; for bloc-backed pages, use `PageBlocBuilder` (or your project's `TitlePageBloc` if it exists). | Lifecycle and Scaffold correctness. |

For module-specific conventions (database, http, bloc), see those docs.
