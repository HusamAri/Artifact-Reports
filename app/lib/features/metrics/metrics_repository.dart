import 'package:supabase_flutter/supabase_flutter.dart';

import 'metrics_series.dart';
import 'metrics_snapshot.dart';

class MetricsRepository {
  MetricsRepository(this._client);

  final SupabaseClient _client;

  /// Most recent snapshot per account for the given workspace.
  /// Returns a map keyed by social_account_id for O(1) dashboard lookup.
  Future<Map<String, MetricsSnapshot>> latestForWorkspace(
    String workspaceId,
  ) async {
    final accountIds = await _accountIdsFor(workspaceId);
    if (accountIds.isEmpty) return const {};

    final rows = await _client
        .from('metrics_snapshots')
        .select(
            'id, social_account_id, captured_at, followers, posts, impressions, reach, engagement_rate')
        .inFilter('social_account_id', accountIds)
        .order('captured_at', ascending: false);

    final out = <String, MetricsSnapshot>{};
    for (final row in rows as List) {
      final snap = MetricsSnapshot.fromJson(row as Map<String, dynamic>);
      out.putIfAbsent(snap.socialAccountId, () => snap);
    }
    return out;
  }

  /// Daily time series of a single numeric metric across the workspace.
  /// For each UTC day in [since..now], picks the newest snapshot per
  /// account and sums [metric] across accounts. Days with no data are
  /// elided — callers can interpolate or just plot the points.
  Future<List<TimeSeriesPoint>> seriesForWorkspace({
    required String workspaceId,
    required String metric,
    required DateTime since,
  }) async {
    final accountIds = await _accountIdsFor(workspaceId);
    if (accountIds.isEmpty) return const [];

    final rows = await _client
        .from('metrics_snapshots')
        .select('social_account_id, captured_at, $metric')
        .inFilter('social_account_id', accountIds)
        .gte('captured_at', since.toUtc().toIso8601String())
        .order('captured_at', ascending: true);

    // Bucket per (account, day) — last value of the day per account wins.
    final perAccountDay = <String, Map<DateTime, int>>{};
    for (final row in rows as List) {
      final map = row as Map<String, dynamic>;
      final raw = map[metric];
      if (raw == null) continue;
      final value = (raw as num).toInt();
      final captured = DateTime.parse(map['captured_at'] as String).toUtc();
      final day = DateTime.utc(captured.year, captured.month, captured.day);
      final acct = map['social_account_id'] as String;
      (perAccountDay[acct] ??= <DateTime, int>{})[day] = value;
    }

    // Sum across accounts per day.
    final totals = <DateTime, int>{};
    for (final perDay in perAccountDay.values) {
      perDay.forEach((day, value) {
        totals.update(day, (cur) => cur + value, ifAbsent: () => value);
      });
    }

    final out = totals.entries
        .map((e) => TimeSeriesPoint(day: e.key, value: e.value))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return out;
  }

  Future<List<String>> _accountIdsFor(String workspaceId) async {
    final rows = await _client
        .from('social_accounts')
        .select('id')
        .eq('workspace_id', workspaceId)
        .filter('deleted_at', 'is', null);
    return (rows as List)
        .map((row) => (row as Map<String, dynamic>)['id'] as String)
        .toList();
  }
}
