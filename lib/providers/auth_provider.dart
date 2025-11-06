import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

// Asynchronously provides a SharedPreferences instance.
// 异步提供 SharedPreferences 实例。
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return await SharedPreferences.getInstance();
});

// Provider for AuthService, which depends on the async sharedPreferencesProvider.
// This provider will only be built after sharedPreferencesProvider is ready.
// AuthService 的 Provider，依赖于上面异步的 sharedPreferencesProvider。
// 当 sharedPreferencesProvider 准备好后，这个 provider 才会构建。
final authServiceProvider = Provider<AuthService>((ref) {
  // The .requireValue ensures that we only build AuthService after SharedPreferences has been successfully loaded.
  // .requireValue 确保我们只在 SharedPreferences 成功加载后才构建 AuthService。
  final sharedPreferences = ref.watch(sharedPreferencesProvider).requireValue;
  return AuthService(sharedPreferences);
});

@immutable
class AuthState {
  final String civitaiToken;
  final String rule34Token;
  final String rule34UserId;

  const AuthState({
    this.civitaiToken = '',
    this.rule34Token = '',
    this.rule34UserId = '',
  });

  AuthState copyWith({
    String? civitaiToken,
    String? rule34Token,
    String? rule34UserId,
  }) {
    return AuthState(
      civitaiToken: civitaiToken ?? this.civitaiToken,
      rule34Token: rule34Token ?? this.rule34Token,
      rule34UserId: rule34UserId ?? this.rule34UserId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  AuthNotifier(this._authService) : super(const AuthState()) {
    _loadAllCredentials();
  }

  void _loadAllCredentials() {
    final newState = AuthState(
      civitaiToken: _authService.getCivitaiToken() ?? '',
      rule34Token: _authService.getRule34Token() ?? '',
      rule34UserId: _authService.getRule34UserId() ?? '',
    );
    debugPrint('[AuthNotifier] Loaded credentials: Civitai token - ${newState.civitaiToken.isNotEmpty}, Rule34 token - ${newState.rule34Token.isNotEmpty}, Rule34 user ID - ${newState.rule34UserId.isNotEmpty}');
    state = newState;
  }

  Future<void> updateCivitaiToken(String newToken) async {
    await _authService.saveCivitaiToken(newToken);
    state = state.copyWith(civitaiToken: newToken);
    debugPrint('[AuthNotifier] Updated Civitai token.');
  }

  Future<void> updateRule34Credentials(
    String newToken,
    String newUserId,
  ) async {
    await _authService.saveRule34Credentials(newToken, newUserId);
    state = state.copyWith(rule34Token: newToken, rule34UserId: newUserId);
    debugPrint('[AuthNotifier] Updated Rule34 credentials.');
  }
}

// The final authProvider, which depends on authServiceProvider.
// 最终的 authProvider，依赖 authServiceProvider。
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
