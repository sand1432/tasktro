import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/error_handler.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../services/supabase/supabase_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({required this.apiClient});

  final ApiClient apiClient;

  User? get currentUser => SupabaseService.currentUser;
  String? get currentUserId => SupabaseService.currentUserId;
  bool get isAuthenticated => SupabaseService.isAuthenticated;

  Stream<AuthState> get authStateChanges => SupabaseService.authStateChanges;

  Future<Result<UserModel>> signInWithEmail(
    String email,
    String password,
  ) async {
    return ErrorHandler.guard(() async {
      final response = await SupabaseService.signInWithEmail(email, password);
      final user = response.user;
      if (user == null) throw Exception('Sign in failed');
      return _getUserProfile(user.id);
    });
  }

  Future<Result<UserModel>> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    return ErrorHandler.guard(() async {
      final response = await SupabaseService.signUp(
        email,
        password,
        data: {'full_name': fullName, 'phone': phone},
      );

      final user = response.user;
      if (user == null) throw Exception('Sign up failed');

      // Create user profile in users table
      await apiClient.insert('users', {
        'id': user.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
      });

      return _getUserProfile(user.id);
    });
  }

  Future<Result<bool>> signInWithGoogle() async {
    return ErrorHandler.guard(() async {
      return SupabaseService.signInWithGoogle();
    });
  }

  Future<Result<bool>> signInWithApple() async {
    return ErrorHandler.guard(() async {
      return SupabaseService.signInWithApple();
    });
  }

  Future<Result<void>> signOut() async {
    return ErrorHandler.guard(() async {
      await SupabaseService.signOut();
    });
  }

  Future<Result<void>> resetPassword(String email) async {
    return ErrorHandler.guard(() async {
      await SupabaseService.resetPassword(email);
    });
  }

  Future<Result<UserModel>> getUserProfile(String userId) async {
    return ErrorHandler.guard(() async {
      return _getUserProfile(userId);
    });
  }

  Future<UserModel> _getUserProfile(String userId) async {
    final data = await apiClient.query(
      'users',
      filters: {'id': userId},
    );

    if (data.isEmpty) {
      // Create profile if it doesn't exist
      final user = SupabaseService.currentUser!;
      final profile = {
        'id': userId,
        'email': user.email ?? '',
        'full_name': user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String? ??
            '',
      };
      final created = await apiClient.insert('users', profile);
      return UserModel.fromJson(created);
    }

    return UserModel.fromJson(data.first);
  }

  Future<Result<UserModel>> updateProfile(UserModel user) async {
    return ErrorHandler.guard(() async {
      final data = await apiClient.update('users', user.id, user.toJson());
      return UserModel.fromJson(data);
    });
  }
}
