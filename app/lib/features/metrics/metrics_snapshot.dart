/// One row from metrics_snapshots. M3c only fills the numeric core;
/// engagement_rate / reach land in later platform-specific PRs.
class MetricsSnapshot {
  const MetricsSnapshot({
    required this.id,
    required this.socialAccountId,
    required this.capturedAt,
    this.followers,
    this.posts,
    this.impressions,
  });

  factory MetricsSnapshot.fromJson(Map<String, dynamic> json) {
    return MetricsSnapshot(
      id: json['id'] as String,
      socialAccountId: json['social_account_id'] as String,
      capturedAt: DateTime.parse(json['captured_at'] as String),
      followers: (json['followers'] as num?)?.toInt(),
      posts: (json['posts'] as num?)?.toInt(),
      impressions: (json['impressions'] as num?)?.toInt(),
    );
  }

  final String id;
  final String socialAccountId;
  final DateTime capturedAt;
  final int? followers;
  final int? posts;
  final int? impressions;
}
