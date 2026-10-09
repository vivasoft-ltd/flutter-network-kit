# viva_network_kit

A lightweight and developer-friendly network manager for Flutter, built on [Dio](https://pub.dev/packages/dio), with automatic connectivity checks before every API request.

Every call returns an `Either<YourError, YourResult>` (from [dartz](https://pub.dev/packages/dartz)), so success and failure are handled in one place without `try`/`catch`.

## Features

- ✅ Checks network availability before every request and skips the call when offline
- ✅ Built on Dio — use your own `BaseOptions`, interceptors, and adapters
- ✅ Typed results: single objects and lists are deserialized for you
- ✅ One error type for your app: connection, HTTP, and parsing failures all go through your `NetworkErrorConverter`
- ✅ Supports Android, iOS, Web, Windows, macOS, and Linux

## Installation

```bash
flutter pub add viva_network_kit
```

Or add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  viva_network_kit: ^2.2.0
```

## Setup

### 1. Register your model parsers

```dart
final jsonSerializer = JsonSerializer()
  ..addParser<PostModel>(PostModel.fromJson);
```

### 2. Configure Dio

Set the base URL, timeouts, and any interceptors (logging, auth, …):

```dart
final dio = Dio(
  BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
    sendTimeout: const Duration(seconds: 3),
    headers: {'Content-Type': 'application/json'},
  ),
);
```

### 3. Map errors to your own error type

`convert` receives one of:

- `ConnectionError` — the device was offline, so no request was made
- `DioException` — the request failed (timeout, bad response, …)
- `SerializationException` — the response could not be parsed into your model

```dart
class AppErrorConverter implements NetworkErrorConverter<AppError> {
  @override
  AppError convert(Exception exception) {
    return switch (exception) {
      ConnectionError() => AppError('No internet connection.'),
      DioException(type: DioExceptionType.connectionTimeout) =>
        AppError('Connection timed out.'),
      DioException(:final response?) =>
        AppError('Server error ${response.statusCode}.'),
      SerializationException() => AppError('Unexpected response format.'),
      _ => AppError('Something went wrong.'),
    };
  }
}
```

### 4. Create the executor

```dart
final executor = DioNetworkCallExecutor(
  dio: dio,
  dioSerializer: jsonSerializer,
  errorConverter: AppErrorConverter(),
);

// When it is no longer needed (e.g. app shutdown or DI container reset):
await executor.dispose();
```

## Usage

The type parameters are `<ErrorType, ReturnType, SingleItemType>`. For a list
response, `ReturnType` is `List<Model>` and `SingleItemType` is `Model`.

### GET

```dart
Future<Either<AppError, List<PostModel>>> getPosts() {
  return executor.get<AppError, List<PostModel>, PostModel>('/posts');
}
```

### POST / PUT / PATCH / DELETE

```dart
Future<Either<AppError, PostModel>> createPost(PostModel post) {
  return executor.post<AppError, PostModel, PostModel>(
    '/posts',
    body: post.toJson(),
  );
}
```

`put`, `patch`, and `delete` take the same arguments. For full control, pass
Dio `RequestOptions` to `execute`.

### Handling the result

```dart
final result = await getPosts();
result.fold(
  (error) => showError(error.message),
  (posts) => showPosts(posts),
);
```

## Showing online/offline status

The executor checks connectivity before every request. To show a live
online/offline indicator in your UI, listen to `Connectivity().onConnectivityChanged`
(re-exported from [connectivity_plus](https://pub.dev/packages/connectivity_plus)).
The [example app](https://github.com/vivasoft-ltd/flutter-network-kit/tree/main/example)
shows this, along with a full clean-architecture setup using BLoC and `get_it`.
