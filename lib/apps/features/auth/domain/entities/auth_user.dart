class AuthUser {
  final String id;
  final String? email;
  final String? name;

  const AuthUser({
    required this.id,
    this.email,
    this.name,
  });
}
