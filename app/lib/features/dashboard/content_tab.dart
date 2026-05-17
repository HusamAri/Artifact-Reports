import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// Placeholder for the per-post feed. Real content lands once the
/// platform sync functions populate the `posts` table (M5).
class ContentTab extends StatelessWidget {
  const ContentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noContentYet,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
