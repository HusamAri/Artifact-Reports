import 'package:flutter/material.dart';

/// Supported social platforms, mirroring the `social_platform` enum in
/// migration 0001. Display metadata lives here so screens stay platform-
/// agnostic.
enum SocialPlatform {
  instagram('instagram', 'Instagram', Icons.camera_alt_outlined),
  tiktok('tiktok', 'TikTok', Icons.music_note_outlined),
  x('x', 'X', Icons.alternate_email_outlined),
  youtube('youtube', 'YouTube', Icons.play_circle_outline),
  linkedin('linkedin', 'LinkedIn', Icons.business_outlined),
  gmb('gmb', 'Google Business', Icons.storefront_outlined),
  uberall('uberall', 'Uberall', Icons.public_outlined);

  const SocialPlatform(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;

  static SocialPlatform? fromId(String id) {
    for (final p in SocialPlatform.values) {
      if (p.id == id) return p;
    }
    return null;
  }
}
