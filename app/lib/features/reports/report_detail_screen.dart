import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../dashboard/metric_chart.dart';
import '../metrics/metrics_controller.dart';
import 'report.dart';
import 'report_controller.dart';

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
    final periodDays = (report.config?['period_days'] as num?)?.toInt() ?? 30;
    // Override the dashboard's selected period so the embedded charts
    // render at this report's window — does not mutate the dashboard
    // selection persistently because the override is scoped to this
    // ProviderScope override.
    return ProviderScope(
      overrides: [
        selectedPeriodProvider.overrideWith(
          (_) => DashboardPeriod.values.firstWhere(
            (p) => p.days == periodDays,
            orElse: () => DashboardPeriod.thirtyDays,
          ),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(report.title, style: AppTypography.display),
          const SizedBox(height: 4),
          Text(
            l10n.lastNDays(periodDays),
            style: AppTypography.caption,
          ),
          const SizedBox(height: 20),
          MetricChart(metric: 'followers', title: l10n.followersOverTime),
          const SizedBox(height: 16),
          MetricChart(
            metric: 'impressions',
            title: l10n.impressionsOverTime,
            color: AppColors.accentYellow,
          ),
          const SizedBox(height: 16),
          MetricChart(metric: 'reach', title: l10n.reachOverTime),
          const SizedBox(height: 24),
          _ShareCard(report: report),
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
