/// Report row from public.reports. Minimal projection — the snapshot
/// itself lives in report_snapshots and is populated separately.
class Report {
  const Report({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.publicId,
    required this.visibility,
    required this.createdAt,
    this.expiresAt,
    this.config,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      workspaceId: json['workspace_id'] as String,
      title: json['title'] as String,
      publicId: json['public_id'] as String,
      visibility: json['visibility'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String workspaceId;
  final String title;
  final String publicId;
  final String visibility; // 'private' | 'public'
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? config;

  bool get isPublic => visibility == 'public';
}
