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
          _showSnackBar(result.isConnected());
        }
      }
    });
  }

  /// Displays a SnackBar indicating the current connectivity status.
  ///
  /// The SnackBar informs the user whether they are currently online or offline.
  /// It only shows the SnackBar if the widget is currently mounted in the
  /// widget tree.
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
              builder: _buildBlocBuilder,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the UI based on the current [PostState].
  ///
  /// Displays a loading indicator if the state is [PostLoading], a list view of
  /// posts if the state is [PostLoaded], an error message if the state is
  /// [PostError], or a prompt to fetch posts if no state is loaded.
  ///
  /// Args:
  ///   context: The build context.
  ///   state: The current state of the PostBloc.
  Widget _buildBlocBuilder(BuildContext context, PostState state) {
    if (state is PostLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is PostLoaded) {
      return _buildListView(state);
    } else if (state is PostError) {
      return Center(child: Text("Error: ${state.message}"));
    }
    return Center(child: Text("Press the button to fetch posts"));
  }

  ListView _buildListView(PostLoaded state) {
    return ListView.builder(
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return _buildListTile(post);
      },
    );
  }

  ListTile _buildListTile(PostModel post) {
    return ListTile(
      title: Text(post.title!),
      subtitle: Text(post.body!),
    );
  }
}
