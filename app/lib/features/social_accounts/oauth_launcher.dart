import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'social_platform.dart';

/// Initiates the per-platform OAuth dance by asking the platform's
/// edge function for an auth URL and opening it in the external
/// browser. The callback URL lives on Supabase and lands a "you can
/// close this window" page after writing the social_accounts row.
class OAuthLauncher {
  OAuthLauncher(this._client);

  final SupabaseClient _client;

  /// Returns the function name for the platform's start handler.
  /// Throws [UnimplementedError] for platforms that haven't shipped
  /// real OAuth yet — UI should keep showing "coming soon" for those.
  String _startFunctionPath(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.youtube:
        return 'oauth-youtube/start';
      case SocialPlatform.instagram:
        return 'oauth-instagram/start';
      case SocialPlatform.tiktok:
        return 'oauth-tiktok/start';
      case SocialPlatform.x:
        return 'oauth-x/start';
      case SocialPlatform.linkedin:
        return 'oauth-linkedin/start';
      case SocialPlatform.gmb:
        return 'oauth-gmb/start';
      case SocialPlatform.uberall:
        throw UnimplementedError(
          '${platform.label} OAuth is not implemented yet.',
        );
    }
  }

  /// Returns true if [platform] has a working OAuth flow.
  bool isSupported(SocialPlatform platform) {
    try {
      _startFunctionPath(platform);
      return true;
    } on UnimplementedError {
      return false;
    }
  }

  /// Asks the start edge function for an auth URL, then opens it in
  /// the external browser. Returns true if the URL was launched.
  Future<bool> launch({
    required SocialPlatform platform,
    required String workspaceId,
  }) async {
    final path = _startFunctionPath(platform);
    final response = await _client.functions.invoke(
      path,
      body: {'workspace_id': workspaceId},
    );
    final data = response.data;
    if (data is! Map || data['auth_url'] is! String) {
      throw StateError('Unexpected /start response: $data');
    }
    final uri = Uri.parse(data['auth_url'] as String);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
