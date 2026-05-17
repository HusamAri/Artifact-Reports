import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'workspace_controller.dart';

/// Redeems a workspace invite token. The token is passed in the URL
/// (e.g. /redeem?token=abc) and forwarded to the invite-accept edge fn.
class InviteRedeemScreen extends ConsumerStatefulWidget {
  const InviteRedeemScreen({required this.token, super.key});

  final String token;

  @override
  ConsumerState<InviteRedeemScreen> createState() => _InviteRedeemScreenState();
}

class _InviteRedeemScreenState extends ConsumerState<InviteRedeemScreen> {
  bool _running = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redeem());
  }

  Future<void> _redeem() async {
    try {
      final workspaceId = await ref
          .read(workspaceRepositoryProvider)
          .acceptInvite(widget.token);
      ref.invalidate(myWorkspacesProvider);
      ref.read(currentWorkspaceIdProvider.notifier).select(workspaceId);
      if (!mounted) return;
      context.go('/');
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.redeemingInvite, style: AppTypography.headline),
                  const SizedBox(height: 16),
                  if (_running)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accentWhite,
                        foregroundColor: AppColors.textOnAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppRadius.iconButton,
                          ),
                        ),
                      ),
                      child: Text(l10n.goHome),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
