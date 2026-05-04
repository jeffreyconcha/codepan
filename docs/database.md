# Database Module

How to use codepan's SQLite layer (`codepan/data/database/*` and `codepan/data/services/*`) to define a schema, open a database, run queries, write transactions, and define services for each table. Codepan uses [`sqflite_sqlcipher`](https://pub.dev/packages/sqflite_sqlcipher) on Android/iOS and [`sqflite_common_ffi`](https://pub.dev/packages/sqflite_common_ffi) + `sqlite3` on Windows/macOS, all behind a single `SqliteAdapter` API.

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [Module Overview](#module-overview)
3. [The Six Concepts](#the-six-concepts)
4. [Step 1 — Define `DatabaseEntity`](#step-1--define-databaseentity)
5. [Step 2 — Define `DatabaseSchema`](#step-2--define-databaseschema)
6. [Step 3 — Define `DatabaseInitializer`](#step-3--define-databaseinitializer)
7. [Step 4 — Open the Database via `SqliteCache`](#step-4--open-the-database-via-sqlitecache)
8. [`Field` — Column Definitions and Factories](#field--column-definitions-and-factories)
9. [`Table` and `TableSchema`](#table-and-tableschema)
10. [Reading: `SqliteAdapter`](#reading-sqliteadapter)
11. [Building Queries: `SqliteQuery`](#building-queries-sqlitequery)
12. [`Condition` — `WHERE` Clauses](#condition--where-clauses)
13. [Writing: `SqliteBinder` and Transactions](#writing-sqlitebinder-and-transactions)
14. [`SqliteStatement` — Low-level SQL Generator](#sqlitestatement--low-level-sql-generator)
15. [Services — `ServiceFor<T>`](#services--servicefort)
16. [Database/Model/Service Triad](#databasemodelservice-triad)
17. [Schema Migrations](#schema-migrations)
18. [Logging Transactions](#logging-transactions)
19. [Error Handling](#error-handling)
20. [Common Pitfalls](#common-pitfalls)

---

## File Registry

| File | Symbols | Purpose |
| :--- | :--- | :--- |
| `codepan/data/database/schema.dart` | `DatabaseEntity`, `DatabaseSchema`, `TableSchema` | Schema definition and table introspection. |
| `codepan/data/database/initializer.dart` | `DatabaseInitializer`, `DefaultDatabaseInitializer` | Hook for `onCreate`/`onUpgrade`/`onDowngrade`. |
| `codepan/data/database/sqlite_adapter.dart` | `SqliteAdapter` | Database connection, query, helper APIs. |
| `codepan/data/database/sqlite_cache.dart` | `SqliteCache` | Process-wide cache of open `SqliteAdapter` instances. |
| `codepan/data/database/sqlite_binder.dart` | `SqliteBinder`, `UpdatePriority`, `BinderBody` | Batched/transactional writes. |
| `codepan/data/database/sqlite_query.dart` | `SqliteQuery`, `JoinType`, `JoinOption`, `Order`, `RecursiveJoin` | `SELECT` builder w/ joins, ordering, paging. |
| `codepan/data/database/sqlite_statement.dart` | `SqliteStatement` | Low-level DDL/DML generator. |
| `codepan/data/database/sqlite_exception.dart` | `SqliteException` | Standard error messages and codes. |
| `codepan/data/database/models/field.dart` | `Field`, `Constraint`, `DataType`, `SqliteFunction` | Column model and constraints. |
| `codepan/data/database/models/condition.dart` | `Condition`, `Operator`, `Scan` | Where-clause model. |
| `codepan/data/database/models/table.dart` | `Table` (codepan's, not `package:flutter/material.dart`) | Table model with auto-aliasing. |
| `codepan/data/database/models/field_value.dart` | `FieldValue`, `SqliteTime` | Field+value pair, plus DB-side `date('now', 'localtime')`. |
| `codepan/data/database/models/sqlite_model.dart` | `SqliteModel` | Base class for `Field`/`Condition`/`FieldValue`. |
| `codepan/data/database/mixin/query_properties.dart` | `QueryProperties` | Shared field/condition list logic. |
| `codepan/data/services/service.dart` | `ServiceFor<T>`, `Parser<T>` | Per-table service base class. |

---

## Module Overview

Codepan's database stack has six layers, from highest to lowest level:

```
┌──────────────────────────────────────────────────────┐
│ ServiceFor<T>          // business logic per table   │
├──────────────────────────────────────────────────────┤
│ SqliteBinder           // batched/transactional ops  │
├──────────────────────────────────────────────────────┤
│ SqliteQuery / Condition // SELECT builder            │
├──────────────────────────────────────────────────────┤
│ SqliteStatement        // raw DDL/DML strings        │
├──────────────────────────────────────────────────────┤
│ SqliteAdapter          // connection + helpers       │
├──────────────────────────────────────────────────────┤
│ DatabaseSchema / DatabaseEntity / Field // metadata  │
└──────────────────────────────────────────────────────┘
```

Most app code lives in the top three layers. You only drop down to `SqliteStatement` for unusual DDL needs.

---

## The Six Concepts

| Concept | Type | Purpose |
| :--- | :--- | :--- |
| Entity | enum implementing `DatabaseEntity` | Logical name of a table (`Tb.users`, `Tb.invoices`). |
| Schema | `DatabaseSchema<E>` | Maps each entity to its `Field` list. |
| TableSchema | `TableSchema<E>` | View of one table's metadata: name, alias, fields, FKs, indices, triggers. |
| Adapter | `SqliteAdapter` | Open connection + read/write APIs. |
| Binder | `SqliteBinder` | Wraps a `Batch` for atomic writes. |
| Service | `ServiceFor<T>` | Per-table business logic and parsing. |

---

## Step 1 — Define `DatabaseEntity`

`DatabaseEntity` is a contract. Make a Dart `enum` that implements it. The `dbName` typically equals the database file name; `version` and `count` are kept on each enum for completeness.

```dart
import 'package:codepan/data/database/schema.dart';

enum Tb implements DatabaseEntity {
  users,
  roles,
  invoices,
  invoiceItems;

  @override String get dbName => 'app.db';
  @override int get version => 1;
  @override int get count => Tb.values.length;
}
```

Naming: lowerCamelCase. Codepan converts each entity name to `snake_case` and appends `_tb`/`_idx`/`_trg` suffixes:

| Entity        | Table name      | Index name      | Trigger name    |
| :------------ | :-------------- | :-------------- | :-------------- |
| `users`       | `users_tb`      | `users_idx`     | `users_trg`     |
| `invoiceItems`| `invoice_items_tb` | `invoice_items_idx` | `invoice_items_trg` |

---

## Step 2 — Define `DatabaseSchema`

Subclass `DatabaseSchema<Tb>` and provide the field list per entity:

```dart
class AppSchema extends DatabaseSchema<Tb> {
  const AppSchema();

  @override
  List<Tb> get entities => Tb.values;

  @override
  List<Field> fields(Tb entity) {
    switch (entity) {
      case Tb.users:
        return [
          Field.primaryKey(),                                   // id INTEGER PRIMARY KEY
          Field.unique('email', type: DataType.text),           // email TEXT UNIQUE
          Field.column('name', type: DataType.text),
          Field.column('isActive', type: DataType.integer).ug(),// part of unique group
          Field.autoUpdateDate('dateUpdated'),                  // auto via trigger
          Field.autoUpdateTime('timeUpdated'),
          Field.defaultDate('dateCreated'),
          Field.defaultTime('timeCreated'),
          Field.defaultValue('isDeleted', value: false),
        ];
      case Tb.roles:
        return [
          Field.primaryKey(),
          Field.column('name', type: DataType.text),
        ];
      case Tb.invoices:
        return [
          Field.primaryKey(),
          Field.foreignKey('userId', at: at(Tb.users)),
          Field.defaultValue('isPaid', value: false),
          Field.column('amount', type: DataType.real),
        ];
      case Tb.invoiceItems:
        return [
          Field.primaryKey(),
          Field.foreignKey('invoiceId', at: at(Tb.invoices)),
          Field.column('description', type: DataType.text),
          Field.column('quantity', type: DataType.integer),
        ];
    }
  }
}
```

**What you get for free:**

- `schema.tableName(entity)` / `schema.indexName(entity)` / `schema.triggerName(entity)`
- `schema.indices(entity)`, `schema.triggers(entity)` (auto-derived from `Field` flags)
- `schema.foreignKeys(entity)`, `schema.references(entity)`
- `schema.unique(entity)`, `schema.uniqueGroup(entity)`
- `schema.of(entity)` returns a `TableSchema<Tb>` — pass this to `SqliteQuery.all`, `db.recordOf`, etc.

---

## Step 3 — Define `DatabaseInitializer`

The initializer is called by `SqliteAdapter` exactly once per (db file × version change). Codepan ships a `DefaultDatabaseInitializer` that creates/updates tables, indices, and triggers from the schema for you. Subclass it and add any **app-level** seeding/migration logic in `onDatabaseCreated` / `onDatabaseUpdated`.

```dart
class AppInitializer extends DefaultDatabaseInitializer {
  const AppInitializer() : super(const AppSchema());

  @override
  Future<void> onDatabaseCreated(SqliteAdapter db, int version) async {
    // Optional: seed default rows.
    final binder = SqliteBinder.of(db);
    await binder.transact<bool>(
      body: (binder) async {
        binder.addStatement("INSERT INTO roles_tb (id, name) VALUES (1, 'admin')");
      },
    );
  }

  @override
  Future<void> onDatabaseUpdated(SqliteAdapter db, int oldVersion, int newVersion) async {
    // Optional: run version-specific migrations.
  }
}
```

If you need direct control over `onCreate`/`onUpgrade`/`onDowngrade` (e.g. to skip default DDL), extend the base `DatabaseInitializer` instead.

---

## Step 4 — Open the Database via `SqliteCache`

```dart
import 'package:codepan/data/database/sqlite_cache.dart';

Future<SqliteAdapter> openAppDb() {
  return SqliteCache.getDatabase(
    name: 'app.db',
    password: 'your-secret',          // SQLCipher key
    version: 1,
    initializer: const AppInitializer(),
    libraryPath: 'sqlite3.dll',       // Required only on Windows
  );
}
```

Notes:

- `SqliteCache` keeps one `SqliteAdapter` per `name` for the whole process. Subsequent calls return the same instance.
- The DB file is stored under `getApplicationDocumentsDirectory()` (mobile) or `getApplicationSupportDirectory()` (desktop), with a `data/` subdirectory on desktop.
- `password` is the SQLCipher passphrase. To use an unencrypted DB, pass an empty string and remove the `PRAGMA KEY` flow if you fork the adapter.

---

## `Field` — Column Definitions and Factories

`Field` is the single source of truth for each column. Use the named factories instead of the bare constructor whenever possible.

| Factory | Generates |
| :--- | :--- |
| `Field.primaryKey([name='id'])` | `id INTEGER PRIMARY KEY NOT NULL` |
| `Field.column(name, type:)` | `name TYPE` |
| `Field.unique(name, type: DataType.integer)` | `name TYPE UNIQUE` |
| `Field.foreignKey(name, at: someTable)` | `name INTEGER REFERENCES someTable(id)` |
| `Field.defaultValue(name, value:)` | `name TYPE DEFAULT <value>` |
| `Field.date(name)` / `Field.time(name)` | `name TEXT CHECK(...)` |
| `Field.defaultDate(name)` / `Field.defaultTime(name)` | `... DEFAULT date('now','localtime')` |
| `Field.autoUpdateDate(name)` / `Field.autoUpdateTime(name)` | Same as `date`/`time` plus `withDateTrigger` / `withTimeTrigger` flag, so the codepan trigger auto-updates the column on row update. |
| `Field.uniqueDate(name)` / `Field.uniqueTime(name)` | Date/time column with `UNIQUE`. |
| `Field.order(field:, order: Order.descending)` | Used in `orderBy`, not table creation. |
| `Field.count(name)` / `Field.sum(name)` | Aggregate select fields. |

### `.ug()` — Unique group

Mark several non-unique columns as members of a composite unique group:

```dart
Field.column('storeId', type: DataType.integer).ug(),
Field.column('userId',  type: DataType.integer).ug(),
```

Codepan emits `UNIQUE (storeId, userId)` in the table definition. `SqliteBinder.insertData` automatically uses the unique group to upsert.

### `Constraint` enum

You rarely use this directly — the factories cover every constraint. The enum exists in case you need `Field(field: ..., constraints: [Constraint.notNull])`:

`primaryKey, foreignKey, defaultField, unique, dateFormatted, timeFormatted, notNull`.

### `DataType` enum

`integer, text, real, blob`.

---

## `Table` and `TableSchema`

`Table` is **codepan's** type — when importing it alongside `package:flutter/material.dart`, alias it:

```dart
import 'package:codepan/data/database/models/table.dart' as tb;
final usersTable = tb.Table('users_tb', entity: Tb.users);
```

Auto-generated alias: `Table('invoice_items_tb').alias` → `invItm` (first letter + max 3 consonants from each word). Aliases are deterministic and used internally for joins.

`TableSchema<E>` is a typed view onto a single table within a `DatabaseSchema`:

```dart
final schema = const AppSchema();
final users = schema.of(Tb.users);  // TableSchema<Tb>

users.tableName;     // 'users_tb'
users.alias;         // 'usrs'
users.fields;        // List<Field>
users.foreignKeys;   // List<Field> with isForeignKey
users.unique;        // 'email'
users.uniqueGroup;   // null or List<String>
users.references;    // List<TableSchema> the FK targets
```

Pass `TableSchema` (not `Table`) wherever a query/binder accepts `dynamic table` — this lets codepan derive aliases, FKs, etc.

---

## Reading: `SqliteAdapter`

`SqliteAdapter` implements `DatabaseExecutor`, so all standard `sqflite` methods (`query`, `insert`, `delete`, `update`, `rawQuery`, `batch`, etc.) work. Codepan adds:

| Method | Returns | Purpose |
| :--- | :--- | :--- |
| `read(sql)` | `Future<List<Map<String, dynamic>>>` | Alias for `rawQuery`. |
| `getValue<T>(sql)` | `Future<T?>` | First column of first row. |
| `getRecord(sql)` | `Future<Map<String,dynamic>?>` | First row. |
| `recordOf(schema:, id:)` | `Future<Map<String,dynamic>?>` | One full row by primary key (joins all FKs). |
| `isRecordExists(sql)` | `Future<bool>` | `rawQuery(sql).isNotEmpty`. |
| `getColumnList(table)` | `Future<List<String?>>` | Result of `PRAGMA table_info`. |
| `getTableColumnCount(table)` | `Future<int>` | Column count via `PRAGMA table_info`. |
| `getIndexColumnCount(idx)` | `Future<int>` | Column count via `PRAGMA index_info`. |
| `hasRecord<E>(entity)` | `Future<bool>` | At least one row exists. |
| `nextIdOf<E>(entity)` | `Future<int>` | `MAX(id) + 1`. |
| `checkVersion()` | `Future<void>` | Logs `PRAGMA user_version`. |
| `deleteDatabaseFile()` | `Future<void>` | Removes the file (use during reset flows). |
| `inTransaction` | `bool` | True while a `SqliteBinder` is bound. |
| `binder` | `SqliteBinder?` | Currently-bound binder, if any. |
| `schema` | `DatabaseSchema` | Same instance used by initializer. |

All methods accept fully-qualified table names (e.g. `users_tb`). When in doubt, use `schema.of(Tb.users).tableName`.

---

## Building Queries: `SqliteQuery`

`SqliteQuery` builds `SELECT` SQL. Two constructors:

### Plain

```dart
final q = SqliteQuery(
  select: ['id', 'name', 'email'],          // List<String> or List<Field>
  from: schema.of(Tb.users),                 // String / Table / TableSchema
  where: { 'isDeleted': false },             // Map<String,dynamic> or List<Condition>
  orderBy: [Field.order(field: 'name')],
  groupBy: ['email'],
  limit: 50,
  offset: 0,
  rowSkip: null,                             // 'every Nth row' window
  randomOrder: false,
);
final sql = q.build();
```

### `SqliteQuery.all` — auto-join all FKs

When you want every column from `Tb.users` plus every column from each foreign-key table:

```dart
final q = SqliteQuery.all(
  schema: schema.of(Tb.invoices),
  where: { 'isDeleted': false },
  type: JoinType.left,                       // left | right | inner | outer
);
```

Codepan walks the FKs and emits a `LEFT JOIN ... ON inv.userId = usrs.id` for each. To recursively follow FKs further:

```dart
final q = SqliteQuery.all(
  schema: schema.of(Tb.invoiceItems),
  recursive: RecursiveJoin(levelLimit: 2),
);
```

`levelLimit: 0` disables; `-1` is unlimited; `n` follows up to `n` levels deep.

### Manual joins

```dart
final q = SqliteQuery(
  select: schema.of(Tb.invoices).fields,
  from: schema.of(Tb.invoices),
);
q.join(
  query: SqliteQuery(
    select: schema.of(Tb.users).fields,
    from: schema.of(Tb.users),
    where: { 'id': q.field('userId') },      // raw alias-qualified field
  ),
  type: JoinType.inner,
);
```

`q.field(name)` returns a fully-qualified `Field` for use as a value in the join condition.

### Result aliasing

Built-in: every selected column is aliased `as 'columnName'` so the result map keys are predictable across joins. Function fields (`Field.count(...)`) become `as 'COUNT(field)'`.

---

## `Condition` — `WHERE` Clauses

The simplest way to build a `WHERE`: pass a `Map<String, dynamic>` to `where:`. Each entry becomes a `field = value` condition; values handle `null`, `bool`, `String`, `Field`, `SqliteQuery`, `List<dynamic>`, and enums automatically.

For more control, build `Condition` objects directly:

```dart
final q = SqliteQuery(
  select: ['id', 'name'],
  from: schema.of(Tb.users),
  where: [
    Condition.equals('isDeleted', false),
    Condition.notNull('email'),
    Condition.greaterThan('amount', 100),
    Condition.between('createdAt', '2024-01-01', '2024-12-31'),
    Condition.like('name', 'Jeff', scan: Scan.between),  // %Jeff%
    Condition.inList('roleId', [1, 2, 3]),
    Condition.or([
      Condition.equals('isVip', true),
      Condition.greaterThan('amount', 10000),
    ]),
  ],
);
```

| Factory | Operator |
| :--- | :--- |
| `Condition.equals(f, v)` | `=` |
| `Condition.notEquals(f, v)` | `!=` |
| `Condition.greaterThan(f, v)` / `lessThan` / `…OrEquals` | `>`, `<`, `>=`, `<=` |
| `Condition.between(f, start, end)` | `BETWEEN start AND end` |
| `Condition.isNull(f)` / `notNull(f)` | `IS NULL` / `NOT NULL` |
| `Condition.isEmpty(f)` / `notEmpty(f)` | `= ''` / `!= ''` |
| `Condition.like(f, value, scan: Scan.start/end/between)` | `LIKE '%v'` / `'v%'` / `'%v%'` |
| `Condition.inQuery(f, query)` / `notInQuery` | `IN (subquery)` / `NOT IN` |
| `Condition.inList(f, [...])` / `notInList` | `IN (a, b, c)` |
| `Condition.isTrue(f)` / `isFalse(f)` | `= 1` / `= 0` |
| `Condition.or([...])` / `Condition.and([...])` | Grouping |

`Scan` controls wildcards in `LIKE`: `Scan.start` → `'%v'`, `Scan.end` → `'v%'`, `Scan.between` → `'%v%'`.

---

## Writing: `SqliteBinder` and Transactions

**All writes go through `SqliteBinder`.** Direct calls to `db.insert/update/delete` skip transaction boundaries and can corrupt foreign-key relationships. The binder wraps a `sqflite` `Batch` and adds:

- Atomic transaction with `transact<T>(body:)`.
- Automatic ID resolution for upserts based on `unique`/`uniqueGroup` columns.
- Convenience methods for typed `TransactionData` (`insertData`, `updateData`, `insertForId`).
- DDL helpers: `createTable`, `createIndex`, `createTimeTrigger`, `dropTable`, `dropIndex`, `dropTrigger`, `addColumn`, `renameTable`, `recreateTable`.

### Basic transaction

```dart
final binder = SqliteBinder.of(db);
final ok = await binder.transact<bool>(
  body: (binder) async {
    binder.insertData(data: user);
    binder.updateData(data: invoice);
    binder.delete(schema.of(Tb.roles), 5);
  },
);
```

`transact<T>` returns `bool` if `T == bool` (true on commit, throws on error), or whatever your `body` returns otherwise:

```dart
final newId = await binder.transact<int>(
  body: (binder) async => binder.insertData(data: user),
);
```

If anything throws, the binder is auto-detached from the adapter to prevent the next caller from inheriting a poisoned state, and the error rethrows.

### `chain` mode

When a service calls another service that opens its own binder, use `SqliteBinder.chain(db)`. If a transaction is already active on the adapter, it returns that binder with `_chain = true` so its `finish()` is a no-op:

```dart
final binder = SqliteBinder.chain(db);   // joins ongoing tx if any
await binder.transact<bool>(body: ...);
```

### Insert API

```dart
// Typed helper using TransactionData.toMap() and unique/uniqueGroup metadata.
final id = await binder.insertData(data: user);

// Same, but also returns a copy of the entity with id/dateCreated/timeCreated set.
final user2 = await binder.insertForId<UserData>(data: user);

// Generic — table can be String, Table, or TableSchema.
final id = await binder.insert(
  schema.of(Tb.users),
  SqliteStatement.fromMap({'name': 'jeff', 'email': 'j@x.io'}),
  unique: 'email',                  // 'ON CONFLICT(email) DO UPDATE'
);
```

`UpdatePriority`:
- `UpdatePriority.unique` (default) — prefer the single-column unique key, else fall back to the unique-group.
- `UpdatePriority.uniqueGroup` — opposite preference.

### Update / Delete

```dart
binder.updateData(data: user.copyWith(name: 'New'));
binder.updateRecord(schema.of(Tb.users), stmt, userId);

binder.delete(schema.of(Tb.users), userId);
binder.deleteWithConditions(schema.of(Tb.users), stmt);

// Reset a bool column across many tables
binder.resetBool(
  tables: [schema.of(Tb.invoices), schema.of(Tb.users)],
  column: 'isSynced',
  value: false,
);

binder.truncate('events_tb');           // delete + reset autoincrement
```

### Raw SQL

```dart
binder.addStatement('UPDATE users_tb SET email = LOWER(email)');
```

`addStatement` honors `showLog` / `logFilters` (see [Logging Transactions](#logging-transactions)).

---

## `SqliteStatement` — Low-level SQL Generator

You usually don't touch this directly — `SqliteBinder` and `SqliteQuery` do. Reach for it when you need raw DDL/DML strings:

```dart
final stmt = SqliteStatement.fromMap({
  'name': 'jeff',
  'email': 'j@x.io',
});
stmt.insert('users_tb', unique: 'email');
// → INSERT INTO users_tb (name, email) VALUES ('jeff', 'j@x.io')
//   ON CONFLICT (email) DO UPDATE SET name = 'jeff', email = 'j@x.io'

stmt.update('users_tb', 5);
// → UPDATE users_tb SET name = 'jeff', email = 'j@x.io' WHERE id = 5

SqliteStatement().delete('users_tb', 5);
SqliteStatement().delete('users_tb');
```

Other constructors:
- `SqliteStatement()` — empty.
- `SqliteStatement.fromMap({...})` — populates `fieldValueList`.
- `SqliteStatement.fromList([...])` — populates `fieldList` (e.g. for `CREATE TABLE`).
- `SqliteStatement.from({fields, fieldsAndValues, conditions})` — combined.

---

## Services — `ServiceFor<T>`

A service encapsulates per-table reads, joins, and parsing.

```dart
class UserService extends ServiceFor<UserData> {
  const UserService(super.db);

  @override
  DatabaseEntity get entity => Tb.users;

  @override
  UserData? parse(Map<String, dynamic>? record) {
    if (record == null) return null;
    return UserData(
      id: record['id'],
      email: record['email'],
      name: record['name'],
      role: RoleService(db).parse(record),       // join nesting
    );
  }

  // Optional: custom loaders
  Future<List<UserData>> loadActive() async {
    final query = SqliteQuery.all(
      schema: schema,
      where: {'isActive': true, 'isDeleted': false},
    );
    return recordsToList(await db.read(query.build()));
  }
}
```

Built-in members on `ServiceFor<T>`:

| Member | Behavior |
| :--- | :--- |
| `db` | The adapter (passed to constructor). |
| `entity` | Override — which `Tb` value this service handles. |
| `schema` | `db.schema.of(entity)` (a `TableSchema`). |
| `parse(record)` | Override — convert one row map into `T?`. |
| `recordsToList(records, [parser])` | Map a list of rows through `parse`. |
| `getRecord(id, [isWebId=false])` | One record by `id` or `webId`. |
| `loadRecords()` | Default `SELECT * WHERE isDeleted = 0` with all FKs joined. |
| `deleteRecord(data)` | Soft-delete via `isDeleted = true`. |
| `records` | Getter alias for `loadRecords()`. |

---

## Database/Model/Service Triad

Every table should have **three** files:

1. **Schema entry** in `DatabaseSchema.fields(entity)`.
2. **Data model** under `lib/data/models/entities/<table_name>.dart` extending `MasterData` (or `TransactionData`). See [data_models.md](./data_models.md).
3. **Service** under `lib/data/services/<table_name>.dart` extending `ServiceFor<TData>`.

Naming:
- Enum value: `lowerCamelCase` matching the table name (`users`).
- Entity class: `UserData`, `InvoiceData` (PascalCase + `Data` suffix).
- Service class: `UserService`, `InvoiceService` (PascalCase + `Service` suffix).
- File names: `snake_case.dart`.

---

## Schema Migrations

Versioning is driven entirely by the `version` argument you pass to `SqliteCache.getDatabase`. When you bump it:

1. `DefaultDatabaseInitializer.onUpgrade` runs — codepan reads `PRAGMA table_info` per table, then issues `ALTER TABLE … ADD COLUMN` for any new column. Indices with more columns than before are dropped and recreated.
2. After codepan's automatic part, your override `onDatabaseUpdated(db, oldVersion, newVersion)` runs. Use it for data migrations, renames, or table drops. Inside, open a fresh `SqliteBinder.of(db)` and `transact`.
3. Downgrades (`oldVersion > newVersion`) follow the same path; codepan resets `PRAGMA user_version` if your handler throws so the next launch retries.

`SqliteBinder.recreateTable<E>(entity)` is the canonical way to rebuild a table when its constraints change (e.g., adding `inUniqueGroup`):

```dart
@override
Future<void> onDatabaseUpdated(SqliteAdapter db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    final binder = SqliteBinder.of(db);
    await binder.transact<bool>(body: (b) async => b.recreateTable(Tb.users));
  }
}
```

---

## Logging Transactions

Pass `showLog: true` to `transact` to print every `addStatement` SQL string. Filter to specific tables with `logFilters`:

```dart
await binder.transact<bool>(
  showLog: true,
  logFilters: [schema.of(Tb.users), schema.of(Tb.invoices)],
  body: (binder) async { ... },
);
```

The transaction footer prints "TRANSACTION SUCCESSFUL" plus elapsed duration in human-readable form.

---

## Error Handling

`SqliteException` extends `sqflite`'s `DatabaseException`. Codepan throws it for:

- `databaseNotOpened` — you forgot to `await openConnection()`.
- `noFieldValues` / `noConditions` / `noFields` — building a statement with empty inputs.
- `noFieldsInQuery` — building a `SqliteQuery` without any selects.
- `invalidTableType` — passing something other than `String`/`Table`/`TableSchema`.
- `noSchemaFoundInQuery` — calling `joinAllForeignKeys` on a query whose `from:` was a `Table`/`String` (FK info isn't available).
- `duplicateRecord` — wrapped from raw SQLite error 2067 (UNIQUE constraint).
- `initializationFailed` — wrapper for any error during `onCreate`/`onUpgrade`.
- `invalidConditionList` — combining `OR` and `AND` lists in a single `Condition`.
- `invalidSqliteEntity` — passing the wrong subtype to `SqliteStatement.add`.
- `unknownEntity` — adapter cannot map an entity to a schema entry.

Catch the codepan exception in services or in your HTTP `onSuccess` for clean user-facing messages.

---

## Common Pitfalls

| Pitfall | Symptom | Fix |
| :--- | :--- | :--- |
| Direct call to `db.insert/update/delete` | Foreign keys/triggers misfire | Always go through `SqliteBinder`. |
| Forgetting `..clean()` on a `Map` before query params | Stray `null`s in `WHERE` | Use `where:` and let `Condition` skip `null`, or call `paramsMap..clean()`. |
| Passing a raw `Table` to `SqliteQuery.all` | `noSchemaFoundInQuery` | Use `schema.of(Tb.x)` (a `TableSchema`). |
| Marking a column `unique` *and* `.ug()` | The `.ug()` is silently ignored | Choose one. `.ug()` participates in a composite unique. |
| Bumping `version` without updating `Tb.version` | Nothing breaks, but misleading | Keep `Tb.version` in sync — you'll need it later. |
| Calling `binder.finish()` manually inside `transact` | Double-commit error | `transact` already calls `finish()`; just await it. |
| Reading a column via raw `record[...]` after a join | Column collisions on duplicated names | `SqliteQuery` aliases `as 'fieldName'`; pass results through services. |
| Building `WHERE` with raw strings | SQL injection / quoting bugs | Use `Condition.*` factories. They handle quoting and types. |

---

For data-model conventions (`MasterData`, `TransactionData`, `EntityData`, factories), see [data_models.md](./data_models.md).
