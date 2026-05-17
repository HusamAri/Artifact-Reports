import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(l10n.generalInfo, style: AppTypography.display),
        ),
      ),
    );
  }
}
