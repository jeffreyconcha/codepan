# HTTP Module

How to perform network requests with codepan's request abstractions: `GetRequest`, `PostRequest`, `PutRequest`, `PatchRequest`, `DeleteRequest`, `UploadRequest`, `DownloadRequest`, plus `InitHandler` / `DataInitHandler` / `ByteInitHandler`. All HTTP traffic in a codepan-backed project should flow through these classes — the consistency they enforce around auth, error handling, JSON decoding, and DB persistence is the entire point.

---

## Index (Table of Contents)

1. [File Registry](#file-registry)
2. [Module Overview](#module-overview)
3. [The Request Lifecycle](#the-request-lifecycle)
4. [`HttpRequest<T, B>` — Common Base](#httprequestt-b--common-base)
5. [`GetRequest<T>`](#getrequestt)
6. [`TransmitRequest<T>` and Its Children](#transmitrequestt-and-its-children)
7. [`PostRequest<T>`, `PutRequest<T>`, `PatchRequest<T>`, `DeleteRequest<T>`](#postrequestt-putrequestt-patchrequestt-deleterequestt)
8. [`UploadRequest<T>`](#uploadrequestt)
9. [`DownloadRequest<T>`](#downloadrequestt)
10. [Handlers — `InitHandler`, `DataInitHandler`, `ByteInitHandler`](#handlers--inithandler-datainithandler-byteinithandler)
11. [`onSuccess` and Database Persistence](#onsuccess-and-database-persistence)
12. [`onError` — User-Facing Messages](#onerror--user-facing-messages)
13. [Configuration: `authority`, `path`, `headers`](#configuration-authority-path-headers)
14. [Calling a Request: `send`](#calling-a-request-send)
15. [Authentication Patterns](#authentication-patterns)
16. [Logging](#logging)
17. [Common Pitfalls](#common-pitfalls)
18. [End-to-End Example](#end-to-end-example)

---

## File Registry

| File | Symbols | Purpose |
| :--- | :--- | :--- |
| `codepan/http/requests/base_request.dart` | `HttpRequest<T,B>`, `HttpRequestResult`, header constants | Base class for every request; defines `send`, `onResponse`. |
| `codepan/http/requests/get_request.dart` | `GetRequest<T>` | HTTP GET with query params and JSON-body decoding. |
| `codepan/http/requests/transmit_request.dart` | `TransmitRequest<T>` | Common base for POST/PUT/PATCH/DELETE with a JSON body. |
| `codepan/http/requests/post_request.dart` | `PostRequest<T>` | HTTP POST. |
| `codepan/http/requests/put_request.dart` | `PutRequest<T>` | HTTP PUT. |
| `codepan/http/requests/patch_request.dart` | `PatchRequest<T>` | HTTP PATCH. |
| `codepan/http/requests/delete_request.dart` | `DeleteRequest<T>` | HTTP DELETE. |
| `codepan/http/requests/upload_request.dart` | `UploadRequest<T>` | Multipart/form-data upload. |
| `codepan/http/requests/download_request.dart` | `DownloadRequest<T>` | Binary GET (returns `Uint8List`). |
| `codepan/http/handlers.dart` | `InitHandler<I,O>`, `DataInitHandler`, `ByteInitHandler`, `DataInitException` | Convert raw response bodies into the typed input expected by `onSuccess`. |

The `http` package is a transitive dependency. Import it directly when you need `MultipartFile`, `MediaType`, `Response`, etc.

---

## Module Overview

Each request class is a small recipe that:

1. Builds a `Uri` from `authority`, `path`, and (for GET/DOWNLOAD) `params`.
2. Awaits `headers` and merges in standard `Content-Type` defaults (codepan's `getHeaders` / `postHeaders` / `uploadHeaders`).
3. Sends the request via the injected `http.Client`.
4. Decodes the body — JSON for most, `Uint8List` for `DownloadRequest`.
5. Routes the parsed payload through the request's `handler` (`InitHandler`).
6. Calls your `onSuccess(data)` with the typed payload, or `onError(code, message)` on failure.
7. Returns whatever your `onSuccess` returned, typed as `T`.

You almost never write a request from scratch. Instead, pick the closest base class, override the abstract members, and (optionally) override `handler` for unusual response shapes.

---

## The Request Lifecycle

```
build params/body ──▶ build headers ──▶ send via Client
        │                                       │
        ▼                                       ▼
  Uri.https(...)                         await Response
                                                │
                                                ▼
                                  parse JSON ── handler.init(body)
                                                │
                                          ┌─────┴────────────┐
                                          │                  │
                                          ▼                  ▼
                                     onSuccess(data)   onError(code,msg)
                                          │                  │
                                          ▼                  ▼
                                       returns T          throws String
```

The whole chain is started by calling `await request.send()`.

---

## `HttpRequest<T, B>` — Common Base

```dart
abstract class HttpRequest<T, B> implements HttpRequestResult<T, B> {
  final SqliteAdapter db;
  final Client client;
  final bool logResponse;

  const HttpRequest({required this.db, required this.client, this.logResponse = true});

  String get authority;
  String get path;
  Future<Map<String, String>> get headers;
  Future<Response> get response;
  InitHandler get handler;

  Future<T> send({Duration? timeout});
  Future<T> onResponse(Response response);

  Future<T> onSuccess(B body);
  Future<String> onError(int code, [String? message]);
}
```

Common to every request:

- **`db`** — the `SqliteAdapter`. Always passed via the constructor; `onSuccess` uses it for `SqliteBinder` writes.
- **`client`** — the `http.Client`. Inject from your DI / app-init layer.
- **`logResponse`** — when `true`, prints the raw body before `onResponse` runs. Disable for noisy upload/long endpoints.
- **`T`** — the return type from `onSuccess`. Common choices: `bool` (sync result), the model class (e.g. `LeadData`), `List<X>`, `File`.
- **`B`** — the body type fed into `onSuccess`. `List<Map<String,dynamic>>` for JSON-based requests; `Uint8List` for downloads.

`send` defaults to a 30-second timeout. Override per-call: `await req.send(timeout: const Duration(seconds: 60))`.

---

## `GetRequest<T>`

For HTTP GET. Override `params` to supply query-string parameters; codepan calls `..clean()` so `null` values are stripped automatically.

```dart
abstract class GetRequest<T> extends HttpRequest<T, List<Map<String, dynamic>>> {
  Future<Map<String, String?>> get params;     // becomes ?key=value&...
  @override DataInitHandler get handler;
}
```

```dart
class GetUsersRequest extends GetRequest<List<UserData>> {
  final int page;
  const GetUsersRequest({required super.db, required super.client, required this.page});

  @override String get authority => mc.authority;
  @override String get path => '${mc.apiPath}/users';

  @override
  Future<Map<String, String>> get headers async => {
        'Authorization': 'Bearer ${await AuthorizationService(db).token}',
      };

  @override
  Future<Map<String, String?>> get params async => {
        'page': '$page',
        'pageSize': '50',
      };

  @override
  DataInitHandler get handler => const ResponseInitHandler(true);

  @override
  Future<List<UserData>> onSuccess(List<Map<String, dynamic>> data) async {
    return data.map(UserData.fromJson).toList();
  }

  @override
  Future<String> onError(int code, [String? message]) async {
    return Errors.failedToLoad$.complete(Strings.users);
  }
}
```

`Uri.https(authority, path, params)` is used internally — pass paths **without** the protocol (`mc.apiPath`/`/users`) and **without** query-string encoding.

---

## `TransmitRequest<T>` and Its Children

`TransmitRequest<T>` is the shared base for POST/PUT/PATCH/DELETE. It sends a JSON body built from `params`:

```dart
Future<Map<String, dynamic>> get params;
```

Subclasses only differ in how they call the client:

```dart
class PostRequest<T> extends TransmitRequest<T> {
  Future<Response> perform(Uri uri, {headers, body, encoding}) =>
      client.post(uri, headers: headers, body: body, encoding: utf8);
}
```

Codepan calls `..clean()` on your params map and JSON-encodes with 4-space indent. Empty/`null` values are omitted from the request body.

---

## `PostRequest<T>`, `PutRequest<T>`, `PatchRequest<T>`, `DeleteRequest<T>`

All have identical APIs — pick the one matching the HTTP verb your endpoint expects.

```dart
class CreateUserRequest extends PostRequest<UserData> {
  final UserData user;
  const CreateUserRequest({required super.db, required super.client, required this.user});

  @override String get authority => mc.authority;
  @override String get path => '${mc.apiPath}/users';

  @override
  Future<Map<String, String>> get headers async => {
        'Authorization': 'Bearer ${await AuthorizationService(db).token}',
      };

  @override
  Future<Map<String, dynamic>> get params async => {
        'name': user.name,
        'email': user.email,
        'roleId': user.role?.webId,
      };

  @override
  DataInitHandler get handler => const ResponseInitHandler(false);

  @override
  Future<UserData> onSuccess(List<Map<String, dynamic>> data) async {
    final map = data.first;
    final updated = user.copyWith(webId: map.getInt('id'));
    final binder = SqliteBinder.of(db);
    await binder.transact<bool>(body: (b) async => b.updateData(data: updated));
    return updated;
  }

  @override
  Future<String> onError(int code, [String? message]) async {
    return message ?? Errors.failedToCreate$.complete(Strings.user);
  }
}
```

Same shape works for `PutRequest`, `PatchRequest`, `DeleteRequest`. The verb is the only thing that changes.

---

## `UploadRequest<T>`

Multipart form-data. Override **both** `fields` (text) and `files`:

```dart
abstract class UploadRequest<T> extends HttpRequest<T, List<Map<String, dynamic>>> {
  Future<Map<String, String>> get fields;
  Future<List<MultipartFile>> get files;
  @override DataInitHandler get handler;
}
```

```dart
class UploadAvatarRequest extends UploadRequest<bool> {
  final UserData user;
  final File image;
  const UploadAvatarRequest({required super.db, required super.client, required this.user, required this.image});

  @override String get authority => mc.authority;
  @override String get path => '${mc.fileApiPath}/avatar';

  @override
  Future<Map<String, String>> get headers async => {
        'Authorization': 'Bearer ${await AuthorizationService(db).token}',
      };

  @override
  Future<Map<String, String>> get fields async => {
        'userId': '${user.webId}',
        'params': json.encode({'replace': true}),  // common: stash JSON in a 'params' field
      };

  @override
  Future<List<MultipartFile>> get files async => [
        MultipartFile.fromBytes(
          'image',
          await image.readAsBytes(),
          contentType: MediaType('image', 'jpeg'),
          filename: '${user.id}.jpg',
        ),
      ];

  @override
  DataInitHandler get handler => const ResponseInitHandler(true);

  @override
  Future<bool> onSuccess(List<Map<String, dynamic>> data) async {
    final binder = SqliteBinder.of(db);
    return binder.transact<bool>(body: (b) async {
      b.updateData(data: user.copyWith(/* updated avatar URL etc. */));
    });
  }

  @override
  Future<String> onError(int code, [String? message]) async => Errors.failedToUpload$.complete(Strings.image);
}
```

Notes:
- `path` typically points to a separate file-upload endpoint (`mc.fileApiPath`).
- Tarkie convention: when the upload also needs JSON, JSON-encode it into a single `params` field.
- The internal multipart request uses POST. There is currently no `UploadPutRequest` — if your API requires PUT-style uploads, fall back to a custom `MultipartRequest`.

---

## `DownloadRequest<T>`

Binary GET. Body type is `Uint8List`; the default `handler` is `ByteInitHandler(false)` which passes bytes through unchanged.

```dart
abstract class DownloadRequest<T> extends HttpRequest<T, Uint8List> {
  Future<Map<String, String?>> get params;
  @override ByteInitHandler get handler => const ByteInitHandler(false);
}
```

```dart
class DownloadInvoicePdfRequest extends DownloadRequest<File> {
  final int invoiceId;
  const DownloadInvoicePdfRequest({required super.db, required super.client, required this.invoiceId});

  @override String get authority => mc.authority;
  @override String get path => '${mc.apiPath}/invoices/$invoiceId/pdf';

  @override
  Future<Map<String, String>> get headers async => {
        'Authorization': 'Bearer ${await AuthorizationService(db).token}',
      };

  @override
  Future<Map<String, String?>> get params async => {};

  @override
  Future<File> onSuccess(Uint8List data) async {
    final file = await PanUtils.getFile(
      fileName: 'invoice_$invoiceId.pdf',
      folder: 'invoices',
    );
    return file.writeAsBytes(data);
  }

  @override
  Future<String> onError(int code, [String? message]) async =>
      Errors.failedToDownload$.complete(Strings.invoice);
}
```

`logResponse` is **ignored** for downloads — codepan does not print binary bodies.

---

## Handlers — `InitHandler`, `DataInitHandler`, `ByteInitHandler`

A handler converts the raw decoded body (`Map<String,dynamic>` for JSON, `Uint8List` for downloads) into the typed `B` your `onSuccess` expects.

```dart
abstract class InitHandler<Input, Output> {
  final bool allowEmpty;
  const InitHandler(this.allowEmpty);
  Output init(Input body);
}

abstract class DataInitHandler
    extends InitHandler<Map<String, dynamic>, List<Map<String, dynamic>>> {}

class ByteInitHandler extends InitHandler<Uint8List, Uint8List> {
  Uint8List init(Uint8List body) => body;
}
```

You typically write **one** `DataInitHandler` per project — it knows your API's JSON envelope. Example:

```dart
class ResponseInitHandler extends DataInitHandler {
  const ResponseInitHandler(super.allowEmpty);

  @override
  List<Map<String, dynamic>> init(Map<String, dynamic> body) {
    if (body['status'] != 'ok') {
      throw DataInitException(body['message'] ?? 'Unknown error');
    }
    final data = body['data'];
    if (data is List) return data.cast<Map<String, dynamic>>();
    if (data is Map) return [Map<String, dynamic>.from(data)];
    return const [];
  }
}
```

- `allowEmpty: true` ⇒ `onSuccess` is invoked even when the parsed list is empty (sync confirmations).
- `allowEmpty: false` ⇒ codepan throws `onError(statusCode)` on empty bodies.
- Inside `init`, throw `DataInitException(message)` to send a custom message into `onError`.

`ByteInitHandler` is the right choice for binary endpoints — `DownloadRequest` provides it by default.

---

## `onSuccess` and Database Persistence

The expected pattern is: parse the response, then write to the local DB inside a single `SqliteBinder.transact`. Anything outside the transaction risks foreign-key drift.

```dart
@override
Future<bool> onSuccess(List<Map<String, dynamic>> data) async {
  final binder = SqliteBinder.of(db);
  return binder.transact<bool>(
    body: (binder) async {
      // 1. Mark all rows for this entity as deleted to clear stale records.
      binder.resetBool(
        tables: [schema.of(Tb.users)],
        column: 'isDeleted',
        value: true,
      );
      // 2. Insert/upsert each incoming row.
      for (final row in data) {
        final user = UserData.fromJson(row).copyWith(isDeleted: false);
        binder.insertData(data: user);
      }
    },
  );
}
```

When you only need to update the local row with the server's `webId` (typical of POST-then-sync flows):

```dart
@override
Future<bool> onSuccess(List<Map<String, dynamic>> data) async {
  final webId = data.first.getInt('id');
  final binder = SqliteBinder.of(db);
  return binder.transact<bool>(body: (b) async {
    b.updateData(data: lead.copyWith(webId: webId, isSynced: true));
  });
}
```

For per-table sync code, see `database.md` and `data_models.md`.

---

## `onError` — User-Facing Messages

`onError(code, [message])` returns a `String` which `send` then throws. Catch the throw at the call site to show the message:

```dart
try {
  final users = await GetUsersRequest(db: db, client: client, page: 1).send();
} catch (e) {
  showSnackBar(e.toString());
}
```

Use codepan's `Errors` and `Strings` (in `codepan/resources/strings.dart`) so messages are consistent:

```dart
@override
Future<String> onError(int code, [String? message]) async {
  if (message != null) return message;
  if (code == 401) return Errors.unauthorized;
  if (code == 404) return Errors.notFound;
  return Errors.failedToLoad$.complete(Strings.users);
}
```

`DataInitException(msg)` thrown inside a handler routes `msg` here as the second argument.

---

## Configuration: `authority`, `path`, `headers`

Centralize host configuration in a `main_config.dart` (per project), e.g.:

```dart
class MainConfig {
  final String authority;
  final String apiPath;
  final String fileApiPath;
  const MainConfig._(this.authority, this.apiPath, this.fileApiPath);
}
const mc = MainConfig._('api.example.com', '/v2', '/files');
```

Then use `mc.authority` / `mc.apiPath` / `mc.fileApiPath` in every request override. This makes flavor switching (dev vs. prod) a single import.

`headers` is `Future<Map<String,String>>` — async because most apps fetch the auth token from the local DB or secure storage:

```dart
@override
Future<Map<String, String>> get headers async {
  final token = await AuthorizationService(db).token;
  return {'Authorization': 'Bearer $token'};
}
```

---

## Calling a Request: `send`

```dart
final result = await GetUsersRequest(db: db, client: client, page: 1)
    .send(timeout: const Duration(seconds: 60));
```

Standard call sites: inside a `ParentBloc` handler, inside a `ServiceFor` method, inside `RefreshIndicator.onRefresh`. Always wrap in `try/catch` if you want to translate the thrown error to UI; otherwise let the exception propagate so the bloc emits an `ErrorState`.

---

## Authentication Patterns

The base class doesn't require authentication. The convention is:

1. Have a service (e.g. `AuthorizationService(db)`) that owns `token` / `refreshToken` getters and persists them via `SharedPreferencesManager` or a dedicated DB table.
2. Override `headers` async and read the token there. **Do not** cache it in a field on the request — the field would go stale across token refresh.
3. On `401`, throw a typed error from `onError` and have the calling bloc dispatch a re-login event.

```dart
@override
Future<Map<String, String>> get headers async {
  final token = await AuthorizationService(db).token;
  return {'Authorization': 'Bearer $token'};
}

@override
Future<String> onError(int code, [String? message]) async {
  if (code == 401) throw const Unauthorized();
  return message ?? Errors.requestFailed;
}
```

---

## Logging

`HttpRequest.send` prints:

- The fully-resolved `Uri`.
- Headers (for non-upload requests).
- Body — for `GetRequest` and `TransmitRequest`. For uploads, the multipart form body is logged. For downloads, body printing is suppressed.
- The response status code.
- The raw response body **only when** `logResponse: true` (default) and the request is not a `DownloadRequest`.

To silence a noisy endpoint:

```dart
const SyncEverythingRequest({required super.db, required super.client})
    : super(logResponse: false);
```

---

## Common Pitfalls

| Pitfall | Symptom | Fix |
| :--- | :--- | :--- |
| Including the protocol in `authority` | `Uri.https` double-prefixes (`https://https//host`) | Use bare host: `'api.example.com'`. |
| Building `params` synchronously | Stale auth tokens / async data unavailable | `params` is an `async` getter — `await` your sources inside. |
| Forgetting `..clean()` | Server receives `null` query params or body fields | Codepan calls `clean()` for you on params/body — but if you build a nested map, clean each level. |
| Catching exceptions inside `onSuccess` and returning a default | Bloc never sees the failure | Let `onSuccess` throw; codepan converts it via `onError`. |
| Writing to DB without `SqliteBinder.transact` | Partial updates, FK drift | Always wrap DB writes in a single `transact` block. |
| Using `PostRequest` for endpoints that require `PUT` | `405 Method Not Allowed` | Use the matching subclass (`PutRequest` / `PatchRequest` / `DeleteRequest`). |
| Reading raw `response.body` outside `send` | Bypasses handler & error logic | Always go through `send`. |
| Reusing one `Client` across isolates | Connection pool issues | Inject one `Client` per scope; close at app shutdown. |

---

## End-to-End Example

A request that:
1. Fetches a list of users with paging.
2. Decodes via a project-wide `ResponseInitHandler`.
3. Refreshes the local DB (mark stale, upsert new) inside one transaction.
4. Returns the count of inserted rows.

```dart
class SyncUsersRequest extends GetRequest<int> {
  final int page;
  const SyncUsersRequest({required super.db, required super.client, required this.page});

  @override String get authority => mc.authority;
  @override String get path => '${mc.apiPath}/users';

  @override
  Future<Map<String, String>> get headers async => {
        'Authorization': 'Bearer ${await AuthorizationService(db).token}',
      };

  @override
  Future<Map<String, String?>> get params async => {
        'page': '$page',
        'pageSize': '100',
      };

  @override
  DataInitHandler get handler => const ResponseInitHandler(true);

  @override
  Future<int> onSuccess(List<Map<String, dynamic>> data) async {
    final binder = SqliteBinder.of(db);
    return binder.transact<int>(body: (b) async {
      b.resetBool(tables: [schema.of(Tb.users)], column: 'isDeleted', value: true);
      int inserted = 0;
      for (final row in data) {
        final user = UserData.fromJson(row).copyWith(isDeleted: false);
        await b.insertData(data: user);
        inserted++;
      }
      return inserted;
    });
  }

  @override
  Future<String> onError(int code, [String? message]) async {
    return message ?? Errors.failedToLoad$.complete(Strings.users);
  }
}

// Usage from a bloc:
on<SyncUsers>((event, emit) async {
  emit(const UsersSyncing());
  try {
    final count = await SyncUsersRequest(db: db, client: client, page: 1).send();
    emit(UsersSynced(count));
  } catch (e) {
    emit(UsersFailed(e));
  }
});
```

This single example exercises the full pipeline: auth header, query params, JSON envelope handler, transactional persistence, typed return, error path. Every other request in the project should follow the same shape.
