import 'package:dio/dio.dart';
import 'package:example/json_serializable/base_error.dart';
import 'package:example/json_serializable/error_converter.dart';
import 'package:example/json_serializable/model/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';

Future<void> testGetApi() async {
  JsonSerializer jsonSerializer = JsonSerializer();
  jsonSerializer.addParser<Post>(Post.fromJson);
  final dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')),
      dioSerializer: jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter());

  final value =
      await dioNetworkCallExecutor.execute<BaseError, List<Post>, Post>(
          options: RequestOptions(
    headers: {
      'Content-Type': 'application/json',
    },
    method: 'GET',
    path: '/posts',
  ));
  debugPrint(value.toString());
}

Future<void> testPostApi() async {
  JsonSerializer jsonSerializer = JsonSerializer();
  final dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')),
      dioSerializer: jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter());

  final value = await dioNetworkCallExecutor
      .execute<BaseError, Map<String, dynamic>, Map<String, dynamic>>(
          options: RequestOptions(
    headers: {
      'Content-Type': 'application/json',
    },
    method: 'Post',
    data: {
      'title': 'foo',
      'body': 'bar',
      'userId': 1,
    },
    path: '/posts',
  ));
  print(value.toString());
}

Future<void> testPostApi2() async {
  JsonSerializer jsonSerializer = JsonSerializer();
  final dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: Dio(),
      dioSerializer: jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter());

  final value = await dioNetworkCallExecutor.post<BaseError, String, String>(
    'https://viva.pihr.xyz/token',
    options: Options(
      headers: {'Content-type': 'application/x-www-form-urlencoded'},
    ),
    body: {
      'username': 'fuad',
      'password': 'p1hr#aPk_pAs5',
      'grant_type': 'password',
      'companyId': '2',
      'deviceId': '',
      'deviceToken': ''
    },
  );
  print(value.toString());
}

Future<void> jsonSerializableWay() async {
  testGetApi();
  //testPostApi();
  // testPostApi2();
}

void main() async {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final DioNetworkCallExecutor _dioNetworkCallExecutor;
  bool isSubscribed = false;

  @override
  void initState() {
    JsonSerializer jsonSerializer = JsonSerializer();
    jsonSerializer.addParser<Post>(Post.fromJson);

    _dioNetworkCallExecutor = DioNetworkCallExecutor(
      dio: Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com')),
      dioSerializer: jsonSerializer,
      errorConverter: DioErrorToApiErrorConverter(),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network library demo'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                await jsonSerializableWay();
              },
              child: const Text('Initiate network call'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () async {
                if (isSubscribed) {
                  await _dioNetworkCallExecutor
                      .unsubscribeFromConnectivityChange();
                } else {
                  _dioNetworkCallExecutor.subscribeToConnectivityChange(
                    (connectivityResult) =>
                        _showSnackBar(connectivityResult.isConnected()),
                  );
                }

                setState(() {
                  isSubscribed = !isSubscribed;
                });
              },
              child: Text(
                  '${isSubscribed ? 'Unsubscribe' : 'Subscribe'} to connectivity listener'),
            ),
          ],
        ),
      ),
    );
  }

  _showSnackBar(bool isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You are ${isConnected ? 'online' : 'offline'}'),
      ),
    );
  }
}
