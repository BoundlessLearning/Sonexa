import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonexa/core/database/app_database.dart';
import 'package:sonexa/core/error/app_error.dart';
import 'package:sonexa/core/error/exceptions.dart';
import 'package:sonexa/core/utils/diagnostic_logger.dart';
import 'package:sonexa/features/auth/data/repositories/auth_repository.dart';
import 'package:sonexa/features/auth/domain/entities/server_config.dart'
    as entity;

final _authDiag = DiagnosticLogger.instance.module('auth');

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(databaseProvider)),
);

final activeServerProvider = FutureProvider<entity.ServerConfig?>((ref) async {
  return ref.read(authRepositoryProvider).getActiveServer();
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  final bool isLoading;
  final AppError? error;
  final bool isLoggedIn;

  AuthState copyWith({
    bool? isLoading,
    AppError? error,
    bool? isLoggedIn,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;

  Future<void> login(String baseUrl, String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _authDiag.log(
      'login start: baseUrl=$baseUrl, username=$username',
      scope: 'session',
    );

    try {
      await _ref
          .read(authRepositoryProvider)
          .login(baseUrl, username, password);
      _ref.invalidate(activeServerProvider);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
      await _authDiag.log(
        'login succeeded: baseUrl=$baseUrl, username=$username',
        scope: 'session',
      );
    } on NetworkException catch (error) {
      state = state.copyWith(isLoading: false, error: _mapNetworkError(error));
      await _authDiag.error(
        'login network error',
        error,
        scope: 'session',
        fields: {'baseUrl': baseUrl, 'username': username},
      );
    } on ServerException catch (error) {
      state = state.copyWith(isLoading: false, error: _mapServerError(error));
      await _authDiag.error(
        'login server error',
        error,
        scope: 'session',
        fields: {'baseUrl': baseUrl, 'username': username, 'code': error.code},
      );
    } on UnauthorizedException {
      state = state.copyWith(
        isLoading: false,
        error: const AppError(AppErrorCode.authenticationFailed),
      );
      await _authDiag.log(
        'login unauthorized: baseUrl=$baseUrl, username=$username',
        scope: 'session',
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: AppError(
          AppErrorCode.connectionFailed,
          message: error.toString(),
        ),
      );
      await _authDiag.error(
        'login unexpected error',
        error,
        scope: 'session',
        fields: {'baseUrl': baseUrl, 'username': username},
      );
    }
  }

  Future<void> logout() async {
    await _authDiag.log('logout start', scope: 'session');
    await _ref.read(authRepositoryProvider).logout();
    _ref.invalidate(activeServerProvider);
    state = const AuthState();
    await _authDiag.log('logout completed', scope: 'session');
  }

  AppError _mapNetworkError(NetworkException error) {
    return switch (error.message) {
      'Connection timeout' => const AppError(AppErrorCode.connectionTimeout),
      'Receive timeout' => const AppError(AppErrorCode.receiveTimeout),
      'Network connectivity issue' => const AppError(
        AppErrorCode.networkConnectivity,
      ),
      'SSL certificate error' => const AppError(AppErrorCode.sslCertificate),
      _ => AppError(AppErrorCode.connectionFailed, message: error.message),
    };
  }

  AppError _mapServerError(ServerException error) {
    return switch (error.code) {
      // Subsonic error code 40 = wrong username or password.
      40 => const AppError(AppErrorCode.invalidCredentials),
      // Subsonic error code 50 = user is not authorized.
      50 => const AppError(AppErrorCode.userNotAuthorized),
      _ => AppError(AppErrorCode.serverError, message: error.message),
    };
  }
}
