import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/workspace/invite_redeem_screen.dart';
import '../../features/workspace/onboarding_screen.dart';
import '../../features/workspace/workspace.dart';
import '../../features/workspace/workspace_controller.dart';
import '../config/env.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefreshNotifier(ref);
  ref.onDispose(notifier.dispose);
  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      // Without Supabase env we still want the dev experience to work —
      // skip every gate and land on the dashboard placeholder.
      if (!Env.isConfigured) return null;

      final loc = state.matchedLocation;
      final goingToAuth = loc == '/login' || loc == '/signup';
      final goingToRedeem = loc == '/redeem';
      final goingToOnboarding = loc == '/onboarding';

      final signedIn = ref.read(isSignedInProvider);
      if (!signedIn) {
        // Redeem links land here too — defer the auth gate so deep links
        // bounce through login and back.
        return goingToAuth ? null : '/login';
      }
      if (goingToAuth) return '/';

      // Authed but no workspace yet — onboarding owns the experience,
      // unless the user is mid-redeem of an invite (which will add them
      // to a workspace).
      final workspaces = ref.read(myWorkspacesProvider).valueOrNull;
      final hasWorkspace = workspaces != null && workspaces.isNotEmpty;
      if (!hasWorkspace && !goingToOnboarding && !goingToRedeem) {
        return '/onboarding';
      }
      if (hasWorkspace && goingToOnboarding) return '/';
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
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/redeem',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return InviteRedeemScreen(token: token);
        },
      ),
    ],
  );
});

/// Bridges Riverpod auth + workspace changes into go_router's
/// [Listenable]-shaped refresh API so redirect() re-runs on either.
class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    _authSub = ref.listen<bool>(
      isSignedInProvider,
      (_, __) => notifyListeners(),
    );
    _wsSub = ref.listen(
      myWorkspacesProvider,
      (_, __) => notifyListeners(),
    );
  }

  late final ProviderSubscription<bool> _authSub;
  late final ProviderSubscription<AsyncValue<List<Workspace>>> _wsSub;

  @override
  void dispose() {
    _authSub.close();
    _wsSub.close();
    super.dispose();
  }
}
