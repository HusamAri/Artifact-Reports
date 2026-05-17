import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../workspace/workspace_controller.dart';
import 'social_account_controller.dart';
import 'social_platform.dart';

/// Platform picker. YouTube triggers a real OAuth dance (M3b); the
/// remaining platforms show a "coming soon" snackbar until their
/// edge functions land in later M3 PRs.
class ConnectAccountScreen extends ConsumerWidget {
  const ConnectAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final launcher = ref.watch(oauthLauncherProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectAccount)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: SocialPlatform.values.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final platform = SocialPlatform.values[i];
          final supported = launcher.isSupported(platform);
          return _PlatformTile(
            platform: platform,
            supported: supported,
            trailingLabel: supported ? l10n.connect : l10n.comingSoon,
            onTap: () => _handleTap(context, ref, platform, supported),
          );
        },
      ),
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    SocialPlatform platform,
    bool supported,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!supported) {
      messenger.showSnackBar(
        SnackBar(content: Text('${platform.label}: ${l10n.comingSoon}')),
      );
      return;
    }
    final workspaceId = ref.read(currentWorkspaceIdProvider);
    if (workspaceId == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.noWorkspaceSelected)));
      return;
    }
    try {
      await ref.read(oauthLauncherProvider).launch(
            platform: platform,
            workspaceId: workspaceId,
          );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.finishInBrowser)),
      );
      // After the user finishes in the browser they'll come back to the
      // app — refresh the list and pop to /accounts.
      ref.invalidate(socialAccountsProvider);
      if (context.canPop()) context.pop();
    } on Exception catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.platform,
    required this.supported,
    required this.trailingLabel,
    required this.onTap,
  });

  final SocialPlatform platform;
  final bool supported;
  final String trailingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
        leading: Icon(platform.icon, color: AppColors.accentViolet),
        title: Text(platform.label, style: AppTypography.title),
        trailing: Text(
          trailingLabel,
          style: AppTypography.caption.copyWith(
            color: supported ? AppColors.accentViolet : AppColors.textSecondary,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
