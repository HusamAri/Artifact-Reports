/// Frozen report data captured at report-creation time by the
/// trg_capture_report_snapshot trigger.
class ReportSnapshot {
  const ReportSnapshot({
    required this.id,
    required this.reportId,
    required this.capturedAt,
    required this.periodDays,
    required this.totals,
    required this.accounts,
  });

  factory ReportSnapshot.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final totalsJson = data['totals'] as Map<String, dynamic>? ?? const {};
    final accountsJson = (data['accounts'] as List?) ?? const [];
    return ReportSnapshot(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      capturedAt: DateTime.parse(
        (data['captured_at'] as String?) ?? (json['created_at'] as String),
      ),
      periodDays: (data['period_days'] as num?)?.toInt() ?? 30,
      totals: SnapshotTotals.fromJson(totalsJson),
      accounts: accountsJson
          .whereType<Map<String, dynamic>>()
          .map(SnapshotAccount.fromJson)
          .toList(),
    );
  }

  final String id;
  final String reportId;
  final DateTime capturedAt;
  final int periodDays;
  final SnapshotTotals totals;
  final List<SnapshotAccount> accounts;
}

class SnapshotTotals {
  const SnapshotTotals({
    this.followers,
    this.impressions,
    this.reach,
    this.posts,
  });

  factory SnapshotTotals.fromJson(Map<String, dynamic> json) {
    return SnapshotTotals(
      followers: (json['followers'] as num?)?.toInt(),
      impressions: (json['impressions'] as num?)?.toInt(),
      reach: (json['reach'] as num?)?.toInt(),
      posts: (json['posts'] as num?)?.toInt(),
    );
  }

  final int? followers;
  final int? impressions;
  final int? reach;
  final int? posts;
}

class SnapshotAccount {
  const SnapshotAccount({
    required this.accountId,
    required this.platform,
    required this.displayName,
    this.followers,
    this.impressions,
    this.reach,
    this.posts,
  });

  factory SnapshotAccount.fromJson(Map<String, dynamic> json) {
    return SnapshotAccount(
      accountId: json['account_id'] as String,
      platform: json['platform'] as String? ?? 'unknown',
      displayName: json['display_name'] as String? ?? '',
      followers: (json['followers'] as num?)?.toInt(),
      impressions: (json['impressions'] as num?)?.toInt(),
      reach: (json['reach'] as num?)?.toInt(),
      posts: (json['posts'] as num?)?.toInt(),
    );
  }

  final String accountId;
  final String platform;
  final String displayName;
  final int? followers;
  final int? impressions;
  final int? reach;
  final int? posts;
}
