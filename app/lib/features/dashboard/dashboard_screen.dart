import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/env.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_controller.dart';
import '../metrics/metrics_controller.dart';
import '../social_accounts/social_account_controller.dart';
import '../workspace/workspace_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final workspace = ref.watch(currentWorkspaceProvider);
    final accountCount =
        ref.watch(socialAccountsProvider).valueOrNull?.length ?? 0;
    final followers = ref.watch(totalFollowersProvider);
    final impressions = ref.watch(totalImpressionsProvider);
    final posts = ref.watch(totalPostsProvider);
    final reach = ref.watch(totalReachProvider);

    final kpis = <_Kpi>[
      _Kpi(label: l10n.totalFollowers, value: followers),
      _Kpi(label: l10n.totalImpressions, value: impressions),
      _Kpi(label: l10n.totalPosts, value: posts),
      _Kpi(label: l10n.totalReach, value: reach),
    ];
    final hasAnyKpi = kpis.any((k) => k.value != null);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
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
              const SizedBox(height: 24),
              if (hasAnyKpi) ...[
                _KpiGrid(kpis: kpis),
                const SizedBox(height: 16),
              ],
              _AccountsCard(count: accountCount, l10n: l10n),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kpi {
  const _Kpi({required this.label, required this.value});
  final String label;
  final int? value;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpis});

  final List<_Kpi> kpis;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        for (final k in kpis) _KpiCard(label: k.label, value: k.value),
      ],
    );
  }
}

String _formatNumber(int? n) {
  if (n == null) return '—';
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.value});

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption),
          Text(_formatNumber(value), style: AppTypography.kpiNumber),
        ],
      ),
    );
  }
}

class _AccountsCard extends StatelessWidget {
  const _AccountsCard({required this.count, required this.l10n});

  final int count;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSurface,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: () => context.push('/accounts'),
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.connectedAccounts, style: AppTypography.title),
                    const SizedBox(height: 4),
                    Text(
                      count == 0 ? l10n.noAccountsYet : '$count',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
