import 'package:example/core/utils/network/network_executor.dart';
import 'package:get_it/get_it.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<INetworkExecutor>(() => NetworkExecutor());
}
