import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../posts/post.dart';
import '../posts/post_controller.dart';

class ContentTab extends ConsumerWidget {
  const ContentTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final asyncPosts = ref.watch(postsProvider);
    return asyncPosts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            e.toString(),
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
      data: (posts) => posts.isEmpty
          ? _EmptyState(label: l10n.noContentYet)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              itemCount: posts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _PostTile(post: posts[i]),
            ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.thumbnailUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.thumbnailUrl!,
                width: 88,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 88,
                  height: 64,
                  color: AppColors.bgCanvas,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 88,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.bgCanvas,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                post.platform.icon,
                color: AppColors.textSecondary,
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.content ?? post.externalPostId,
                  style: AppTypography.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    post.accountName,
                    if (post.postedAt != null) _relativeTime(post.postedAt!),
                  ].where((s) => s.isNotEmpty).join(' • '),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y';
  if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo';
  if (diff.inDays >= 1) return '${diff.inDays}d';
  if (diff.inHours >= 1) return '${diff.inHours}h';
  if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
  return 'now';
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
