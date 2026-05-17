import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'metric_chart.dart';

class PerformanceTab extends StatelessWidget {
  const PerformanceTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      children: [
        MetricChart(
          metric: 'impressions',
          title: l10n.impressionsOverTime,
          color: AppColors.accentYellow,
        ),
        const SizedBox(height: 16),
        MetricChart(
          metric: 'reach',
          title: l10n.reachOverTime,
        ),
      ],
    );
  }
}
