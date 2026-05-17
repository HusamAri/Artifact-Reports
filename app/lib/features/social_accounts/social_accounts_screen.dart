import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../metrics/metrics_controller.dart';
import 'social_account.dart';
import 'social_account_controller.dart';

class SocialAccountsScreen extends ConsumerWidget {
  const SocialAccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accountsAsync = ref.watch(socialAccountsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectedAccounts)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/accounts/connect'),
        icon: const Icon(Icons.add),
        label: Text(l10n.connectAccount),
      ),
      body: accountsAsync.when(
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
        data: (accounts) => accounts.isEmpty
            ? _EmptyState(label: l10n.noAccountsYet)
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: accounts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _AccountTile(account: accounts[i]),
              ),
      ),
    );
  }
}

class _AccountTile extends ConsumerStatefulWidget {
  const _AccountTile({required this.account});

  final SocialAccount account;

  @override
  ConsumerState<_AccountTile> createState() => _AccountTileState();
}

class _AccountTileState extends ConsumerState<_AccountTile> {
  bool _syncing = false;

  Future<void> _sync() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _syncing = true);
    try {
      await ref
          .read(socialAccountRepositoryProvider)
          .triggerSync(widget.account.id);
      ref.invalidate(socialAccountsProvider);
      ref.invalidate(latestMetricsProvider);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.syncSuccess)));
    } on Exception catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final account = widget.account;
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
        leading: Icon(account.platform.icon, color: AppColors.accentViolet),
        title: Text(account.displayName, style: AppTypography.title),
        subtitle: Text(
          account.handle ?? account.platform.label,
          style: AppTypography.caption,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.sync,
              icon: _syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.refresh,
                      color: AppColors.textSecondary,
                    ),
              onPressed: _syncing ? null : _sync,
            ),
            IconButton(
              tooltip: l10n.disconnect,
              icon: const Icon(
                Icons.link_off,
                color: AppColors.textSecondary,
              ),
              onPressed: () async {
                await ref
                    .read(socialAccountRepositoryProvider)
                    .disconnect(account.id);
                ref.invalidate(socialAccountsProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          label,
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
