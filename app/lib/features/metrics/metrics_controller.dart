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

/// Sum of followers across every connected account in the workspace.
/// Returns null when there are no snapshots yet.
final totalFollowersProvider = Provider<int?>((ref) {
  final asyncMap = ref.watch(latestMetricsProvider);
  final map = asyncMap.valueOrNull;
  if (map == null || map.isEmpty) return null;
  var total = 0;
  var any = false;
  for (final snap in map.values) {
    if (snap.followers != null) {
      total += snap.followers!;
      any = true;
    }
  }
  return any ? total : null;
});
