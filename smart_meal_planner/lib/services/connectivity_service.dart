import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map((results) {
    // result is a List<ConnectivityResult> in version 6.0+
    return !results.contains(ConnectivityResult.none);
  });
});

class ConnectivityService {
  static Future<bool> isConnected() async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }
}
