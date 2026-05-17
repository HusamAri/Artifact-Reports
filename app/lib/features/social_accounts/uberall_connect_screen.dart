import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';
import '../workspace/workspace_controller.dart';
import 'social_account_controller.dart';

/// Uberall has no OAuth — operators paste their account's private API
/// key. The key is validated through the connect-uberall edge function
/// (which probes /api/locations) before any DB write.
class UberallConnectScreen extends ConsumerStatefulWidget {
  const UberallConnectScreen({super.key});

  @override
  ConsumerState<UberallConnectScreen> createState() =>
      _UberallConnectScreenState();
}

class _UberallConnectScreenState extends ConsumerState<UberallConnectScreen> {
  final _keyController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final key = _keyController.text.trim();
    final l10n = AppLocalizations.of(context);
    if (key.isEmpty) {
      setState(() => _error = l10n.apiKeyRequired);
      return;
    }
    final workspaceId = ref.read(currentWorkspaceIdProvider);
    if (workspaceId == null) {
      setState(() => _error = l10n.noWorkspaceSelected);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'connect-uberall',
        body: {'workspace_id': workspaceId, 'api_key': key},
      );
      final data = response.data;
      if (data is! Map || data['account_id'] is! String) {
        throw StateError('Unexpected response: $data');
      }
      ref.invalidate(socialAccountsProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.connectedSuccessfully)),
      );
      if (context.canPop()) context.pop();
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
      appBar: AppBar(title: const Text('Uberall')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.uberallApiKeyHint, style: AppTypography.caption),
              const SizedBox(height: 16),
              TextField(
                controller: _keyController,
                autofocus: true,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.apiKey,
                  filled: true,
                  fillColor: AppColors.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.iconButton),
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
                    borderRadius: BorderRadius.circular(AppRadius.iconButton),
                  ),
                ),
                child: Text(_submitting ? '…' : l10n.connect),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
