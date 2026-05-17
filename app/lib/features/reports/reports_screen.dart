import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../metrics/metrics_controller.dart';
import '../workspace/workspace_controller.dart';
import 'report.dart';
import 'report_controller.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncReports = ref.watch(reportsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reports)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSheet(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.newReport),
      ),
      body: asyncReports.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              e.toString(),
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
        data: (reports) => reports.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.noReportsYet,
                    style: AppTypography.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: reports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _ReportTile(report: reports[i]),
              ),
      ),
    );
  }

  Future<void> _showCreateSheet(BuildContext context, WidgetRef ref) async {
    final workspaceId = ref.read(currentWorkspaceIdProvider);
    if (workspaceId == null) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _CreateReportSheet(workspaceId: workspaceId),
    );
  }
}

class _ReportTile extends ConsumerWidget {
  const _ReportTile({required this.report});

  final Report report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        title: Text(report.title, style: AppTypography.title),
        subtitle: Text(
          report.isPublic ? l10n.publicReport : l10n.privateReport,
          style: AppTypography.caption,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
        onTap: () => context.push('/reports/${report.id}'),
      ),
    );
  }
}

class _CreateReportSheet extends ConsumerStatefulWidget {
  const _CreateReportSheet({required this.workspaceId});

  final String workspaceId;

  @override
  ConsumerState<_CreateReportSheet> createState() => _CreateReportSheetState();
}

class _CreateReportSheetState extends ConsumerState<_CreateReportSheet> {
  final _titleController = TextEditingController();
  DashboardPeriod _period = DashboardPeriod.thirtyDays;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (title.isEmpty) {
      setState(() => _error = l10n.reportTitleRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(reportRepositoryProvider).create(
            workspaceId: widget.workspaceId,
            title: title,
            periodDays: _period.days,
          );
      ref.invalidate(reportsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.newReport, style: AppTypography.headline),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.reportTitle,
              filled: true,
              fillColor: AppColors.bgCanvas,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.iconButton),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.period, style: AppTypography.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final p in DashboardPeriod.values)
                ChoiceChip(
                  label: Text('${p.days}d'),
                  selected: _period == p,
                  onSelected: (_) => setState(() => _period = p),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentWhite,
              foregroundColor: AppColors.textOnAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.iconButton),
              ),
            ),
            child: Text(_submitting ? '…' : l10n.createReport),
          ),
        ],
      ),
    );
  }
}
