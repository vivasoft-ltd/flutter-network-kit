import 'package:flutter_network_lib/flutter_network_lib.dart';

import 'configer.dart';

class Executor {
  static DioNetworkCallExecutor setupParser() {
    return NetworkConfigurator()
        .createDioNetworkCallExecutor(ConnectivityResult.none);
  }
}
