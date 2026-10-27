import 'package:flutter/material.dart';

import '../l10n/gen/app_localizations.dart';

/// Maps role id -> display label, in the order they should appear in pickers.
const Map<String, String> kRoleLabels = {
  'builder': 'Builder / Owner',
  'pm': 'Project Manager',
  'site_engineer': 'Site Engineer',
  'supervisor': 'Supervisor',
  'vendor': 'Vendor / Supplier',
  'contractor': 'Contractor / Subcontractor',
};

/// Languages the in-app language toggle supports, keyed by the code stored
/// on the user's profile — label is shown in its own language so a user can
/// find their language without already reading the current UI language.
const Map<String, String> kSupportedLanguages = {
  'en': 'English',
  'hi': 'हिन्दी',
  'ta': 'தமிழ்',
  'te': 'తెలుగు',
};

/// Localized equivalent of [AppUser.roleLabel] / [kRoleLabels], for the
/// screens that participate in the language toggle. Everywhere else
/// ([AppUser.roleLabel]) keeps the English label, since it also doubles as
/// data (e.g. the role name stored on a chat message).
String localizedRoleLabel(BuildContext context, String role) {
  final l10n = AppLocalizations.of(context)!;
  switch (role) {
    case 'builder':
      return l10n.roleBuilder;
    case 'pm':
      return l10n.rolePm;
    case 'site_engineer':
      return l10n.roleSiteEngineer;
    case 'supervisor':
      return l10n.roleSupervisor;
    case 'vendor':
      return l10n.roleVendor;
    case 'contractor':
      return l10n.roleContractor;
    default:
      return kRoleLabels[role] ?? role;
  }
}

/// One distinct accent color per role, used to tint each role's dashboard
/// (AppBar, nav bar, icons) so the six dashboards are visually distinguishable
/// at a glance while still sharing the app's overall brand theme.
const Map<String, Color> kRoleAccentColors = {
  'builder': Color(0xFF3949AB),
  'pm': Color(0xFF00897B),
  'site_engineer': Color(0xFF1E88E5),
  'supervisor': Color(0xFF5E35B1),
  'vendor': Color(0xFFEF6C00),
  'contractor': Color(0xFF6D4C41),
};

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.assignedProjectIds,
    this.photoBase64,
    this.languageCode = 'en',
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'site_engineer',
      assignedProjectIds:
          (data['assignedProjectIds'] as List<dynamic>?)?.cast<String>() ?? const [],
      photoBase64: data['photoBase64'] as String?,
      languageCode: data['languageCode'] as String? ?? 'en',
    );
  }

  final String uid;
  final String name;
  final String email;
  final String role;
  final List<String> assignedProjectIds;
  final String? photoBase64;
  final String languageCode;

  bool get hasPhoto => photoBase64 != null && photoBase64!.isNotEmpty;

  bool get isBuilder => role == 'builder';
  bool get isPm => role == 'pm';
  bool get isSiteEngineer => role == 'site_engineer';
  bool get isSupervisor => role == 'supervisor';
  bool get isVendor => role == 'vendor';
  bool get isContractor => role == 'contractor';

  /// Builder and PM operate across every project; the other roles only see
  /// what's in [assignedProjectIds].
  bool get canViewAllProjects => isBuilder || isPm;

  String get roleLabel => kRoleLabels[role] ?? role;

  Color get accentColor => kRoleAccentColors[role] ?? kRoleAccentColors['builder']!;
}
