import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'report.dart';
import 'report_controller.dart';
import 'report_snapshot.dart';

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({required this.reportId, super.key});

  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncReport = ref.watch(reportProvider(reportId));
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportDetails)),
      body: asyncReport.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        data: (report) {
          if (report == null) {
            return Center(
              child: Text(l10n.reportNotFound, style: AppTypography.caption),
            );
          }
          return _Body(report: report);
        },
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.report});
  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncSnapshot = ref.watch(reportSnapshotProvider(report.id));
    return asyncSnapshot.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          e.toString(),
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
      data: (snapshot) {
        if (snapshot == null) {
          return Center(
            child:
                Text(l10n.reportSnapshotMissing, style: AppTypography.caption),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(report.title, style: AppTypography.display),
            const SizedBox(height: 4),
            Text(
              l10n.lastNDays(snapshot.periodDays),
              style: AppTypography.caption,
            ),
            const SizedBox(height: 20),
            _TotalsGrid(totals: snapshot.totals, l10n: l10n),
            const SizedBox(height: 16),
            if (snapshot.accounts.isNotEmpty) ...[
              Text(l10n.perAccount, style: AppTypography.title),
              const SizedBox(height: 8),
              for (final a in snapshot.accounts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _AccountRow(account: a),
                ),
              const SizedBox(height: 16),
            ],
            _ShareCard(report: report),
          ],
        );
      },
    );
  }
}

class _TotalsGrid extends StatelessWidget {
  const _TotalsGrid({required this.totals, required this.l10n});
  final SnapshotTotals totals;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final kpis = <_Kpi>[
      _Kpi(label: l10n.totalFollowers, value: totals.followers),
      _Kpi(label: l10n.totalImpressions, value: totals.impressions),
      _Kpi(label: l10n.totalReach, value: totals.reach),
      _Kpi(label: l10n.totalPosts, value: totals.posts),
    ];
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

class _Kpi {
  const _Kpi({required this.label, required this.value});
  final String label;
  final int? value;
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

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.account});
  final SnapshotAccount account;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(account.displayName, style: AppTypography.title),
                const SizedBox(height: 2),
                Text(account.platform, style: AppTypography.caption),
              ],
            ),
          ),
          Text(
            _formatNumber(account.followers),
            style: AppTypography.title,
          ),
        ],
      ),
    );
  }
}

class _ShareCard extends ConsumerStatefulWidget {
  const _ShareCard({required this.report});
  final Report report;

  @override
  ConsumerState<_ShareCard> createState() => _ShareCardState();
}

class _ShareCardState extends ConsumerState<_ShareCard> {
  bool _busy = false;

  String get _publicUrl {
    final base = Env.publicReportBaseUrl;
    return '$base/r/${widget.report.publicId}';
  }

  Future<void> _toggle(bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(reportRepositoryProvider)
          .setPublic(widget.report.id, public: value);
      ref.invalidate(reportsProvider);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(value ? l10n.linkEnabled : l10n.linkDisabled),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyLink() async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: _publicUrl));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.linkCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(l10n.publicLink, style: AppTypography.title),
              ),
              Switch(
                value: widget.report.isPublic,
                onChanged: _busy ? null : _toggle,
              ),
            ],
          ),
          if (widget.report.isPublic) ...[
            const SizedBox(height: 8),
            SelectableText(_publicUrl, style: AppTypography.caption),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _copyLink,
                icon: const Icon(Icons.copy, size: 16),
                label: Text(l10n.copy),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentWhite,
                  foregroundColor: AppColors.textOnAccent,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Text(l10n.publicLinkOff, style: AppTypography.caption),
          ],
        ],
      ),
    );
  }
}
