import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';

/// Streams Supabase auth state. Emits `null` until configured, so the
/// router can treat "unconfigured" the same as "signed out" and bounce
/// the user to /login (which surfaces the env warning).
final authStateChangesProvider = StreamProvider<AuthState?>((ref) {
  if (!Env.isConfigured) {
    return const Stream.empty();
  }
  return Supabase.instance.client.auth.onAuthStateChange;
});

final currentSessionProvider = Provider<Session?>((ref) {
  if (!Env.isConfigured) return null;
  // Re-evaluate when auth state changes.
  ref.watch(authStateChangesProvider);
  return Supabase.instance.client.auth.currentSession;
});

final isSignedInProvider = Provider<bool>((ref) {
  return ref.watch(currentSessionProvider) != null;
});

class AuthController {
  AuthController(this._client);

  final SupabaseClient _client;

  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUpWithPassword({
    required String email,
    required String password,
  }) async {
    await _client.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() => _client.auth.signOut();
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(Supabase.instance.client);
});
