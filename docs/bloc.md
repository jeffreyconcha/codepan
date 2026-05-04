# BLoC Module

How to use the `codepan/bloc/*` building blocks (`ParentBloc`, `ParentEvent`, `ParentState`, `BlocHandlerMixin`, `FinisherState`, `ErrorState`) in any project that depends on `codepan`. The bloc module is the standardized state-management layer of the codepan ecosystem — every page, widget, or service that needs reactive state should lean on these classes instead of declaring its own `Bloc<E, S>` directly.

> **Note:** This document intentionally does **NOT** prescribe folder structure for blocs. Different host projects (e.g. plain BLoC, MVVM-on-bloc) organize their blocs differently. Focus here is purely on **how** to use the codepan classes.

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [Module Overview](#module-overview)
3. [The Three Pillars: Event, State, Bloc](#the-three-pillars-event-state-bloc)
4. [`ParentEvent` — Event Base Class](#parentevent--event-base-class)
5. [`ParentState` — State Base Class](#parentstate--state-base-class)
6. [`ParentBloc` — Bloc Base Class](#parentbloc--bloc-base-class)
7. [The Mirror Pattern (Event ⇄ State)](#the-mirror-pattern-event--state)
8. [`BlocHandlerMixin` — Loading Tracker](#blochandlermixin--loading-tracker)
9. [`FinisherState` and `ErrorState` Mixins](#finisherstate-and-errorstate-mixins)
10. [Connecting a Bloc to UI](#connecting-a-bloc-to-ui)
11. [Reading a Bloc From Anywhere — `context.blocOf`](#reading-a-bloc-from-anywhere--contextblocof)
12. [`initialEvent` and `start()`](#initialevent-and-start)
13. [Adding Multiple Events at Once](#adding-multiple-events-at-once)
14. [Error Handling](#error-handling)
15. [Common Pitfalls](#common-pitfalls)
16. [End-to-End Example](#end-to-end-example)

---

## File Registry

Every codepan source file this document depends on. When in doubt, jump to the file — the source is small and readable.

| File                                       | Symbol(s) Exposed                                              | Purpose                                                            |
| :----------------------------------------- | :------------------------------------------------------------- | :----------------------------------------------------------------- |
| `codepan/bloc/parent_event.dart`           | `ParentEvent`                                                  | Base class for every BLoC event in the project.                    |
| `codepan/bloc/parent_state.dart`           | `ParentState`                                                  | Base class for every BLoC state. Pairs each state with an `Event`. |
| `codepan/bloc/parent_bloc.dart`            | `ParentBloc`                                                   | Base class for every BLoC. Adds `start()` and `addAll(...)`.       |
| `codepan/bloc/bloc_handler.dart`           | `BlocHandlerMixin`, `FinisherState`, `ErrorState`              | Built-in loading-state tracking and standardized error semantics.  |
| `codepan/extensions/context.dart`          | `context.blocOf<T>()`                                          | Retrieve a `ParentBloc` instance from a `BuildContext`.            |
| `codepan/widgets/page_builder.dart`        | `PageBlocBuilder`, `WidgetBlocBuilder`, `BlocCreator`, etc.    | Plug a `ParentBloc` into a Flutter page or widget tree.            |

The `flutter_bloc` and `equatable` packages are transitive dependencies — you do **not** need to add them yourself. Any time you need `BlocProvider`, `BlocListener`, or `BlocBuilder` directly, import them from `package:flutter_bloc/flutter_bloc.dart`.

---

## Module Overview

The codepan bloc module is a thin opinionated layer on top of the standard [`bloc`](https://pub.dev/packages/bloc) / [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) packages. It enforces three rules:

1. **Every event extends `ParentEvent`.** Events are immutable (Equatable) and may carry a "mirrored" state, so a state can convert itself back into an event without ceremony.
2. **Every state extends `ParentState`.** A state declares the event type it mirrors back to via the `Event` generic, plus a `mirrorToEvent()` implementation.
3. **Every bloc extends `ParentBloc<Event, State>`.** Blocs get free loading-state tracking, an optional `initialEvent`, and standardized error logging.

The end result is that any page in your project can do:

```dart
PageBlocBuilder<MyEvent, MyBloc, MyState>(
  creator: (context) => MyBloc()..start(),
  observer: (context, state) { /* side effects */ },
  builder: (context, state) { /* UI */ },
);
```

…and behave consistently with every other page in the codebase.

---

## The Three Pillars: Event, State, Bloc

A typical bloc set has three classes:

```dart
// 1) Event — what the UI dispatches.
abstract class HomeEvent extends ParentEvent {
  const HomeEvent([super.state]);
}

class LoadHome extends HomeEvent {
  const LoadHome();
}

class RefreshHome extends HomeEvent {
  const RefreshHome();
}

// 2) State — what the bloc emits.
abstract class HomeState extends ParentState<HomeEvent> {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
  @override
  HomeEvent mirrorToEvent() => const LoadHome();
}

class HomeLoaded extends HomeState with FinisherState<HomeLoaded> {
  final List<ItemData> items;
  const HomeLoaded(this.items);
  @override
  HomeEvent mirrorToEvent() => const RefreshHome();
  @override
  List<Object?> get props => [items];
}

class HomeError extends HomeState with ErrorState<HomeLoaded> {
  @override
  final Object error;
  const HomeError(this.error);
  @override
  HomeEvent mirrorToEvent() => const LoadHome();
}

// 3) Bloc — the rules between events and states.
class HomeBloc extends ParentBloc<HomeEvent, HomeState> {
  HomeBloc()
      : super(
          initialState: const HomeInitial(),
          initialEvent: const LoadHome(),
        ) {
    on<LoadHome>(_onLoad);
    on<RefreshHome>(_onLoad);
  }

  Future<void> _onLoad(HomeEvent event, Emitter<HomeState> emit) async {
    try {
      final items = await _repo.fetch();
      emit(HomeLoaded(items));
    } catch (e) {
      emit(HomeError(e));
    }
  }
}
```

Three things to note:

- `HomeEvent` accepts an optional **mirrored state** (`super.state`). You pass it when an event is "born from" a state — e.g. retrying after an error. Keep it `null` for plain events.
- Each `HomeState` subclass implements `mirrorToEvent()` so the system can spawn the **right event** from a state without you having to type-test by hand.
- `HomeBloc` registers handlers with the standard `on<...>` API. Codepan does not change how you write handlers — only what you extend.

---

## `ParentEvent` — Event Base Class

```dart
class ParentEvent extends Equatable {
  final ParentState? state;
  const ParentEvent(this.state);

  bool isMirroredFrom<State extends ParentState>() => state is State;

  @override
  List<Object?> get props => [state];
}
```

**Always** extend `ParentEvent` for project events. Properties:

- **`state`** *(optional)* — the originating state. Set this when you fire an event in response to an existing state (e.g. retry).
- **`isMirroredFrom<S>()`** — convenient type test. Useful inside an `on<...>` handler when you need to branch on whether the event originated from a particular error/finisher state.

### Adding event-specific data

Just add fields like any normal Equatable subclass; remember to override `props`:

```dart
class LoadItem extends HomeEvent {
  final int itemId;
  const LoadItem(this.itemId);

  @override
  List<Object?> get props => [...super.props, itemId];
}
```

### Marker (no-payload) events

For events that carry no data (e.g. `Refresh`, `Reset`), you can keep them as a plain `const` constructor with no fields. Equatable handles equality automatically through `props`.

---

## `ParentState` — State Base Class

```dart
abstract class ParentState<Event extends ParentEvent> extends Equatable {
  const ParentState();
  Event mirrorToEvent();
  Type get origin => Event;
}
```

**Always** extend `ParentState<YourEvent>`. The generic ties a state group to an event group at the type level; `mirrorToEvent()` is the implementation contract that lets any state regenerate "the event that produced me."

### Why `mirrorToEvent()`?

It's the canonical answer to "I'm holding a state — how do I retry it?" Used heavily in error/retry flows:

```dart
PanButton(
  text: 'Retry',
  onTap: () {
    final state = context.blocOf<HomeBloc>().state;
    context.blocOf<HomeBloc>().add(state.mirrorToEvent());
  },
);
```

### `props` is required

`ParentState` is `Equatable`, so override `props` on every concrete state. If you forget, two distinct states with the same payload will be considered equal and the bloc may skip emitting them — symptom: UI stops updating after the first build.

```dart
class HomeLoaded extends HomeState {
  final List<ItemData> items;
  const HomeLoaded(this.items);

  @override
  HomeEvent mirrorToEvent() => const RefreshHome();

  @override
  List<Object?> get props => [items];
}
```

---

## `ParentBloc` — Bloc Base Class

```dart
abstract class ParentBloc<Event extends ParentEvent, State extends ParentState>
    extends Bloc<Event, State> with BlocHandlerMixin<Event, State> {
  final Event? initialEvent;

  ParentBloc({
    required State initialState,
    this.initialEvent,
  }) : super(initialState);

  void start() { if (initialEvent != null) add(initialEvent!); }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    printError(error, stackTrace);
  }

  void addAll(List<Event> events) { events.forEach(add); }
}
```

Key points:

- Pass `initialState` and (optionally) `initialEvent` to the super constructor.
- Call **`bloc.start()`** to dispatch `initialEvent`. Most pages do this in their `creator`: `creator: (ctx) => MyBloc()..start()`.
- `addAll(events)` dispatches a list in the order given.
- `onError` is overridden to log via codepan's `printError`, so unhandled exceptions show up in the debug console with stacktrace context.

### Registering handlers

Use the stock `on<E>(handler)` API inside the constructor body, exactly the same as a vanilla `Bloc`:

```dart
class HomeBloc extends ParentBloc<HomeEvent, HomeState> {
  HomeBloc()
      : super(
          initialState: const HomeInitial(),
          initialEvent: const LoadHome(),
        ) {
    on<LoadHome>(_handleLoad);
    on<RefreshHome>(_handleLoad);
    on<DeleteItem>(_handleDelete);
  }

  Future<void> _handleLoad(HomeEvent e, Emitter<HomeState> emit) async { /*...*/ }
  Future<void> _handleDelete(DeleteItem e, Emitter<HomeState> emit) async { /*...*/ }
}
```

You can also use `Stream`-based emitters, `emit.forEach`, etc. — codepan does not constrain handler shape.

---

## The Mirror Pattern (Event ⇄ State)

Two complementary mechanisms:

1. **State → Event** via `state.mirrorToEvent()` — answers "what event would re-trigger this state?"
2. **Event ← State** via `event.state` — when you create a new event because of an existing state, pass that state in the constructor: `Refresh(state: oldState)`. Inside the handler check `event.isMirroredFrom<HomeError>()`.

### Example: Retry on Error

```dart
// State carries error info; mirror to event as "load again."
class HomeError extends HomeState with ErrorState<HomeLoaded> {
  @override final Object error;
  const HomeError(this.error);
  @override HomeEvent mirrorToEvent() => const LoadHome();
}

// UI:
ElevatedButton(
  onPressed: () => context.blocOf<HomeBloc>().add(state.mirrorToEvent()),
  child: const Text('Retry'),
);
```

This pattern keeps retry/refresh logic out of the UI — the state itself knows how to relive itself.

---

## `BlocHandlerMixin` — Loading Tracker

Automatically applied to every `ParentBloc`. It maintains an internal `Map<Type, bool>` keyed by state type so the UI can ask **"is the bloc currently working towards state X?"**.

```dart
final isLoadingItems = context.blocOf<HomeBloc>().isLoading<HomeLoaded>();
```

How the map is populated, in `onTransition`:

- A state that **mixes in** `FinisherState<S>` ⇒ marks `S` as loading (`true`).
- A state that **mixes in** `ErrorState<S>` ⇒ removes `S` from the map (loading cleared).
- Any other plain state with type `T` ⇒ removes `T` from the map.

### Typical usage

Use `isLoading<X>()` from inside the bloc to gate redundant requests, or expose it via state:

```dart
Future<void> _handleLoad(HomeEvent e, Emitter<HomeState> emit) async {
  if (isLoading<HomeLoaded>()) return;     // already in flight
  emit(const HomeLoading());
  // ... do work, finally emit HomeLoaded
}
```

---

## `FinisherState` and `ErrorState` Mixins

```dart
mixin FinisherState<S extends ParentState> { Type get type => S; }

mixin ErrorState<S extends ParentState> {
  Type get type => S;
  Object get error;
  bool get isNetwork => error is SocketException;
  String get message {
    if (isNetwork) return Errors.unableToConnectToServer;
    if (error is TimeoutException) return Errors.requestTimedOut;
    return error.toString();
  }
}
```

### `FinisherState<S>`

Mark a state as the "completion" of an asynchronous operation that targets state `S`. In practice you mix it into the **success** state of an in-flight operation. For most cases, `S` is the same class:

```dart
class HomeLoaded extends HomeState with FinisherState<HomeLoaded> { ... }
```

But you can also mix it into a different state if a *different* completion type closes the loading window — e.g. a `ProductsRefreshed` finishes `ProductsLoaded`.

### `ErrorState<S>`

Mark a state as the "error variant" that closes the loading window for `S`. The mixin gives you:

- **`error`** — the raw exception you stored on the state.
- **`isNetwork`** — `true` for `SocketException`.
- **`message`** — a localized, user-friendly message. Customize globally by editing `codepan/resources/strings.dart`.

```dart
class HomeError extends HomeState with ErrorState<HomeLoaded> {
  @override final Object error;
  const HomeError(this.error);
  @override HomeEvent mirrorToEvent() => const LoadHome();
}
```

> **Important:** The generic `S` on both mixins must match — pair `FinisherState<HomeLoaded>` with `ErrorState<HomeLoaded>`. Otherwise the loading map will not clear correctly.

---

## Connecting a Bloc to UI

Use codepan's `PageBlocBuilder` (in `codepan/widgets/page_builder.dart`) for full pages, or `WidgetBlocBuilder` for partial trees. Both expect three callbacks:

| Param      | Type                                  | Purpose                                  |
| :--------- | :------------------------------------ | :--------------------------------------- |
| `creator`  | `ParentBloc Function(BuildContext)`   | Create + provide your bloc.              |
| `observer` | `void Function(BuildContext, State)`  | Side effects (snackbars, navigation).    |
| `builder`  | `Widget Function(BuildContext, State)`| Pure UI rendering.                       |

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return PageBlocBuilder<HomeEvent, HomeBloc, HomeState>(
      creator: (context) => HomeBloc()..start(),
      observer: (context, state) {
        if (state is HomeError) {
          // show snackbar / dialog
        }
      },
      builder: (context, state) {
        if (state is HomeLoaded) return _buildList(state.items);
        if (state is HomeError) return _buildError(state);
        return const LoadingIndicator();
      },
    );
  }
}
```

> Use `PageBlocBuilder` only inside a `StatefulWidget`. Static-only pages should use `PageBuilder` (no bloc).

### Multiple blocs on a page

Stick to standard `flutter_bloc`'s `MultiBlocProvider` at the top of your widget tree, then read the secondary blocs with `context.blocOf<X>()`.

---

## Reading a Bloc From Anywhere — `context.blocOf`

Defined in `codepan/extensions/context.dart`:

```dart
extension BuildContextUtils on BuildContext {
  T blocOf<T extends ParentBloc>() => BlocProvider.of<T>(this);
}
```

Use it from any descendant of the provider:

```dart
final bloc = context.blocOf<HomeBloc>();
bloc.add(const LoadHome());
```

This is just `BlocProvider.of<T>(context)` typed against `ParentBloc`, but the extension keeps call sites short and consistent. **Always** prefer `context.blocOf<T>()` over the verbose form.

---

## `initialEvent` and `start()`

`ParentBloc` accepts an optional `initialEvent`. It is **not** dispatched automatically — you must call `start()`. The conventional spot is the `creator`:

```dart
PageBlocBuilder<HomeEvent, HomeBloc, HomeState>(
  creator: (context) => HomeBloc()..start(),
  ...
);
```

If a page must initialize from data only available at runtime, omit `initialEvent` entirely and dispatch the first event in `observer`/`initState`:

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.blocOf<HomeBloc>().add(LoadHome(userId: widget.userId));
  });
}
```

---

## Adding Multiple Events at Once

`ParentBloc.addAll(List<Event>)` dispatches each event in order:

```dart
context.blocOf<HomeBloc>().addAll([
  const ClearFilters(),
  const ResetPagination(),
  const LoadHome(),
]);
```

There is no batching — they're queued one after another, just like calling `add` three times.

---

## Error Handling

Three layers, in order of preference:

1. **Catch in handlers and emit an `ErrorState` mixed-in state.** This is the canonical path; the UI sees the error in `observer`/`builder`, and `BlocHandlerMixin` clears any pending loading.
2. **Throw out of a handler.** `ParentBloc.onError` will log via `printError` (with stacktrace). You will *not* automatically get a state transition — make sure you also `emit(...)` an error state or the UI will freeze on its previous state.
3. **Use `Errors`/`Strings`** in `codepan/resources/strings.dart` for user-facing messages so the project speaks one voice.

```dart
Future<void> _handleLoad(HomeEvent e, Emitter<HomeState> emit) async {
  try {
    final items = await _repo.fetch();
    emit(HomeLoaded(items));
  } on SocketException catch (err) {
    emit(HomeError(err));   // ErrorState.message → Errors.unableToConnectToServer
  } catch (err) {
    emit(HomeError(err));
  }
}
```

---

## Common Pitfalls

| Pitfall | Symptom | Fix |
| :--- | :--- | :--- |
| Forgetting `props` on a `ParentState` | UI doesn't rebuild after first emission of "the same" state | Override `props` to include every meaningful field. |
| Mixing in `FinisherState<X>` and `ErrorState<Y>` (mismatched `X`/`Y`) | `isLoading<X>()` gets stuck `true` after an error | Use the same generic on both mixins. |
| Calling `bloc.add(initialEvent)` manually after `..start()` | Initial event runs twice | Pick one: `..start()` **or** manual `add`. |
| Using `BlocProvider.of<T>(context)` directly | Verbose, inconsistent with codebase | Use `context.blocOf<T>()`. |
| Wrapping a bloc page with another `Scaffold` | Doubled app bar / wrong padding | `PageBlocBuilder` includes a `Scaffold` — do not nest one. Set `bodyOnly: true` to opt out. |
| Throwing inside a handler without emitting a state | UI sticks on previous state forever | Always `emit(SomeErrorState(error))` after catching. |

---

## End-to-End Example

A minimal but complete page that loads, displays, and refreshes a list of items, plus retries on error.

```dart
// ---- events.dart ----
abstract class ItemsEvent extends ParentEvent {
  const ItemsEvent([super.state]);
}
class LoadItems extends ItemsEvent { const LoadItems(); }
class RefreshItems extends ItemsEvent { const RefreshItems(); }

// ---- states.dart ----
abstract class ItemsState extends ParentState<ItemsEvent> {
  const ItemsState();
}

class ItemsInitial extends ItemsState {
  const ItemsInitial();
  @override ItemsEvent mirrorToEvent() => const LoadItems();
}

class ItemsLoading extends ItemsState {
  const ItemsLoading();
  @override ItemsEvent mirrorToEvent() => const LoadItems();
}

class ItemsLoaded extends ItemsState with FinisherState<ItemsLoaded> {
  final List<ItemData> items;
  const ItemsLoaded(this.items);
  @override ItemsEvent mirrorToEvent() => const RefreshItems();
  @override List<Object?> get props => [items];
}

class ItemsFailed extends ItemsState with ErrorState<ItemsLoaded> {
  @override final Object error;
  const ItemsFailed(this.error);
  @override ItemsEvent mirrorToEvent() => const LoadItems();
  @override List<Object?> get props => [error];
}

// ---- bloc.dart ----
class ItemsBloc extends ParentBloc<ItemsEvent, ItemsState> {
  final ItemRepository repo;
  ItemsBloc(this.repo)
      : super(
          initialState: const ItemsInitial(),
          initialEvent: const LoadItems(),
        ) {
    on<LoadItems>(_load);
    on<RefreshItems>(_load);
  }

  Future<void> _load(ItemsEvent e, Emitter<ItemsState> emit) async {
    if (isLoading<ItemsLoaded>()) return;
    emit(const ItemsLoading());
    try {
      emit(ItemsLoaded(await repo.fetch()));
    } catch (err) {
      emit(ItemsFailed(err));
    }
  }
}

// ---- items_page.dart ----
class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});
  @override State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  @override
  Widget build(BuildContext context) {
    return PageBlocBuilder<ItemsEvent, ItemsBloc, ItemsState>(
      creator: (ctx) => ItemsBloc(ctx.read())..start(),
      observer: (ctx, state) {
        if (state is ItemsFailed) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (ctx, state) {
        if (state is ItemsLoaded) {
          return RefreshIndicator(
            onRefresh: () async =>
                ctx.blocOf<ItemsBloc>().add(state.mirrorToEvent()),
            child: ListView(children: state.items.map(_tile).toList()),
          );
        }
        if (state is ItemsFailed) {
          return Center(
            child: PanButton(
              text: 'Retry',
              onTap: () => ctx.blocOf<ItemsBloc>().add(state.mirrorToEvent()),
            ),
          );
        }
        return const LoadingIndicator();
      },
    );
  }
}
```

That single example exercises every mechanism in the module: `ParentEvent`, `ParentState`, `ParentBloc`, `initialEvent`/`start()`, `FinisherState`, `ErrorState`, `mirrorToEvent`, `isLoading`, `context.blocOf`, and `PageBlocBuilder`.
