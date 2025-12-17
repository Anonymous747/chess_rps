class AuthUser {
  final int userId;
  final String phoneNumber;
  final String accessToken;

  const AuthUser({
    required this.userId,
    required this.phoneNumber,
    required this.accessToken,
  });

  bool get isAuthenticated => accessToken.isNotEmpty;
}






