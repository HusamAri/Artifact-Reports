import 'package:supabase_flutter/supabase_flutter.dart';

import 'workspace.dart';

class WorkspaceRepository {
  WorkspaceRepository(this._client);

  final SupabaseClient _client;

  /// Workspaces the current user is a member of (RLS does the filtering).
  Future<List<Workspace>> listMine() async {
    final rows = await _client
        .from('workspaces')
        .select('id, name, owner_id, plan_tier, locale')
        .order('created_at');
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Workspace.fromJson)
        .toList();
  }

  /// Creates a workspace owned by the current user. The 0004 trigger
  /// automatically inserts the owner into workspace_members.
  Future<Workspace> create({required String name, String locale = 'en'}) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot create a workspace while signed out.');
    }
    final row = await _client
        .from('workspaces')
        .insert({
          'name': name,
          'owner_id': user.id,
          'locale': locale,
        })
        .select('id, name, owner_id, plan_tier, locale')
        .single();
    return Workspace.fromJson(row);
  }

  /// Calls the invite-accept edge function with the user's JWT.
  /// Returns the workspace id on success.
  Future<String> acceptInvite(String token) async {
    final response = await _client.functions.invoke(
      'invite-accept',
      body: {'token': token},
    );
    final data = response.data;
    if (data is Map && data['workspace_id'] is String) {
      return data['workspace_id'] as String;
    }
    throw StateError('Unexpected invite-accept response: $data');
  }
}
