import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../metrics/metrics_controller.dart';
import '../metrics/metrics_series.dart';

/// Line chart of total followers across all connected accounts over
/// the currently selected period. Renders nothing until the workspace
/// has at least two snapshots in the window — a single point doesn't
/// communicate a trend.
class FollowersChart extends ConsumerWidget {
  const FollowersChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncSeries = ref.watch(followersSeriesProvider);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.followersOverTime, style: AppTypography.title),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: asyncSeries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              data: (series) => series.length < 2
                  ? Center(
                      child: Text(
                        l10n.notEnoughDataYet,
                        style: AppTypography.caption,
                      ),
                    )
                  : _Chart(series: series),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chart extends StatelessWidget {
  const _Chart({required this.series});

  final List<TimeSeriesPoint> series;

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < series.length; i++)
        FlSpot(i.toDouble(), series[i].value.toDouble()),
    ];
    final minY = series.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    final maxY = series.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    final pad = ((maxY - minY).abs() * 0.1).clamp(1, double.infinity);

    return LineChart(
      LineChartData(
        minY: (minY - pad).toDouble(),
        maxY: (maxY + pad).toDouble(),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            color: AppColors.accentViolet,
            barWidth: 2,
            isCurved: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.accentViolet.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
