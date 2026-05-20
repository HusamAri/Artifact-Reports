import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../workspace/workspace_controller.dart';
import 'post.dart';
import 'post_repository.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(Supabase.instance.client);
});

/// Newest posts across every connected account in the current
/// workspace.
final postsProvider = FutureProvider<List<Post>>((ref) async {
  if (!Env.isConfigured) return const [];
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return const [];
  return ref.read(postRepositoryProvider).listForWorkspace(workspaceId);
});
