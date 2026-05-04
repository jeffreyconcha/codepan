# Codepan — Flutter Library Documentation

Codepan is the **shared foundation library** for every Flutter project in this organization. It centralizes BLoC state management, SQLite (with SQLCipher), HTTP requests, widgets, extensions, and assorted utilities behind opinionated abstractions so that every project speaks the same patterns.

> **Audience:** The `docs/` directory is the canonical reference for human contributors *and* for Claude Code when generating code in any codepan-backed project. Always start a new feature by skimming the relevant module doc — most "new" code is just composing what's already here.

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [Why Codepan](#why-codepan)
3. [Adding Codepan to a Project](#adding-codepan-to-a-project)
4. [Module Map](#module-map)
5. [The Layered Architecture](#the-layered-architecture)
6. [Conventions That Apply Everywhere](#conventions-that-apply-everywhere)
7. [Suggested Reading Order](#suggested-reading-order)
8. [Where Project-Specific Docs Live](#where-project-specific-docs-live)

---

## File Registry

| Doc | Covers |
| :--- | :--- |
| [docs/bloc.md](./docs/bloc.md) | `ParentBloc`, `ParentEvent`, `ParentState`, `BlocHandlerMixin`, `FinisherState`, `ErrorState`, mirror pattern. |
| [docs/database.md](./docs/database.md) | `SqliteAdapter`, `SqliteBinder`, `SqliteQuery`, `SqliteStatement`, `Field`, `Condition`, `Table`, `TableSchema`, `DatabaseSchema`, `DatabaseInitializer`, `SqliteCache`, `ServiceFor<T>`. |
| [docs/data_models.md](./docs/data_models.md) | `EntityData`, `TransactionData`, `MasterData`, `BaseFactory`, `PairData`, `ProgressData`, naming, `toMap`/`fromJson`/`copyWith`. |
| [docs/http.md](./docs/http.md) | `GetRequest`, `PostRequest`, `PutRequest`, `PatchRequest`, `DeleteRequest`, `UploadRequest`, `DownloadRequest`, `TransmitRequest`, `InitHandler`, `DataInitHandler`, `ByteInitHandler`. |
| [docs/widgets.md](./docs/widgets.md) | `PageBlocBuilder`, `PageBuilder`, `PanText`, `PanIcon`, `PanImage`, `PanButton`, `PanTextField`, dialogs, lists, indicators, lifecycle states, `Dimension`, `PanColors`. |
| [docs/extensions.md](./docs/extensions.md) | All `codepan/extensions/*` (`BuildContext`, `Map`, `String`, `List`, `dynamic`, `int`, `num`, `double`, `Duration`, `Directory`, `File`, `CustomPainter`, `SendPort`). |
| [docs/utils.md](./docs/utils.md) | `PanUtils`, `Debouncer`, `SearchHandlerMixin`, `CacheManager`, `StoredNetworkImage`, `MotionDetector`. |
| [docs/misc.md](./docs/misc.md) | `SharedPreferencesManager`, `KeyManager`, `IsolateHandler`, route transitions, `Time`/`TimeRange`/`TimePeriod`, `PeriodicTimer`, media typedefs, resource strings. |

Every doc starts with its own **File Registry** and **Index** — use them for quick navigation.

---

## Why Codepan

Three goals, in priority order:

1. **Eliminate boilerplate.** Most "new" code in a project should be three lines of glue between codepan classes. If a project ends up with its own SQLite adapter, custom `BlocBuilder`, or hand-rolled HTTP plumbing, that's a regression.
2. **Centralize design decisions.** Typography (`PanText`), spacing (`Dimension`), error messages (`Errors`), permission flows (`PermissionState`), database transactions (`SqliteBinder`) — all live here. Change once, propagate everywhere.
3. **Standardize patterns across projects.** Every codepan project has the same shape: `bloc/`, `data/database/`, `data/models/`, `data/services/`, `http/requests/`, `widgets/`. Onboarding becomes a 1-day affair.

When a feature is genuinely missing, **extend codepan** rather than duplicating. PRs back to this library beat one-off implementations every time.

---

## Adding Codepan to a Project

In your project's `pubspec.yaml`:

```yaml
dependencies:
  codepan:
    path: ../codepan          # or git: { url: ..., ref: ... }
```

Most transitive dependencies (`flutter_bloc`, `equatable`, `sqflite_sqlcipher`, `http`, `shared_preferences`, `path_provider`, `sensors_plus`, `permission_handler`, `geolocator`, `geocoding`, `google_maps_flutter`, `latlong2`, `connectivity_plus`, `url_launcher`, `intl`, `flutter_svg`, `image`, `image_compression`, `cryptography`, `crypto`, `pull_to_refresh_flutter3`, `time_ago_provider`, `inflection3`, `html_unescape`, `uuid`, `package_info_plus`, `app_settings`) are already declared by codepan and need not be redeclared.

> Windows: ship `sqlite3.dll` next to your binary and pass its path via `SqliteCache.getDatabase(libraryPath: 'sqlite3.dll')`.

---

## Module Map

```
codepan/
├── bloc/                  → docs/bloc.md
├── data/
│   ├── database/          → docs/database.md
│   ├── factories/         → docs/data_models.md
│   ├── models/            → docs/data_models.md
│   └── services/          → docs/database.md (services section)
├── http/
│   ├── requests/          → docs/http.md
│   └── handlers.dart      → docs/http.md
├── widgets/
│   ├── dialogs/           → docs/widgets.md (dialogs section)
│   ├── states/            → docs/widgets.md (page lifecycle section)
│   └── *.dart             → docs/widgets.md
├── extensions/            → docs/extensions.md
├── utils/                 → docs/utils.md
├── storage/               → docs/misc.md
├── security/              → docs/misc.md
├── isolate/               → docs/misc.md
├── time/                  → docs/misc.md
├── transitions/           → docs/misc.md
├── media/                 → docs/misc.md
└── resources/             → docs/widgets.md + docs/misc.md
```

---

## The Layered Architecture

A typical screen in a codepan-backed project flows like this:

```
            ┌─────────────────────────────────────┐
            │           UI (widgets/)             │   ← PageBlocBuilder + PanText/PanIcon/...
            └──────────────────┬──────────────────┘
                               │ events / states
            ┌──────────────────▼──────────────────┐
            │      BLoC layer (codepan/bloc/)     │   ← ParentBloc / ParentEvent / ParentState
            └──────────────────┬──────────────────┘
                               │ calls
            ┌──────────────────▼──────────────────┐
   HTTP ◀───┤   Services (lib/data/services/)     ├───▶ Database
            └──────────────────┬──────────────────┘
                               │ rows
            ┌──────────────────▼──────────────────┐
            │ Models (lib/data/models/entities/)  │   ← MasterData / TransactionData
            └──────────────────┬──────────────────┘
                               │ schema
            ┌──────────────────▼──────────────────┐
            │  Schema (lib/data/database/schema)  │   ← DatabaseSchema / DatabaseEntity
            └─────────────────────────────────────┘
```

Cross-cutting helpers (`extensions/`, `utils/`, `storage/`, `security/`) sit beside this stack and are imported wherever needed.

---

## Conventions That Apply Everywhere

### Files and naming

| Item | Rule |
| :--- | :--- |
| File names | `snake_case.dart`, singular for entities (`user.dart`), plural only for collections of unrelated symbols. |
| Class names | `PascalCase`. Suffix conventions: `Data` (entity), `Service` (per-table logic), `Request` (HTTP), `Bloc`/`Event`/`State` (state mgmt). |
| Boolean column or field | Prefix with `is*`/`has*`/`with*`/`did*`/`can*`. `MapUtils.get` auto-parses these to bool. |
| Date/time columns | Split into `dateX` and `timeX` (`dateCreated` + `timeCreated`). |

### Code style

- **Trailing commas** on every multi-arg constructor/function — keeps diffs clean.
- Always declare `final d = Dimension.of(context);` as the first line of `build` and use `d.at(value)` for every literal size, padding, font.
- Always use `PanText` (or your project's typography wrapper) — never bare `Text`.
- Always use `PanIcon` for SVG icons.
- Don't nest a `Scaffold` under `PageBlocBuilder` / `PageBuilder` — they include one.
- `context.blocOf<T>()` over `BlocProvider.of<T>(context)`.
- All HTTP request classes go through `GetRequest` / `PostRequest` / etc.
- All DB writes go through `SqliteBinder.transact`.
- All page-level state lives in a `ParentBloc<E,S>`. No `setState` for business logic.

### SOLID

The library is built around SOLID; keep your project's code aligned:

- **SRP** — every class does one thing. Don't bolt parsing onto a service or DB writes onto a widget.
- **OCP** — extend codepan classes; don't fork them.
- **LSP** — every `MasterData`/`TransactionData`/`Selectable` should be substitutable.
- **ISP** — prefer the smallest base class that fits (`TransactionData` over `MasterData` if you don't need `webId`/`name`).
- **DIP** — depend on `codepan` abstractions (`SqliteAdapter`, `Client`, `ServiceFor<T>`); inject through constructors. Mock those abstractions in tests, not the concrete sqlite or http clients.

---

## Suggested Reading Order

For a new contributor (or a fresh Claude Code session) onboarding to a codepan-backed project:

1. **README.md (this file)** — orientation.
2. **[docs/bloc.md](./docs/bloc.md)** — every page touches this.
3. **[docs/database.md](./docs/database.md)** — the schema/binder/query pattern is the single biggest area to learn.
4. **[docs/data_models.md](./docs/data_models.md)** — pairs with `database.md`; covers the `MasterData`/`TransactionData` split.
5. **[docs/http.md](./docs/http.md)** — request classes and the persist-on-success pattern.
6. **[docs/widgets.md](./docs/widgets.md)** — pick this up while building the first screen.
7. **[docs/extensions.md](./docs/extensions.md)** — quick reference; many helpers are invoked silently by other modules.
8. **[docs/utils.md](./docs/utils.md) / [docs/misc.md](./docs/misc.md)** — reach for these as needed.

---

## Where Project-Specific Docs Live

The `docs/` directory documents **codepan**. Each consumer project has its own `docs/` with project-specific architecture, schema, and tasks. Typical structure (Tarkie example):

```
<project>/docs/
├── architecture.md      project flavors, folder structure, brand-specific patterns
├── contracts.md         project-specific contracts on top of codepan
├── decisions.md         project-level technical decisions
├── tasks.md             current work
├── frontend.md          page/typography conventions for this brand
├── http_request.md      project-specific HTTP rules referencing codepan/http.md
├── models.md            project-specific entity/service registry
└── prompts/             generation prompts that delegate to codepan/docs/*
```

Pattern: project docs **reference** codepan docs — they don't duplicate them. When generating code, Claude Code should:

1. Read the codepan doc for the module being touched (in this repo's `docs/` directory).
2. Read the project's matching doc (e.g. `models.md`) for project-specific names/conventions.
3. Compose existing codepan classes; only write new code where neither codepan nor the project provides what's needed.

If you find yourself implementing something codepan should already handle, file an issue or add a PR to codepan first.
