import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../metrics/metrics_controller.dart';

/// Segmented control for [DashboardPeriod]. Pill-shaped chips matching
/// the M2a chip token; active chip uses the white accent.
class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPeriodProvider);
    return Wrap(
      spacing: 8,
      children: [
        for (final period in DashboardPeriod.values)
          _PeriodChip(
            period: period,
            active: period == selected,
            onTap: () =>
                ref.read(selectedPeriodProvider.notifier).state = period,
          ),
      ],
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.period,
    required this.active,
    required this.onTap,
  });

  final DashboardPeriod period;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = active ? AppColors.chipBgActive : AppColors.chipBgMuted;
    final fg = active ? AppColors.textOnAccent : AppColors.textPrimary;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.chip),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            '${period.days}d',
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: active ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
