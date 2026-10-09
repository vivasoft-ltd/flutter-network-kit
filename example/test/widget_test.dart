import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:example/core/utils/exception/base_error.dart';
import 'package:example/domain/entity/post_entity.dart';
import 'package:example/domain/repository/call_example_repository.dart';
import 'package:example/domain/usecase/create_post.dart';
import 'package:example/domain/usecase/get_all_posts.dart';
import 'package:example/presentation/view/main_screen.dart';
import 'package:example/presentation/viewmodel/post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viva_network_kit/viva_network_kit.dart';

class _FakeRepository implements CallExampleRepository {
  @override
  Future<Either<BaseError, List<PostEntity>>> getAllPosts() async =>
      const Right(
          [PostEntity(userId: 1, id: 1, title: 'Hello', body: 'World')]);

  @override
  Future<Either<BaseError, PostEntity>> createPost(PostEntity post) async =>
      Right(post);
}

class _FakeConnectivity implements Connectivity {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async =>
      [ConnectivityResult.wifi];

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream.empty();
}

void main() {
  testWidgets('fetches and lists posts', (tester) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => PostBloc(
          GetAllPostsUseCase(repository),
          CreatePostUseCase(repository),
        ),
        child: MaterialApp(home: MainScreen(connectivity: _FakeConnectivity())),
      ),
    );

    expect(find.text('Press the button to fetch posts'), findsOneWidget);

    await tester.tap(find.text('Fetch Posts'));
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('World'), findsOneWidget);
  });
}
