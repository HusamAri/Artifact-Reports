/// One row from metrics_snapshots. Numeric fields are nullable so
/// platforms that don't surface them can still record a heartbeat.
class MetricsSnapshot {
  const MetricsSnapshot({
    required this.id,
    required this.socialAccountId,
    required this.capturedAt,
    this.followers,
    this.posts,
    this.impressions,
    this.reach,
    this.engagementRate,
  });

  factory MetricsSnapshot.fromJson(Map<String, dynamic> json) {
    return MetricsSnapshot(
      id: json['id'] as String,
      socialAccountId: json['social_account_id'] as String,
      capturedAt: DateTime.parse(json['captured_at'] as String),
      followers: (json['followers'] as num?)?.toInt(),
      posts: (json['posts'] as num?)?.toInt(),
      impressions: (json['impressions'] as num?)?.toInt(),
      reach: (json['reach'] as num?)?.toInt(),
      engagementRate: (json['engagement_rate'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String socialAccountId;
  final DateTime capturedAt;
  final int? followers;
  final int? posts;
  final int? impressions;
  final int? reach;
  final double? engagementRate;
}
