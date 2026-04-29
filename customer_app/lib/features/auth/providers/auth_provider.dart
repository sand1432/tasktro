import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../services/analytics/analytics_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required this.authRepository}) {
    _init();
  }

  final AuthRepository authRepository;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  void _init() {
    authRepository.authStateChanges.listen((AuthState state) async {
      if (state.session != null) {
        await _loadUserProfile();
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });

    if (authRepository.isAuthenticated) {
      _loadUserProfile();
    } else {
      _status = AuthStatus.unauthenticated;
    }
  }

  Future<void> _loadUserProfile() async {
    final userId = authRepository.currentUserId;
    if (userId == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    final result = await authRepository.getUserProfile(userId);
    result.when(
      success: (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        AnalyticsService.instance.setUserId(user.id);
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = AuthStatus.error;
      },
    );
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signInWithEmail(email, password);
    return result.when(
      success: (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        AnalyticsService.instance.logEvent('login', parameters: {'method': 'email'});
        notifyListeners();
        return true;
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await authRepository.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
    return result.when(
      success: (user) {
        _user = user;
        _status = AuthStatus.authenticated;
        AnalyticsService.instance.logEvent('sign_up');
        notifyListeners();
        return true;
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = AuthStatus.error;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> signInWithGoogle() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await authRepository.signInWithGoogle();
    result.when(
      success: (_) {
        AnalyticsService.instance.logEvent('login', parameters: {'method': 'google'});
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = AuthStatus.error;
        notifyListeners();
      },
    );
  }

  Future<void> signInWithApple() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final result = await authRepository.signInWithApple();
    result.when(
      success: (_) {
        AnalyticsService.instance.logEvent('login', parameters: {'method': 'apple'});
      },
      failure: (e) {
        _errorMessage = e.message;
        _status = AuthStatus.error;
        notifyListeners();
      },
    );
  }

  Future<void> signOut() async {
    await authRepository.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    await authRepository.resetPassword(email);
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    final result = await authRepository.updateProfile(updatedUser);
    result.when(
      success: (user) {
        _user = user;
        notifyListeners();
      },
      failure: (e) {
        _errorMessage = e.message;
        notifyListeners();
      },
    );
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
