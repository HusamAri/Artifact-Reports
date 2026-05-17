import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../workspace/workspace_controller.dart';
import 'content_tab.dart';
import 'dashboard_tabs.dart';
import 'overview_tab.dart';
import 'performance_tab.dart';
import 'period_selector.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workspace = ref.watch(currentWorkspaceProvider);
    final tab = ref.watch(selectedTabProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.generalInfo, style: AppTypography.display),
                      if (workspace != null) ...[
                        const SizedBox(height: 4),
                        Text(workspace.name, style: AppTypography.caption),
                      ],
                    ],
                  ),
                  if (Env.isConfigured)
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: l10n.signOut,
                      onPressed: () =>
                          ref.read(authControllerProvider).signOut(),
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: DashboardTabBar(),
            ),
            const SizedBox(height: 12),
            // Period selector hides on the Content tab — period filtering
            // doesn't apply to a posts feed.
            if (tab != DashboardTab.content) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: PeriodSelector(),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(child: _Body(tab: tab)),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.tab});
  final DashboardTab tab;

  @override
  Widget build(BuildContext context) {
    switch (tab) {
      case DashboardTab.overview:
        return const OverviewTab();
      case DashboardTab.performance:
        return const PerformanceTab();
      case DashboardTab.content:
        return const ContentTab();
    }
  }
}
