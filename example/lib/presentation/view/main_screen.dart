import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

import '../../domain/entity/post_entity.dart';
import '../viewmodel/post_bloc.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.connectivity});

  /// Injected for tests; defaults to the platform [Connectivity] singleton.
  final Connectivity? connectivity;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _listenToConnectivityChange();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Shows a SnackBar whenever the device goes online or offline.
  void _listenToConnectivityChange() {
    _connectivitySubscription = (widget.connectivity ?? Connectivity())
        .onConnectivityChanged
        .listen(
            (results) => _showSnackBar(results.any((r) => r.isConnected())));
  }

  void _showSnackBar(bool isConnected) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You are ${isConnected ? 'online' : 'offline'}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Posts")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () => context.read<PostBloc>().add(FetchPosts()),
            child: const Text("Fetch Posts"),
          ),
          ElevatedButton(
            onPressed: () {
              const newPost = PostEntity(title: "foo", body: "bar", userId: 1);
              context.read<PostBloc>().add(CreateNewPost(newPost));
            },
            child: const Text("Create Post"),
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

  /// Builds the UI for the current [PostState].
  Widget _buildBlocBuilder(BuildContext context, PostState state) {
    return switch (state) {
      PostLoading() => const Center(child: CircularProgressIndicator()),
      PostLoaded(:final posts) => _buildListView(posts),
      PostCreated(:final post) => _buildListView([post]),
      PostError(:final message) => Center(child: Text("Error: $message")),
      PostInitial() =>
        const Center(child: Text("Press the button to fetch posts")),
    };
  }

  Widget _buildListView(List<PostEntity> posts) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return ListTile(title: Text(post.title), subtitle: Text(post.body));
      },
    );
  }
}
