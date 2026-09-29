import 'dart:convert';

import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

/// Stands in for the native connectivity plugin. The mixin lets it pass
/// [ConnectivityPlatform.instance]'s token check.
class MockConnectivityPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements ConnectivityPlatform {}

/// Replaces Dio's transport so no request reaches the network.
class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

class MockNetworkErrorConverter extends Mock
    implements NetworkErrorConverter<Exception> {}

/// Registers the fallback values mocktail needs for `any()` matchers on the
/// mocks above. Call once from `setUpAll`.
void registerNetworkFallbackValues() {
  registerFallbackValue(RequestOptions());
  registerFallbackValue(Exception('fallback'));
}

ResponseBody jsonResponse(Object? body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

class Post implements Serializable {
  final int id;
  final String title;

  const Post({required this.id, required this.title});

  factory Post.fromJson(Map<String, dynamic> json) =>
      Post(id: json['id'] as int, title: json['title'] as String);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'title': title};

  @override
  bool operator ==(Object other) =>
      other is Post && other.id == id && other.title == title;

  @override
  int get hashCode => Object.hash(id, title);
}
