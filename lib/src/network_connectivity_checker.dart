import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Tracks whether the device has an active network connection.
///
/// Used by [DioNetworkCallExecutor] to check connectivity before every
/// request. When no [initialResult] is given, it starts as
/// [ConnectivityResult.none] and follows [Connectivity.onConnectivityChanged].
class NetworkConnectivityChecker {
  ConnectivityResult connectivityResult;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  NetworkConnectivityChecker({ConnectivityResult? initialResult})
      : connectivityResult = initialResult ?? ConnectivityResult.none {
    if (initialResult == null) {
      _subscribeToConnectivityChange();
    }
  }

  bool get isConnected => connectivityResult.isConnected();

  /// Queries the current connectivity, updates [connectivityResult] and
  /// returns whether the device is online.
  Future<bool> checkConnection() async {
    connectivityResult =
        _firstActiveResult(await Connectivity().checkConnectivity());
    return isConnected;
  }

  /// Subscribes to connectivity changes using the [Connectivity] package.
  ///
  /// This method listens for changes in the device's connectivity status and
  /// updates the [connectivityResult] accordingly.
  void _subscribeToConnectivityChange() {
    _connectivitySubscription ??= Connectivity().onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        connectivityResult = _firstActiveResult(results);
      },
    );
  }

  /// Picks the first active connection type from [results], or
  /// [ConnectivityResult.none] if there is none.
  ConnectivityResult _firstActiveResult(List<ConnectivityResult> results) {
    return results.firstWhere(
      (result) => result.isConnected(),
      orElse: () => ConnectivityResult.none,
    );
  }
}

/// Extension on [ConnectivityResult] to easily check if the device has an
/// active network connection.
///
/// - [isConnected]: Returns true for any connection type (wifi, mobile,
/// ethernet, vpn, bluetooth, satellite, other); false only for
/// [ConnectivityResult.none]. iOS reports wired Ethernet, VPN/tunnel and
/// other interfaces as [ConnectivityResult.ethernet] or
/// [ConnectivityResult.other], so accepting only wifi/mobile would wrongly
/// flag those devices as offline.
extension ConectivityChecker on ConnectivityResult {
  bool isConnected() {
    return this != ConnectivityResult.none;
  }
}
