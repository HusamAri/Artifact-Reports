import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'workspace_controller.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(
          () => _error = AppLocalizations.of(context).workspaceNameRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(workspaceRepositoryProvider).create(name: name);
      ref.invalidate(myWorkspacesProvider);
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
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
                  Text(l10n.onboardingTitle, style: AppTypography.display),
                  const SizedBox(height: 8),
                  Text(l10n.onboardingSubtitle, style: AppTypography.caption),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: l10n.workspaceName,
                      filled: true,
                      fillColor: AppColors.bgSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppRadius.iconButton,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
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
                    child: Text(_submitting ? '…' : l10n.createWorkspace),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
