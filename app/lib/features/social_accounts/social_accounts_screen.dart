import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
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

class _AccountTile extends ConsumerWidget {
  const _AccountTile({required this.account});

  final SocialAccount account;

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
        leading: Icon(account.platform.icon, color: AppColors.accentViolet),
        title: Text(account.displayName, style: AppTypography.title),
        subtitle: Text(
          account.handle ?? account.platform.label,
          style: AppTypography.caption,
        ),
        trailing: IconButton(
          tooltip: l10n.disconnect,
          icon: const Icon(Icons.link_off, color: AppColors.textSecondary),
          onPressed: () async {
            await ref
                .read(socialAccountRepositoryProvider)
                .disconnect(account.id);
            ref.invalidate(socialAccountsProvider);
          },
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
