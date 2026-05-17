import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../workspace/workspace_controller.dart';
import 'metrics_repository.dart';
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

/// Sum of followers across every connected account in the workspace.
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
