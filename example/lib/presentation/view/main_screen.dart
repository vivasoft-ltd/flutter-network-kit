import 'package:example/core/di.dart';
import 'package:example/core/utils/network/network_executor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_network_lib/flutter_network_lib.dart';

import '../../data/model/post.dart';
import '../viewmodel/post_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final INetworkExecutor _networkExecutor;

  /// Listens to changes in the device's connectivity status.
  ///
  /// When the connectivity status changes, it checks if the new status is
  /// different from the previously known status and updates accordingly.
  void _listenToConnectivityChange() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        ConnectivityResult result = results.first;
        if (result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile) {
          _networkExecutor.getExecutor(result).connectivityResult = result;
          _showSnackBar(result.isConnected());
        }
      }
    });
  }

  _showSnackBar(bool isConnected) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You are ${isConnected ? 'online' : 'offline'}'),
        ),
      );
    }
  }

  @override
  void initState() {
    _networkExecutor = locator<INetworkExecutor>();
    _listenToConnectivityChange();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Posts")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<PostBloc>().add(FetchPosts());
            },
            child: Text("Fetch Posts"),
          ),
          ElevatedButton(
            onPressed: () {
              final newPost = PostModel(title: "foo", body: "bar", userId: 1);
              context.read<PostBloc>().add(CreateNewPost(newPost));
            },
            child: Text("Create Post"),
          ),
          Expanded(
            child: BlocBuilder<PostBloc, PostState>(
              builder: (context, state) {
                if (state is PostLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is PostLoaded) {
                  return ListView.builder(
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return ListTile(
                        title: Text(post.title!),
                        subtitle: Text(post.body!),
                      );
                    },
                  );
                } else if (state is PostError) {
                  return Center(child: Text("Error: ${state.message}"));
                }
                return Center(child: Text("Press the button to fetch posts"));
              },
            ),
          ),
        ],
      ),
    );
  }
}
