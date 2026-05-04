# Data Models Module

How to build data classes for codepan-backed projects: `EntityData`, `TransactionData`, `MasterData`, plus optional `BaseFactory<T>`, `PairData`, and `ProgressData`. These types live in `codepan/data/models/*` and `codepan/data/factories/*`.

A correct data model is the contract between your **schema** ([database.md](./database.md)), your **service** layer, and your **HTTP/JSON** layer ([http.md](./http.md)). Get it right and inserts, updates, sync-back, and rendering all come "for free."

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [Class Hierarchy](#class-hierarchy)
3. [`EntityData` — The Root](#entitydata--the-root)
4. [`TransactionData` — Rows You Can Write](#transactiondata--rows-you-can-write)
5. [`MasterData` — Rows With `webId` and `name`](#masterdata--rows-with-webid-and-name)
6. [Linking a Model to its Schema (`schemaInstance`)](#linking-a-model-to-its-schema-schemainstance)
7. [`toMap` and `filtered`](#tomap-and-filtered)
8. [`fromJson` Factories](#fromjson-factories)
9. [`copyWith`](#copywith)
10. [`insertForId` and `insert` Helpers](#insertforid-and-insert-helpers)
11. [`BaseFactory<T>` — JSON → Entity Conversion](#basefactoryt--json--entity-conversion)
12. [`PairData<T1, T2>`](#pairdatat1-t2)
13. [`ProgressData`](#progressdata)
14. [Naming Conventions](#naming-conventions)
15. [End-to-End Example](#end-to-end-example)

---

## File Registry

| File | Symbols | Purpose |
| :--- | :--- | :--- |
| `codepan/data/models/entities/entity.dart` | `EntityData`, `ParentToChild` | Root abstract class, links to `TableSchema`. |
| `codepan/data/models/entities/transaction.dart` | `TransactionData` | Adds `id`, `dateCreated`, `timeCreated`, `dateUpdated`, `timeUpdated`, `isDeleted`, `toMap`, `toStatement`, `insert`, `insertForId`, `compareTo`. |
| `codepan/data/models/entities/master.dart` | `MasterData` | Adds `webId`, `name`, search/select integration. |
| `codepan/data/models/pair_data.dart` | `PairData<T1, T2>` | Generic 2-tuple. |
| `codepan/data/models/progress.dart` | `ProgressData` | Progress (current/max) container. |
| `codepan/data/factories/base_factory.dart` | `BaseFactory<T extends EntityData>` | JSON-to-entity conversion contract. |

---

## Class Hierarchy

```
EntityData                        (Equatable, links to TableSchema)
└── TransactionData               (id, audit columns, isDeleted, toMap, toStatement)
    └── MasterData                (webId, name, Selectable, Searchable)
```

Practical rule of thumb:

- Use **`MasterData`** for tables that map to a server-side primary entity (Users, Stores, Forms, Roles…). They almost always have a server-issued `webId` and a display `name`.
- Use **`TransactionData`** for purely-local tables (cached log entries, sync queues) and for entities that don't have a `name` in the human sense.
- Use **`EntityData`** only as a base class — you almost never instantiate it directly.

---

## `EntityData` — The Root

```dart
abstract class EntityData extends Equatable {
  const EntityData();
  TableSchema get schemaInstance;
  String get table => schemaInstance.tableName;
  String? get unique => schemaInstance.unique;
  List<String>? get uniqueGroup => schemaInstance.uniqueGroup;
}
```

`EntityData` ties a Dart class to a database table by exposing `schemaInstance`. Subclasses get `table`, `unique`, `uniqueGroup` for free — used by `SqliteBinder.insertData`, `SqliteBinder.updateData`, etc.

`ParentToChild<P>` is a tiny optional helper for parent classes that should produce typed "children" (rare; you'll know if you need it).

---

## `TransactionData` — Rows You Can Write

```dart
abstract class TransactionData extends EntityData
    implements Comparable<TransactionData> {
  final String? dateCreated, timeCreated, dateUpdated, timeUpdated;
  final bool? isDeleted;
  final int? id;
  // ...
}
```

Anything you can `INSERT`/`UPDATE`/`DELETE` in the local DB extends this class. It contributes:

| Member | Purpose |
| :--- | :--- |
| `id`, `dateCreated`, `timeCreated`, `dateUpdated`, `timeUpdated`, `isDeleted` | Audit columns. |
| `hasId` | `id != null && id != 0`. |
| `createdAt`, `updatedAt` | Convenience `Time` getters. |
| `compareTo(other)` | Sort by `createdAt` descending. |
| `toMap()` *(abstract)* | Serialize for `INSERT`/`UPDATE`. |
| `toStatement()` | `SqliteStatement.fromMap(toMap())`. |
| `copyWith({...})` *(abstract)* | Standard Dart copyWith pattern. |
| `insertForId(binder)` | Async; returns a copy with `id`/`dateCreated`/`timeCreated` populated. |
| `insert(binder)` | Async; returns the row's `id`. |
| Built-in Equatable `props => [id]` | Two `TransactionData` are equal iff they share `id`. |

### Minimal subclass

```dart
class EventLogData extends TransactionData {
  final String? type;
  final String? payload;

  const EventLogData({
    super.id,
    super.dateCreated,
    super.timeCreated,
    super.dateUpdated,
    super.timeUpdated,
    super.isDeleted,
    this.type,
    this.payload,
  });

  static const _schema = TableSchema(AppSchema(), Tb.eventLogs);

  @override
  TableSchema get schemaInstance => _schema;

  @override
  Map<String, dynamic> toMap() => filtered({
        'type': type,
        'payload': payload,
      });

  @override
  EventLogData copyWith({
    int? id,
    String? dateCreated,
    String? timeCreated,
    String? dateUpdated,
    String? timeUpdated,
    bool? isDeleted,
    String? type,
    String? payload,
  }) {
    return EventLogData(
      id: id ?? this.id,
      dateCreated: dateCreated ?? this.dateCreated,
      timeCreated: timeCreated ?? this.timeCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      timeUpdated: timeUpdated ?? this.timeUpdated,
      isDeleted: isDeleted ?? this.isDeleted,
      type: type ?? this.type,
      payload: payload ?? this.payload,
    );
  }
}
```

---

## `MasterData` — Rows With `webId` and `name`

```dart
abstract class MasterData extends TransactionData implements Selectable {
  final int? webId;
  final String? name;
  // ...
}
```

`MasterData` adds two semantically important columns:

- **`webId`** — server-side primary key. Used to detect "is this row already synced?" via `hasWebId`. After a successful POST, set this from the API response.
- **`name`** — human-readable label. Powers `Selectable.title`, `Searchable.searchable`, and list rendering.

`MasterData` also implements:

- `Selectable` (from `codepan/widgets/dialogs/menu_dialog.dart`) → `title`, `identifier`. Lets you pass any `MasterData` to codepan's menu/selector dialogs without adapter code.
- `Searchable` (from `codepan/utils/search_handler.dart`) → `searchable: [name]`. Lets `SearchHandlerMixin` filter your list by typed text.

Override these getters if your model needs richer search/labeling:

```dart
@override
String? get title => '$firstName $lastName';

@override
List<String?> get searchable => [firstName, lastName, email];
```

`props` defaults to `[webId]` — so two `MasterData` are "equal" iff they share `webId`. **Override `props`** if you have other identity fields, or if the same row may exist with `webId == null` before sync.

---

## Linking a Model to its Schema (`schemaInstance`)

Every concrete model **must** declare a `static const _schema` and override `schemaInstance`:

```dart
static const _schema = TableSchema<Tb>(AppSchema(), Tb.users);

@override
TableSchema get schemaInstance => _schema;
```

That single line gives you `table`, `unique`, `uniqueGroup`, used by every `SqliteBinder` write. If `schemaInstance` doesn't match the actual table you intend to write to, your inserts will silently land in the wrong table — debug by `print(schemaInstance.tableName)`.

---

## `toMap` and `filtered`

`TransactionData.toMap()` serializes the row for SQLite. The trick: codepan's binder uses `SqliteStatement.fromMap` which writes `field = NULL` for any null value, *except* when the value isn't in the map at all — in which case the column keeps its existing value during upserts. That's why you typically `..clean()` or `filtered({...})` to drop nulls.

### `MasterData.filtered`

`MasterData.filtered({extras})` is the canonical helper. It merges your fields into the base map (`id, dateCreated, timeCreated, dateUpdated, timeUpdated, isDeleted, webId, name`) and drops every `null` entry:

```dart
@override
Map<String, dynamic> toMap() => filtered({
      'email': email,
      'roleId': role?.id,
      'isActive': isActive,
    });
```

For `TransactionData` (no `webId`/`name`), use the protected `filtered({...})` from `transaction.dart` (which calls `..clean()` from `extensions/map.dart`). The behavior is identical.

> If you intentionally want to set a column to `NULL`, build the map manually instead of using `filtered`.

---

## `fromJson` Factories

For HTTP responses, expose a `fromJson` factory on your model. Use the codepan `MapUtils` extensions (`getInt`, `getDouble`, `getBool`, `get`, etc.) to parse loose JSON into typed fields:

```dart
factory UserData.fromJson(Map<String, dynamic> json) {
  return UserData(
    id: json.getInt('id'),
    webId: json.getInt('webId'),
    name: json.get('name'),
    email: json.get('email'),
    isActive: json.getBool('isActive'),
    role: json.hasKey('role') ? RoleData.fromJson(json['role']) : null,
    dateCreated: json.get('dateCreated'),
    timeCreated: json.get('timeCreated'),
  );
}
```

Notice:
- `getInt` / `getDouble` / `getBool` parse loose strings into the right types.
- `get` returns the trimmed string for text fields, parses bool when the key starts with `is`/`has`/`with`/`did`/`can`, or returns the raw value otherwise.
- For nested objects, recurse with the child's own `fromJson`.

When the API uses prefixed keys (e.g. `user_id`, `user_name`), use `setPrefix` once at the start of the parsing call:

```dart
factory UserData.fromJson(Map<String, dynamic> json) {
  json.setPrefix('user', separator: '_');
  return UserData(
    id: json.getInt('id'),       // reads 'user_id'
    name: json.get('name'),       // reads 'user_name'
  );
}
```

See [extensions.md](./extensions.md) for the full `MapUtils` API.

---

## `copyWith`

`TransactionData.copyWith` is abstract. Override on every concrete subclass; **always include the parent's audit fields** so `SqliteBinder.insertForId` can refresh `id`/`dateCreated`/`timeCreated`:

```dart
@override
UserData copyWith({
  int? id,
  String? dateCreated,
  String? timeCreated,
  String? dateUpdated,
  String? timeUpdated,
  bool? isDeleted,
  int? webId,
  String? name,
  String? email,
  bool? isActive,
  RoleData? role,
}) {
  return UserData(
    id: id ?? this.id,
    dateCreated: dateCreated ?? this.dateCreated,
    timeCreated: timeCreated ?? this.timeCreated,
    dateUpdated: dateUpdated ?? this.dateUpdated,
    timeUpdated: timeUpdated ?? this.timeUpdated,
    isDeleted: isDeleted ?? this.isDeleted,
    webId: webId ?? this.webId,
    name: name ?? this.name,
    email: email ?? this.email,
    isActive: isActive ?? this.isActive,
    role: role ?? this.role,
  );
}
```

> **Rule:** every nullable field must use `?? this.<field>`. If you ever need to *clear* a field via copyWith, add a sentinel parameter — codepan does not provide one out of the box.

---

## `insertForId` and `insert` Helpers

```dart
final newUser = await user.insertForId<UserData>(binder);
//   ^ a copy of `user` with id, dateCreated, timeCreated populated.

final id = await user.insert(binder);
//   ^ Future<int?> — just the row id.
```

Both delegate to `SqliteBinder.insertData` / `SqliteBinder.insertForId`, so they use the upsert behavior tied to `unique` / `uniqueGroup`. Pass `priority: UpdatePriority.uniqueGroup` to flip preference. See [database.md](./database.md#writing-sqlitebinder-and-transactions).

---

## `BaseFactory<T>` — JSON → Entity Conversion

When the conversion logic is non-trivial (multiple keys feed one field, derived fields, polymorphic types), put it in a `BaseFactory<T>` instead of crowding `fromJson`:

```dart
abstract class BaseFactory<T extends EntityData> {
  final Map<String, dynamic> map;
  const BaseFactory(this.map);
  T create() => convert(map);
  @protected T convert(Map<String, dynamic> json);
}
```

```dart
class UserFactory extends BaseFactory<UserData> {
  const UserFactory(super.map);

  @override
  UserData convert(Map<String, dynamic> json) {
    return UserData(
      id: json.getInt('id'),
      webId: json.getInt('webId'),
      name: '${json.get('firstName') ?? ''} ${json.get('lastName') ?? ''}'.trim(),
      email: json.get('email'),
    );
  }
}

// Use:
final user = UserFactory(json).create();
```

When to prefer a factory over `fromJson`:

- The conversion is reused across multiple call sites with slightly different inputs.
- The conversion mutates state outside the entity (caching, ID lookups).
- You want to test the conversion in isolation.

For most simple maps, a `factory Foo.fromJson(...)` constructor is enough.

---

## `PairData<T1, T2>`

A typed two-tuple. Useful when a method returns two related values:

```dart
class PairData<T1, T2> {
  final T1 data1;
  final T2 data2;
  const PairData({required this.data1, required this.data2});
}

Future<PairData<UserData, List<InvoiceData>>> loadDashboard() async {
  return PairData(data1: await loadUser(), data2: await loadInvoices());
}
```

Stick to `PairData` for return values that are too small for a dedicated class. For three or more, prefer a real class.

---

## `ProgressData`

Used by progress dialogs and any `ParentBloc` that wants to publish "x of y" state.

```dart
class ProgressData {
  final int? current;
  final int? max;
  String get value => '$current/$max';                 // e.g. '12/40'
  String get percentValue => PanUtils.getPercentage(current!, max!);  // '30%'
  double get percentage => current!.toDouble() / max!.toDouble();
  static const zero = ProgressData(current: 0, max: 0);
}
```

```dart
emit(SyncInProgress(progress: ProgressData(current: i, max: total)));
```

Pair it with `ProgressDialog` from `codepan/widgets/dialogs/progress_dialog.dart` (see [widgets.md](./widgets.md)).

---

## Naming Conventions

| Item | Convention | Example |
| :--- | :--- | :--- |
| `Tb` enum value | lowerCamelCase, plural | `users`, `invoiceItems` |
| Entity class | PascalCase + `Data` | `UserData`, `InvoiceItemData` |
| Service class | PascalCase + `Service` | `UserService` |
| File name | snake_case singular | `user.dart`, `invoice_item.dart` |
| Factory class | PascalCase + `Factory` | `UserFactory` |
| `webId` | always camelCase, `int?` | `final int? webId;` |
| Boolean column | `is*`, `has*`, `with*` | `isActive`, `hasMedia`, `withReceipt` |
| Date/time column | split into `dateX` + `timeX` | `dateCreated` + `timeCreated` |

---

## End-to-End Example

A `RoleData` (master) and a `UserData` (master) that references it.

```dart
// lib/data/models/entities/role.dart
class RoleData extends MasterData {
  final String? code;

  const RoleData({
    super.id,
    super.webId,
    super.name,
    super.dateCreated,
    super.timeCreated,
    super.dateUpdated,
    super.timeUpdated,
    super.isDeleted,
    this.code,
  });

  static const _schema = TableSchema<Tb>(AppSchema(), Tb.roles);

  @override
  TableSchema get schemaInstance => _schema;

  @override
  Map<String, dynamic> toMap() => filtered({'code': code});

  factory RoleData.fromJson(Map<String, dynamic> json) => RoleData(
        webId: json.getInt('id'),
        name: json.get('name'),
        code: json.get('code'),
      );

  @override
  RoleData copyWith({
    int? id, int? webId, String? name, String? code,
    String? dateCreated, String? timeCreated,
    String? dateUpdated, String? timeUpdated,
    bool? isDeleted,
  }) =>
      RoleData(
        id: id ?? this.id,
        webId: webId ?? this.webId,
        name: name ?? this.name,
        code: code ?? this.code,
        dateCreated: dateCreated ?? this.dateCreated,
        timeCreated: timeCreated ?? this.timeCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        timeUpdated: timeUpdated ?? this.timeUpdated,
        isDeleted: isDeleted ?? this.isDeleted,
      );
}

// lib/data/models/entities/user.dart
class UserData extends MasterData {
  final String? email;
  final bool? isActive;
  final RoleData? role;

  const UserData({
    super.id,
    super.webId,
    super.name,
    super.dateCreated,
    super.timeCreated,
    super.dateUpdated,
    super.timeUpdated,
    super.isDeleted,
    this.email,
    this.isActive,
    this.role,
  });

  static const _schema = TableSchema<Tb>(AppSchema(), Tb.users);

  @override
  TableSchema get schemaInstance => _schema;

  @override
  Map<String, dynamic> toMap() => filtered({
        'email': email,
        'isActive': isActive,
        'roleId': role?.id,
      });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        webId: json.getInt('id'),
        name: json.get('name'),
        email: json.get('email'),
        isActive: json.getBool('isActive'),
        role: json.hasKey('role')
            ? RoleData.fromJson(json['role'])
            : null,
      );

  @override
  List<String?> get searchable => [name, email];

  @override
  UserData copyWith({
    int? id, int? webId, String? name, String? email,
    bool? isActive, RoleData? role,
    String? dateCreated, String? timeCreated,
    String? dateUpdated, String? timeUpdated,
    bool? isDeleted,
  }) =>
      UserData(
        id: id ?? this.id,
        webId: webId ?? this.webId,
        name: name ?? this.name,
        email: email ?? this.email,
        isActive: isActive ?? this.isActive,
        role: role ?? this.role,
        dateCreated: dateCreated ?? this.dateCreated,
        timeCreated: timeCreated ?? this.timeCreated,
        dateUpdated: dateUpdated ?? this.dateUpdated,
        timeUpdated: timeUpdated ?? this.timeUpdated,
        isDeleted: isDeleted ?? this.isDeleted,
      );
}
```

This snippet covers everything you need: schema link, `toMap`+`filtered`, `fromJson`, `copyWith`, foreign-key nesting, `searchable`. Apply the same pattern to every table.
