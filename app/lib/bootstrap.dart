import 'dart:async';

import 'package:artifact_reports/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(M2): Supabase.initialize(url: ..., anonKey: ...)
  // TODO(M2): Configure error reporting (Sentry/Crashlytics)
  // TODO(M6): Initialize in_app_purchase + restore previous purchases

  runApp(const ProviderScope(child: ArtifactReportsApp()));
}
