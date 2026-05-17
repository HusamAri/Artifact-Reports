import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../auth/auth_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.generalInfo, style: AppTypography.display),
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
      ),
    );
  }
}
