import 'social_platform.dart';

/// Minimal projection of social_accounts rows the app needs in M3a.
/// Token columns are intentionally absent — only edge functions read
/// those via the service-role decrypted view.
class SocialAccount {
  const SocialAccount({
    required this.id,
    required this.workspaceId,
    required this.platform,
    required this.displayName,
    this.handle,
    this.avatarUrl,
    this.lastSyncedAt,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) {
    final platformId = json['platform'] as String;
    final platform = SocialPlatform.fromId(platformId);
    if (platform == null) {
      throw FormatException('Unknown social platform: $platformId');
    }
    return SocialAccount(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      platform: platform,
      displayName: json['display_name'] as String? ?? '',
      handle: json['handle'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      lastSyncedAt: json['last_synced_at'] == null
          ? null
          : DateTime.parse(json['last_synced_at'] as String),
    );
  }

  final String id;
  final String workspaceId;
  final SocialPlatform platform;
  final String displayName;
  final String? handle;
  final String? avatarUrl;
  final DateTime? lastSyncedAt;
}
