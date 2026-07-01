import 'package:example/presentation/view/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di.dart';
import 'data/datasource/call_example_datasource.dart';
import 'data/repository/call_example_repository_impl.dart';
import 'domain/repository/get_call_repository.dart';
import 'domain/usecase/get_all_posts.dart';
import 'domain/usecase/post_request.dart';
import 'presentation/viewmodel/post_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      /// Define the repositories that will be provided to the widgets below in the widget tree.
      ///
      /// [CallExampleRepository] is responsible for data operations.
      /// [CallExampleRepositoryImpl] is the implementation of [CallExampleRepository].
      /// [CallExampleDataSource] is the data source for the repository.
      /// [GetAllPosts] is a use case that uses the repository to fetch all posts.
      /// [CreatePost] is a use case that uses the repository to create a new post.
      ///
      /// These repositories are provided using [RepositoryProvider] from the flutter_bloc package.
      providers: [
        RepositoryProvider<CallExampleRepository>(
          create: (context) =>
              CallExampleRepositoryImpl(CallExampleDataSource()),
        ),
        RepositoryProvider<GetAllPostsUseCase>(
          create: (context) => GetAllPostsUseCase(
            RepositoryProvider.of<CallExampleRepository>(context),
          ),
        ),
        RepositoryProvider<CreatePostUseCase>(
          create: (context) => CreatePostUseCase(
            RepositoryProvider.of<CallExampleRepository>(context),
          ),
        ),
      ],
      child: BlocProvider(
        create: (context) => PostBloc(
          RepositoryProvider.of<GetAllPostsUseCase>(context),
          RepositoryProvider.of<CreatePostUseCase>(context),
        ),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MainScreen(),
        ),
      ),
    );
  }
}
