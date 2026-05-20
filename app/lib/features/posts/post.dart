import '../social_accounts/social_platform.dart';

/// Minimal projection of a posts row joined with the owning social
/// account so the feed can show platform iconography without a second
/// query.
class Post {
  const Post({
    required this.id,
    required this.socialAccountId,
    required this.externalPostId,
    required this.platform,
    required this.accountName,
    this.postedAt,
    this.content,
    this.thumbnailUrl,
    this.metrics,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final accountJson = json['social_accounts'] as Map<String, dynamic>?;
    final platformId = accountJson?['platform'] as String?;
    final platform =
        platformId == null ? null : SocialPlatform.fromId(platformId);
    final mediaUrls = (json['media_urls'] as List?)?.cast<String>();
    return Post(
      id: json['id'] as String,
      socialAccountId: json['social_account_id'] as String,
      externalPostId: json['external_post_id'] as String,
      platform: platform ?? SocialPlatform.youtube,
      accountName: accountJson?['display_name'] as String? ?? '',
      postedAt: json['posted_at'] == null
          ? null
          : DateTime.parse(json['posted_at'] as String),
      content: json['content'] as String?,
      thumbnailUrl:
          mediaUrls != null && mediaUrls.isNotEmpty ? mediaUrls.first : null,
      metrics: json['metrics'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String socialAccountId;
  final String externalPostId;
  final SocialPlatform platform;
  final String accountName;
  final DateTime? postedAt;
  final String? content;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metrics;
}
