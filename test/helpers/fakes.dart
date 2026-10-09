import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

/// [Connectivity] double whose state is set by the test.
class FakeConnectivity implements Connectivity {
  FakeConnectivity([this.results = const [ConnectivityResult.wifi]]);

  List<ConnectivityResult> results;
  final StreamController<List<ConnectivityResult>> controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      controller.stream;
}

/// Dio adapter that records the last request and replies with a canned body.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter({this.statusCode = 200, this.body});

  int statusCode;
  Object? body;
  RequestOptions? lastRequest;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    requestCount++;
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Error converter that exposes the raw exception it received.
class PassThroughErrorConverter implements NetworkErrorConverter<Exception> {
  @override
  Exception convert(Exception exception) => exception;
}

class Item implements Serializable {
  Item(this.id);

  factory Item.fromJson(Map<String, dynamic> json) => Item(json['id'] as int);

  final int id;

  @override
  Map<String, dynamic> toJson() => {'id': id};
}
