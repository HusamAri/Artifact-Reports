import 'package:supabase_flutter/supabase_flutter.dart';

import 'post.dart';

class PostRepository {
  PostRepository(this._client);

  final SupabaseClient _client;

  /// Newest posts across every connected account in the workspace.
  /// RLS gates the join via the social_account_id FK.
  Future<List<Post>> listForWorkspace(
    String workspaceId, {
    int limit = 30,
  }) async {
    final rows = await _client
        .from('posts')
        .select(
          'id, social_account_id, external_post_id, posted_at, content, '
          'media_urls, metrics, '
          'social_accounts!inner(workspace_id, platform, display_name)',
        )
        .eq('social_accounts.workspace_id', workspaceId)
        .order('posted_at', ascending: false, nullsFirst: false)
        .limit(limit);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }
}
