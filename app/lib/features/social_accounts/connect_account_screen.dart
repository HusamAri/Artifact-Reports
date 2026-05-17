import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'social_platform.dart';

/// Platform picker. Tapping a tile would normally kick off the OAuth
/// flow for that platform; in M3a the action is a placeholder while
/// the per-platform edge functions are still being built out.
class ConnectAccountScreen extends StatelessWidget {
  const ConnectAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectAccount)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: SocialPlatform.values.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final platform = SocialPlatform.values[i];
          return _PlatformTile(
            platform: platform,
            comingSoonLabel: l10n.comingSoon,
          );
        },
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  const _PlatformTile({
    required this.platform,
    required this.comingSoonLabel,
  });

  final SocialPlatform platform;
  final String comingSoonLabel;

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
        trailing: Text(comingSoonLabel, style: AppTypography.caption),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${platform.label}: $comingSoonLabel')),
          );
        },
      ),
    );
  }
}
