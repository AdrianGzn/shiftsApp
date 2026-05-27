class AuthUser {
  final String id;
  final String? email;
  final String displayName;
  final String? photoUrl;
  final String idToken;
  final String role;
  final int? idOrganization;

  AuthUser({
    required this.id,
    this.email,
    required this.displayName,
    this.photoUrl,
    required this.idToken,
    required this.role,
    this.idOrganization,
  });
}
