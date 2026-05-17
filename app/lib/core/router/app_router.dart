import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../config/env.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      // Without Supabase env we still want the dev experience to work —
      // skip the auth gate and land on the dashboard placeholder.
      if (!Env.isConfigured) return null;

      final signedIn = ref.read(isSignedInProvider);
      final goingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!signedIn && !goingToAuth) return '/login';
      if (signedIn && goingToAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
    ],
  );
});

/// Bridges Riverpod auth-state changes into go_router's [Listenable]-shaped
/// refresh API so redirect() re-runs on sign-in/out.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    _sub = ref.listen<bool>(
      isSignedInProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<bool> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
