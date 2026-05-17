import 'package:supabase_flutter/supabase_flutter.dart';

import 'social_account.dart';

class SocialAccountRepository {
  SocialAccountRepository(this._client);

  final SupabaseClient _client;

  /// Lists social accounts attached to a workspace. RLS scopes the
  /// query to workspaces the caller belongs to.
  Future<List<SocialAccount>> listForWorkspace(String workspaceId) async {
    final rows = await _client
        .from('social_accounts')
        .select(
          'id, workspace_id, platform, display_name, handle, '
          'avatar_url, last_synced_at',
        )
        .eq('workspace_id', workspaceId)
        .filter('deleted_at', 'is', null)
        .order('created_at');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(SocialAccount.fromJson)
        .toList();
  }

  /// Soft-delete: sets deleted_at. Hard delete + token revocation will
  /// land in M3b alongside the real OAuth disconnect path.
  Future<void> disconnect(String accountId) async {
    await _client.from('social_accounts').update(
        {'deleted_at': DateTime.now().toIso8601String()}).eq('id', accountId);
  }
}
