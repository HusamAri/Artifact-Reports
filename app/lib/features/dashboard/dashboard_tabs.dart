import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';

enum DashboardTab { overview, performance, content }

final selectedTabProvider =
    StateProvider<DashboardTab>((_) => DashboardTab.overview);

String _label(DashboardTab tab, AppLocalizations l10n) {
  switch (tab) {
    case DashboardTab.overview:
      return l10n.tabOverview;
    case DashboardTab.performance:
      return l10n.tabPerformance;
    case DashboardTab.content:
      return l10n.tabContent;
  }
}

/// Chip-style segmented control. Mirrors the filter-chip pattern from
/// docs/design-system.md — active = white chip, idle = muted.
class DashboardTabBar extends ConsumerWidget {
  const DashboardTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selected = ref.watch(selectedTabProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final tab in DashboardTab.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _TabChip(
                label: _label(tab, l10n),
                active: tab == selected,
                onTap: () => ref.read(selectedTabProvider.notifier).state = tab,
              ),
            ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
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
