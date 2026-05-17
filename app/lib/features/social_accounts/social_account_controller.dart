import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../workspace/workspace_controller.dart';
import 'social_account.dart';
import 'social_account_repository.dart';

final socialAccountRepositoryProvider = Provider<SocialAccountRepository>((
  ref,
) {
  return SocialAccountRepository(Supabase.instance.client);
});

/// Social accounts for the currently selected workspace.
final socialAccountsProvider = FutureProvider<List<SocialAccount>>((ref) async {
  if (!Env.isConfigured) return const [];
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return const [];
  return ref
      .read(socialAccountRepositoryProvider)
      .listForWorkspace(workspaceId);
});
