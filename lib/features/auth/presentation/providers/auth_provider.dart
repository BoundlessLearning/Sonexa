import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ohmymusic/core/database/app_database.dart';
import 'package:ohmymusic/core/error/exceptions.dart';
import 'package:ohmymusic/features/auth/data/repositories/auth_repository.dart';
import 'package:ohmymusic/features/auth/domain/entities/server_config.dart' as entity;

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.read(databaseProvider)),
);

final activeServerProvider = FutureProvider<entity.ServerConfig?>((ref) async {
  return ref.read(authRepositoryProvider).getActiveServer();
});

final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
  });

  final bool isLoading;
  final String? error;
  final bool isLoggedIn;

  AuthState copyWith({
    bool? isLoading,
    String? error,
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

  Future<void> login(
    String baseUrl,
    String username,
    String password,
  ) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _ref.read(authRepositoryProvider).login(baseUrl, username, password);
      _ref.invalidate(activeServerProvider);
      state = state.copyWith(isLoading: false, isLoggedIn: true);
    } on NetworkException catch (e) {
      // 网络层错误：超时、DNS、SSL 等
      final message = switch (e.message) {
        'Connection timeout' => '连接超时，请检查服务器地址是否可访问',
        'Receive timeout' => '服务器响应超时，请稍后重试',
        'Network connectivity issue' => '无法连接到服务器，请检查网络和服务器地址',
        'SSL certificate error' => 'SSL 证书验证失败，请检查服务器证书配置',
        _ => '网络错误：${e.message}',
      };
      state = state.copyWith(isLoading: false, error: message);
    } on ServerException catch (e) {
      // 服务器返回了错误（认证失败、权限不足等）
      // Subsonic error code 40 = Wrong username or password
      // Subsonic error code 50 = User is not authorized
      final message = switch (e.code) {
        40 => '用户名或密码错误',
        50 => '该用户没有访问权限',
        _ => '服务器错误：${e.message}',
      };
      state = state.copyWith(isLoading: false, error: message);
    } on UnauthorizedException {
      state = state.copyWith(
        isLoading: false,
        error: '认证失败，请检查用户名和密码',
      );
    } catch (e) {
      // 其他未预期的错误（JSON 解析失败、数据库写入失败等）
      state = state.copyWith(
        isLoading: false,
        error: '连接失败：${e.toString()}',
      );
    }
  }

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).logout();
    _ref.invalidate(activeServerProvider);
    state = const AuthState();
  }
}
