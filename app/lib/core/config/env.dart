/// Compile-time configuration. Pass via `--dart-define` at build time:
///
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ...
abstract final class Env {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Base URL where the Next.js web-report front-end lives. Public
  /// report links are built as `{publicReportBaseUrl}/r/{publicId}`.
  static const String publicReportBaseUrl = String.fromEnvironment(
    'PUBLIC_REPORT_BASE_URL',
    defaultValue: 'https://reports.artifact.studio',
  );

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
