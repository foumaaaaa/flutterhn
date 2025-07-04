// TODO: Implementer le code pour data/repositories/user_repository_impl
// data/repositories/user_repository_impl.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/user_local_datasource.dart';
import '../datasources/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserLocalDataSource _localDataSource = UserLocalDataSource();
  final UserRemoteDataSource _remoteDataSource = UserRemoteDataSource();

  @override
  Future<User?> getUserById(String id) async {
    // First check local cache
    final localUser = await _localDataSource.getUserById(id);

    final isConnected = await _isConnected();
    if (isConnected) {
      try {
        final remoteUser = await _remoteDataSource.getUserById(id);
        if (remoteUser != null) {
          await _localDataSource.insertUser(remoteUser);
          return remoteUser;
        }
      } catch (e) {
        // Continue to return local user if available
      }
    }

    return localUser;
  }

  @override
  Future<List<User>> getUsersByIds(List<String> ids) async {
    final isConnected = await _isConnected();

    if (isConnected) {
      try {
        final remoteUsers = await _remoteDataSource.getUsersByIds(ids);

        // Cache users locally
        for (final user in remoteUsers) {
          await _localDataSource.insertUser(user);
        }

        return remoteUsers;
      } catch (e) {
        // Fallback to local data
        final List<User> localUsers = [];
        for (final id in ids) {
          final user = await _localDataSource.getUserById(id);
          if (user != null) {
            localUsers.add(user);
          }
        }
        return localUsers;
      }
    } else {
      // Return cached users
      final List<User> localUsers = [];
      for (final id in ids) {
        final user = await _localDataSource.getUserById(id);
        if (user != null) {
          localUsers.add(user);
        }
      }
      return localUsers;
    }
  }

  Future<bool> _isConnected() async {
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
  }
}
