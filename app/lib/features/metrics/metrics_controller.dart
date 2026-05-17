import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../workspace/workspace_controller.dart';
import 'metrics_repository.dart';
import 'metrics_series.dart';
import 'metrics_snapshot.dart';

final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  return MetricsRepository(Supabase.instance.client);
});

/// Latest snapshot per social account in the current workspace.
final latestMetricsProvider =
    FutureProvider<Map<String, MetricsSnapshot>>((ref) async {
  if (!Env.isConfigured) return const {};
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return const {};
  return ref.read(metricsRepositoryProvider).latestForWorkspace(workspaceId);
});

int? _sumInt(
    Iterable<MetricsSnapshot> snaps, int? Function(MetricsSnapshot) pick) {
  var total = 0;
  var any = false;
  for (final s in snaps) {
    final v = pick(s);
    if (v != null) {
      total += v;
      any = true;
    }
  }
  return any ? total : null;
}

final totalFollowersProvider = Provider<int?>((ref) {
  final map = ref.watch(latestMetricsProvider).valueOrNull ?? const {};
  return _sumInt(map.values, (s) => s.followers);
});

final totalImpressionsProvider = Provider<int?>((ref) {
  final map = ref.watch(latestMetricsProvider).valueOrNull ?? const {};
  return _sumInt(map.values, (s) => s.impressions);
});

final totalPostsProvider = Provider<int?>((ref) {
  final map = ref.watch(latestMetricsProvider).valueOrNull ?? const {};
  return _sumInt(map.values, (s) => s.posts);
});

final totalReachProvider = Provider<int?>((ref) {
  final map = ref.watch(latestMetricsProvider).valueOrNull ?? const {};
  return _sumInt(map.values, (s) => s.reach);
});

/// Time-window selection for charts.
enum DashboardPeriod {
  sevenDays(7),
  thirtyDays(30),
  ninetyDays(90);

  const DashboardPeriod(this.days);
  final int days;
}

final selectedPeriodProvider =
    StateProvider<DashboardPeriod>((_) => DashboardPeriod.thirtyDays);

/// Generic time-series provider keyed on a `metrics_snapshots` column
/// (e.g. `followers`, `impressions`, `reach`). Honors the currently
/// selected period and the active workspace.
final metricSeriesProvider =
    FutureProvider.family<List<TimeSeriesPoint>, String>((ref, metric) async {
  if (!Env.isConfigured) return const [];
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return const [];
  final period = ref.watch(selectedPeriodProvider);
  final since = DateTime.now().toUtc().subtract(Duration(days: period.days));
  return ref.read(metricsRepositoryProvider).seriesForWorkspace(
        workspaceId: workspaceId,
        metric: metric,
        since: since,
      );
});
