import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../workspace/workspace_controller.dart';
import 'report.dart';
import 'report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(Supabase.instance.client);
});

/// Reports in the current workspace, newest first.
final reportsProvider = FutureProvider<List<Report>>((ref) async {
  if (!Env.isConfigured) return const [];
  final workspaceId = ref.watch(currentWorkspaceIdProvider);
  if (workspaceId == null) return const [];
  return ref.read(reportRepositoryProvider).listForWorkspace(workspaceId);
});

final reportProvider = FutureProvider.family<Report?, String>((ref, id) async {
  final list = await ref.watch(reportsProvider.future);
  for (final r in list) {
    if (r.id == id) return r;
  }
  return null;
});
