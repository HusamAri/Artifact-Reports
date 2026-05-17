/// Minimal data model for the workspaces table. Mirrors the M1 schema.
class Workspace {
  const Workspace({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.planTier,
    required this.locale,
  });

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String,
      planTier: json['plan_tier'] as String? ?? 'free',
      locale: json['locale'] as String? ?? 'en',
    );
  }

  final String id;
  final String name;
  final String ownerId;
  final String planTier;
  final String locale;
}
