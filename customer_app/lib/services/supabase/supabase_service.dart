import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';

class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static SupabaseStorageClient get storage => client.storage;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    debugPrint('Supabase initialized');
  }

  static User? get currentUser => auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // Auth methods
  static Future<AuthResponse> signInWithEmail(
    String email,
    String password,
  ) async {
    return auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUp(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    return auth.signUp(email: email, password: password, data: data);
  }

  static Future<bool> signInWithGoogle() async {
    return auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.fixlyai.app://login-callback/',
    );
  }

  static Future<bool> signInWithApple() async {
    return auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.fixlyai.app://login-callback/',
    );
  }

  static Future<void> signOut() async {
    await auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await auth.resetPasswordForEmail(email);
  }

  // Storage methods
  static Future<String> uploadFile(
    String bucket,
    String path,
    List<int> bytes, {
    String? contentType,
  }) async {
    await storage.from(bucket).uploadBinary(
      path,
      Uint8List.fromList(bytes),
      fileOptions: FileOptions(contentType: contentType),
    );
    return storage.from(bucket).getPublicUrl(path);
  }

  static Future<void> deleteFile(String bucket, String path) async {
    await storage.from(bucket).remove([path]);
  }
}
