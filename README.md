# viva_network_kit

A lightweight and developer-friendly network manager for Flutter, built on [Dio](https://pub.dev/packages/dio), with automatic connectivity checks before every API request.

## Features

| Feature                                        | Android | iOS |
|------------------------------------------------|---------|-----|
| ✅ Ensures network availability before request  | ✔️       | ✔️   |
| ✅ Reduces redundant error handling duplication | ✔️       | ✔️   |
| ✅ Built on Dio for handling HTTP requests      | ✔️       | ✔️   |
| ✅ Prevents API calls when offline              | ✔️       | ✔️   |
| ✅ Simple API design with minimal setup         | ✔️       | ✔️   |

***If you want to display the online/offline status at the initial level, you need to listen for connectivity changes. See the example for more details.***

## Installation
#### Run in your terminal
```bash
flutter pub add viva_network_kit
```

#### Or add it manually to your pubspec.yaml:
```yaml
dependencies:
  viva_network_kit: latest_version
```


## Initialize dioNetworkCallExecutor
#### First, set up the JSON serializer to parse your models.
```dart
// Add jsonSerializer to add parser
JsonSerializer jsonSerializer = JsonSerializer();

// Add Parsers
jsonSerializer.addParser<PostModel>(PostModel.fromJson)
```
#### This package requires a Dio instance for network calls. You can configure this instance by adding
- Base URL
- Timeouts for requests
- Custom interceptors for logging, authentication, etc.:
```dart
final Dio _dio = Dio(
      BaseOptions(
        baseUrl: Constants.BASE_URL,
        connectTimeout: const Duration(milliseconds: 3000),
        receiveTimeout: const Duration(milliseconds: 3000),
        sendTimeout: const Duration(milliseconds: 3000),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    )
```

#### Now, initialize the DioNetworkCallExecutor:
```dart
final DioNetworkCallExecutor dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: dio,
      dioSerializer: jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter(),
      );
```

#### Example for BaseErrorConverter
```dart
class DioErrorToApiErrorConverter implements NetworkErrorConverter<BaseError> {
  @override
  BaseError convert(Exception exception) {
    if (exception is DioException) {
      switch (exception.type) {
        case DioExceptionType.cancel:
          return BaseError(ErrorCode.cancel);
        case DioExceptionType.connectionTimeout:
          return BaseError(ErrorCode.connectionTimeOut);
      }
      }
}
```

## Example GET Usage
```dart
Future<Either<BaseError, List<YOUR_MODEL>>> get() async {
    final response = await di<DioNetworkCallExecutor>()
        .get<BaseError, List<YOUR_MODEL>, YOUR_MODEL>(
      Constants.YOUR_PATH,
    );

    return response;
}
```

## Example POST Usage
```dart
  Future<Either<BaseError, YOUR_MODEL>> createPost(YOUR_MODEL post) async {
    final response = await di<DioNetworkCallExecutor>()
        .post<BaseError, YOUR_MODEL, YOUR_MODEL>(
      Constants.YOUR_PATH,
      body: post.toJson(),
    );

    return response;
  }
```