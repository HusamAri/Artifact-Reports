import 'package:supabase_flutter/supabase_flutter.dart';

import 'metrics_snapshot.dart';

class MetricsRepository {
  MetricsRepository(this._client);

  final SupabaseClient _client;

  /// Most recent snapshot per account for the given workspace.
  /// Returns a map keyed by social_account_id for O(1) dashboard lookup.
  Future<Map<String, MetricsSnapshot>> latestForWorkspace(
    String workspaceId,
  ) async {
    // Pull the accounts first so RLS scoping stays explicit.
    final accounts = await _client
        .from('social_accounts')
        .select('id')
        .eq('workspace_id', workspaceId)
        .filter('deleted_at', 'is', null);
    final accountIds = (accounts as List)
        .map((row) => (row as Map<String, dynamic>)['id'] as String)
        .toList();
    if (accountIds.isEmpty) return const {};

    // Newest snapshot per account: order desc, group client-side
    // (Supabase REST has no DISTINCT ON).
    final rows = await _client
        .from('metrics_snapshots')
        .select(
            'id, social_account_id, captured_at, followers, posts, impressions')
        .inFilter('social_account_id', accountIds)
        .order('captured_at', ascending: false);

    final out = <String, MetricsSnapshot>{};
    for (final row in rows as List) {
      final snap = MetricsSnapshot.fromJson(row as Map<String, dynamic>);
      out.putIfAbsent(snap.socialAccountId, () => snap);
    }
    return out;
  }
}
