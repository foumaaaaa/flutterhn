import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get connectivityStream;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
    : connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final results = await connectivity.checkConnectivity();
    return _isConnectedResults(results);
  }

  @override
  Stream<bool> get connectivityStream {
    return connectivity.onConnectivityChanged.map(_isConnectedResults);
  }

  // Mise à jour pour gérer List<ConnectivityResult>
  bool _isConnectedResults(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
