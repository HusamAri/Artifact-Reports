import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../auth/auth_controller.dart';
import 'workspace.dart';
import 'workspace_repository.dart';

final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return WorkspaceRepository(Supabase.instance.client);
});

/// Lists workspaces the signed-in user belongs to. Re-fetches on
/// auth-state changes so sign-in/out swaps the list cleanly.
final myWorkspacesProvider = FutureProvider<List<Workspace>>((ref) async {
  if (!Env.isConfigured) return const [];
  // Refresh when auth state flips.
  ref.watch(isSignedInProvider);
  if (!ref.read(isSignedInProvider)) return const [];
  return ref.read(workspaceRepositoryProvider).listMine();
});

/// Currently selected workspace id. Defaults to the first workspace the
/// user belongs to once myWorkspacesProvider resolves.
class CurrentWorkspaceIdNotifier extends Notifier<String?> {
  @override
  String? build() {
    final asyncWs = ref.watch(myWorkspacesProvider);
    final list = asyncWs.valueOrNull;
    if (list == null || list.isEmpty) return null;
    if (state != null && list.any((w) => w.id == state)) return state;
    return list.first.id;
  }

  void select(String id) => state = id;
}

final currentWorkspaceIdProvider =
    NotifierProvider<CurrentWorkspaceIdNotifier, String?>(
  CurrentWorkspaceIdNotifier.new,
);

final currentWorkspaceProvider = Provider<Workspace?>((ref) {
  final id = ref.watch(currentWorkspaceIdProvider);
  if (id == null) return null;
  final list = ref.watch(myWorkspacesProvider).valueOrNull ?? const [];
  for (final w in list) {
    if (w.id == id) return w;
  }
  return null;
});
