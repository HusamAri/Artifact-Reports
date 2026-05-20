import 'package:supabase_flutter/supabase_flutter.dart';

import 'report.dart';
import 'report_snapshot.dart';

class ReportRepository {
  ReportRepository(this._client);

  final SupabaseClient _client;

  Future<List<Report>> listForWorkspace(String workspaceId) async {
    final rows = await _client
        .from('reports')
        .select(
          'id, workspace_id, title, public_id, visibility, expires_at, created_at, config',
        )
        .eq('workspace_id', workspaceId)
        .filter('deleted_at', 'is', null)
        .order('created_at', ascending: false);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(Report.fromJson)
        .toList();
  }

  Future<Report> create({
    required String workspaceId,
    required String title,
    required int periodDays,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Cannot create a report while signed out.');
    }
    final row = await _client
        .from('reports')
        .insert({
          'workspace_id': workspaceId,
          'title': title,
          'created_by': user.id,
          'config': {'period_days': periodDays},
        })
        .select(
          'id, workspace_id, title, public_id, visibility, expires_at, created_at, config',
        )
        .single();
    return Report.fromJson(row);
  }

  /// Toggles visibility between 'public' and 'private'. Public reports
  /// expire 30 days from now by default; flipping back to private
  /// clears the expiry.
  Future<Report> setPublic(String reportId, {required bool public}) async {
    final updates = <String, dynamic>{
      'visibility': public ? 'public' : 'private',
      'expires_at': public
          ? DateTime.now()
              .toUtc()
              .add(const Duration(days: 30))
              .toIso8601String()
          : null,
    };
    final row = await _client
        .from('reports')
        .update(updates)
        .eq('id', reportId)
        .select(
          'id, workspace_id, title, public_id, visibility, expires_at, created_at, config',
        )
        .single();
    return Report.fromJson(row);
  }

  /// Newest frozen snapshot for the report. The trigger from migration
  /// 0007 inserts one on report creation, so this should always
  /// return a row for reports created after that migration.
  Future<ReportSnapshot?> latestSnapshot(String reportId) async {
    final row = await _client
        .from('report_snapshots')
        .select('id, report_id, data, created_at')
        .eq('report_id', reportId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return ReportSnapshot.fromJson(row);
  }

  Future<void> softDelete(String reportId) async {
    await _client
        .from('reports')
        .update({'deleted_at': DateTime.now().toUtc().toIso8601String()}).eq(
            'id', reportId);
  }
}
