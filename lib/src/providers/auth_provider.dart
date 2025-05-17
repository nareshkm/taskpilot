import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/meal_item.dart';
import '../models/communication_item.dart';
import '../models/schedule_item.dart';
import '../models/appointment_item.dart';
import '../models/expense_item.dart';
import '../models/note_item.dart';
import '../models/goal_item.dart';
import '../models/wellness_item.dart';

/// Represents authentication state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? email;
  final String? token;
  final String? error;

  AuthState({
    required this.isLoading,
    required this.isAuthenticated,
    this.email,
    this.token,
    this.error,
  });

  factory AuthState.initial() => AuthState(isLoading: true, isAuthenticated: false);
  factory AuthState.authenticated({required String email, required String token}) =>
      AuthState(isLoading: false, isAuthenticated: true, email: email, token: token);
  factory AuthState.unauthenticated({String? error}) =>
      AuthState(isLoading: false, isAuthenticated: false, error: error);
}

/// StateNotifier to manage authentication lifecycle
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  final AuthService _authService;

  AuthNotifier(this._ref, this._authService) : super(AuthState.initial()) {
    _init();
  }

  Future<void> _init() async {
    final ok = await _authService.tryAutoLogin();
    if (ok) {
      final email = _authService.email!;
      final token = _authService.token!;
      // Determine user
      final user = dummyUsers.firstWhere((u) => u.email == email,
          orElse: () => dummyUsers.first);
      // Update current user
      _ref.read(currentUserProvider.notifier).state = user;
      state = AuthState.authenticated(email: email, token: token);
    } else {
      state = AuthState.unauthenticated();
    }
  }

  /// Performs login and updates state accordingly
  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true, isAuthenticated: false);
    try {
      final data = await _authService.login(email, password);
      final uEmail = data['email']!;
      final uToken = data['token']!;
      // Determine user
      final user = dummyUsers.firstWhere((u) => u.email == uEmail,
          orElse: () => dummyUsers.first);
      // Update current user
      _ref.read(currentUserProvider.notifier).state = user;
      state = AuthState.authenticated(email: uEmail, token: uToken);
    } catch (e) {
      state = AuthState.unauthenticated(error: e.toString());
    }
  }

  /// Logs out the user
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated();
    // Reset current user
    _ref.read(currentUserProvider.notifier).state = dummyUsers.first;
  }
  
  /// Opens the Hive boxes specific to a user for complete data isolation.
}

/// Provides the AuthService; overridden in main.dart
final authServiceProvider = Provider<AuthService>((ref) =>
    throw UnimplementedError('AuthService must be provided'));

/// Exposes AuthState and AuthNotifier
/// StateNotifierProvider for authentication lifecycle
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final service = ref.watch(authServiceProvider);
  return AuthNotifier(ref, service);
});
/// Notifier holding the currently signed-in user from [dummyUsers]
class CurrentUserNotifier extends StateNotifier<User> {
  CurrentUserNotifier() : super(dummyUsers.first);
}
/// Provider for the currently selected [User]
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, User>((ref) {
  return CurrentUserNotifier();
});